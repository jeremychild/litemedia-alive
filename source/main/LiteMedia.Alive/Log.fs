namespace LiteMedia.Alive

// Helper module to deal with logging.
module Log =

  /// Dynamically load a log method
  let private logMethod logger level = 
    try
      let commonLogging = System.Reflection.Assembly.Load("Common.Logging")
      let logManager = commonLogging.GetType("Common.Logging.LogManager")
      let getLogger = logManager.GetMethod("GetLogger", [|typedefof<string>|])
      let loggerInstance = getLogger.Invoke(null, [|logger|])
      let loggerType = loggerInstance.GetType()
      let loggerMethod = loggerType.GetMethod(level, [|typedefof<string>|])
      Some((fun (m : string) -> (loggerMethod.Invoke(loggerInstance, [|m|]) |> ignore)))
    with | _ -> None
  
  // Lazy instance of activity log
  let private _audit = lazy ( 
    match (logMethod "alive-activity" "Info") with 
    | Some(log) -> log 
    | None -> (fun m -> ())
  )

  // Lazy instance of error log
  let private _error = lazy (
    match (logMethod "alive-debug" "Error") with
    | Some(log) -> log
    | None -> (fun m -> ())
  )

  // Public interface
  let activity format = Printf.ksprintf _audit.Value format
  let error format = Printf.ksprintf _error.Value format