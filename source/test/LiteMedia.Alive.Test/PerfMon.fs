module PerfMon
open Xunit
open Swensen.Unquote
open LiteMedia.Alive

// Test data
let unknownCounter : Model.Counter = 
  { 
    Name = "GPU"; CurrentValue = 50.f;
    CategoryName = "Processor Information";
    CounterName = "% GPU Time";
    InstanceName = None;
    Machine = "."
  }

// Create a cpu counter
let cpuCounter instance : Model.Counter =
  { 
    CategoryName = "Processor Information"; 
    CounterName = "% Processor Time"; 
    InstanceName = Some(instance); 
    Name = "CPU"; 
    Machine = ".";
    CurrentValue = 50.f;
  }  

// Hardware group are cpu counters
let hardwareGroup : Model.Group = 
  { 
    Name = "Hardware";
    UpdateLatency = 1000;
    Max = 100;
    Counters = 
      [|
        cpuCounter "_Total";
        cpuCounter "0,0";
        cpuCounter "0,1"
      |]
  }

[<Fact>]
let ``cannot retrive performance counter from counterFact should throw exception`` () =
  raises<PerfMon.NoSuchPerformanceCounterException> <@ (PerfMon.counterFact unknownCounter.CategoryName unknownCounter.CounterName unknownCounter.InstanceName unknownCounter.Machine)() @>

[<Fact>]
let ``should retrieve value from average cpu performance counter`` () =
  test <@ (PerfMon.measureCounter 1000 (cpuCounter "_Total")).CurrentValue <> 50.f @>

[<Fact>]
let ``measure counter async should set counter value to -1. on failure`` () =
  let value = 
    async { 
      let! measured = PerfMon.measureCounterAsync 1000 unknownCounter
      return measured
    } |> Async.RunSynchronously
  test <@ value.CurrentValue = -1.f @>

[<Fact>]
let ``measure group should timeout after twice the UpdateLatency time has passed`` () =
  let stopwatch = System.Diagnostics.Stopwatch()
  stopwatch.Start() // Some how we should inject a long lasting perf counter here
  raises<System.TimeoutException> <@ PerfMon.measureGroup hardwareGroup @>
  test <@ stopwatch.ElapsedMilliseconds < 2500L && stopwatch.ElapsedMilliseconds > 2000L @>