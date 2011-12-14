module Model
open Xunit
open Swensen.Unquote
open LiteMedia.Alive

let cpuCounter instance : Model.Counter =
  { 
    CategoryName = "Processor Information"; 
    CounterName = "% Processor Time"; 
    InstanceName = Some(instance); 
    Name = "CPU"; 
    Machine = "."
    CurrentValue = 50.f
  }

let chart : Model.Chart = 
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

let group : Model.Group = 
 {
    Name = "First Group";
    Charts = [| chart |]
 }

// helper method to deserialize the json back to object
let deserialize<'a> (json : string) : 'a =
  let serializer = System.Runtime.Serialization.Json.DataContractJsonSerializer(typedefof<'a>)
  use reader = new System.IO.MemoryStream(System.Text.Encoding.UTF8.GetBytes(json))
  serializer.ReadObject(reader) :?> 'a

[<Fact>]
let ``should transfer chart name to serialized json`` () =
  test <@ chart.Name = (deserialize<Model.Chart> (chart.ToJson())).Name @>

[<Fact>]
let ``should transfer update latency to serialized json`` () =
  test <@ chart.UpdateLatency = (deserialize<Model.Chart> (chart.ToJson())).UpdateLatency @>

[<Fact>]
let ``should transfer sequence of counters to serialized json`` () =
  test <@ chart.Counters.[0].Name = (deserialize<Model.Chart> (chart.ToJson())).Counters.[0].Name @>

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
  