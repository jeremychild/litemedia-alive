namespace LiteMedia.Alive
open Model
open System
open System.Diagnostics

/// Performance monitor functionality
module PerfMon =
  exception NoSuchPerformanceCounterException of string

  /// How many milliseconds between samples
  let sampleDelay = 100

  /// Sleep for x ms and pass through value
  let sleep (ms : int) value = 
    ms |> System.Threading.Thread.Sleep |> ignore; value

  /// List.map with sleep before each mapping 
  let sleepMap ms fn_map list = List.map ((sleep ms) >> fn_map) list

  /// Retrieve a counter by groupName counterName and Some(instanceName)
  /// Example: let factory = counterFact "Processor Information" "% Processor Time" (Some("_Total"))
  ///          use(counter = factory())
  let counterFact groupName counterName instanceName (machineName : string) =
    (fun () ->
      try
        match instanceName with
        | Some name -> new PerformanceCounter(groupName, counterName, name, true, MachineName = machineName)
        | None -> new PerformanceCounter(groupName, counterName, true, MachineName = machineName)
      with 
        | :? InvalidOperationException as ex -> raise (NoSuchPerformanceCounterException(ex.Message))
      )

  /// Measure the average of a counter over time
  /// time is under what amount of time we'll be measuring
  /// factory is a factory method that returns a performance counter
  let measureAvg time (counter : PerformanceCounter) =
    let round (f : float32) = float32(System.Math.Round(float(f), 1))
    let samples = int (time / sampleDelay)
    [0..samples - 1] |> sleepMap sampleDelay (fun x -> counter.NextValue())
                     |> List.average
                     |> round                     

  /// Measure the number of discrete instances over time
  let measureNof time (counter : PerformanceCounter) =
    let value = lazy(counter.NextValue())
    (sleep time value).Value

  /// Get measure function based on counter type
  let measureFn = function
  | PerformanceCounterType.NumberOfItems32 -> measureNof
  | PerformanceCounterType.Timer100NsInverse // CPU
  | PerformanceCounterType.RawFraction // memory
  | _ -> measureAvg

  /// Example: measure 1000 (counterFact "Processor Information" "% Processor Time" (Some("_Total")))
  let measure time (factory : unit -> PerformanceCounter) =
    use counter = factory()
    try
      let result = (measureFn counter.CounterType) time counter
      (Log.activity "%s/%s@%s:%E" counter.CategoryName counter.CounterName counter.InstanceName result) |> ignore
      result
    finally
      counter.Close()

  /// Measure average of counter
  /// time, during what time do you measure
  /// counter that you want to measure
  /// Returns a new counter with updated value
  /// Example: measureCounter 1000 { CategoryName = "Processor Information"; CounterName = "% Processor Time"; InstanceName = Some("_Total"); Name = "CPU"; CurrentValue = 50.f }
  let measureCounter time counter =
    { counter with CurrentValue = measure time (counterFact counter.CategoryName counter.CounterName counter.InstanceName counter.Machine) }
  
  /// Async version of measure the counter
  /// Will set the counter to -1 on failure
  let measureCounterAsync time counter = 
    Async.FromContinuations(fun (cont, econt, ccont) ->
      try
        cont(measureCounter time counter)
      with
        // Does a better job communicating that the counter failed than an exception
        | exn -> 
          (Log.error "Failed measure counter %s/%s:%s" counter.CategoryName counter.CounterName exn.Message) |> ignore
          cont({ counter with CurrentValue = -1.f })
    )
    
  /// Measure the performance counters of the group
  /// Measurement is done during the group.UpdateLatency time. This measurement is done asyncrously.
  let measureGroup group =
    let measurements = group.Counters |> Seq.map (measureCounterAsync group.UpdateLatency)
    { group with Counters = Async.RunSynchronously(Async.Parallel(measurements), group.UpdateLatency * 3) }