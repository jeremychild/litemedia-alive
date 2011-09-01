module Model
open Xunit
open Swensen.Unquote
open LiteMedia.Alive

let cpuCounter instance : Model.Counter =
  { 
    CategoryName = "Processor Information"; 
    CounterName = "% Processor Time"; 
    InstanceName = Some(instance); 
    Name = "CPU"; CurrentValue = 50.f
  }

let group : Model.Group = 
  {
    Name = "Hardware";
    UpdateLatency = 1000;
    Counters = 
    [|
        cpuCounter "_Total";
        cpuCounter "0,0";
        cpuCounter "0,1"
    |]
  }

// helper method to deserialize the json back to object
let deserialize<'a> (json : string) : 'a =
  let serializer = System.Runtime.Serialization.Json.DataContractJsonSerializer(typedefof<'a>)
  use reader = new System.IO.MemoryStream(System.Text.Encoding.UTF8.GetBytes(json))
  serializer.ReadObject(reader) :?> 'a

[<Fact>]
let ``should transfer group name to serialized json`` () =
  test <@ group.Name = (deserialize<Model.Group> (group.ToJson())).Name @>

[<Fact>]
let ``should transfer update latency to serialized json`` () =
  test <@ group.UpdateLatency = (deserialize<Model.Group> (group.ToJson())).UpdateLatency @>

[<Fact>]
let ``should transfer sequence of counters to serialized json`` () =
  test <@ group.Counters.[0].Name = (deserialize<Model.Group> (group.ToJson())).Counters.[0].Name @>

[<Fact>]
let ``should transfer category name to serialized json`` () =
  let counter = cpuCounter "_Total"
  test <@ counter.CategoryName = (deserialize<Model.Counter> (counter.ToJson())).CategoryName @>

[<Fact>]
let ``should transfer counter name to serialized json`` () =
  let counter = cpuCounter "_Total"
  test <@ counter.CounterName = (deserialize<Model.Counter> (counter.ToJson())).CounterName @>

[<Fact>]
let ``should transfer display name to serialized json`` () =
  let counter = cpuCounter "_Total"
  test <@ counter.Name = (deserialize<Model.Counter> (counter.ToJson())).Name @>

[<Fact>]
let ``should transfer instance name to serialized json`` () =
  let counter = cpuCounter "_Total"
  test <@ counter.InstanceName = (deserialize<Model.Counter> (counter.ToJson())).InstanceName @>

[<Fact>]
let ``should transfer current counter value to serialized json`` () =
  let counter = cpuCounter "_Total"
  test <@ counter.CurrentValue = (deserialize<Model.Counter> (counter.ToJson())).CurrentValue @>
  