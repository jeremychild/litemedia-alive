module Model
    open System.Runtime.Serialization

    let XsltEnableDebug = true
    let XsltEnableDocumentFunction = true
    let XsltEnableScript = true
    let IndexTemplate = "Index.xslt"

    [<DataContract>]
    type Counter = { 
        [<field : DataMember(Name = "CategoryName")>]
        CategoryName: string
        [<field : DataMember(Name = "CounterName")>]
        CounterName: string 
        [<field : DataMember(Name = "InstanceName")>]
        InstanceName : string Option
        [<field : DataMember(Name = "Name")>]
        Name : string
        [<field : DataMember(Name = "Machine")>]
        Machine : string
        [<field : DataMember(Name = "CurrentValue")>]
        CurrentValue : float32
    }

    [<DataContract>]
    type Chart = {
        [<field : DataMember(Name = "Name")>]  
        Name : string
        [<field : DataMember(Name = "UpdateLatency")>]
        UpdateLatency : int
        [<field : DataMember(Name = "Max")>]
        Max : int
        [<field : DataMember(Name = "Counters")>] 
        Counters : Counter[] 
    }

    [<DataContract>]
    type Group = {
      [<field : DataMember(Name = "Name")>]
      Name : string
      [<field : DataMember(Name = "Charts")>]
      Charts : Chart[]
    }

    let counterJson (counter : Counter) =
      let instanceName = match counter.InstanceName with | Some(name) -> name | None -> ""
      sprintf @"{""CategoryName"":""%s"",""CounterName"":""%s"",""CurrentValue"":%f,""InstanceName"":{""value"":""%s""},""Name"":""%s""}"
        counter.CategoryName counter.CounterName counter.CurrentValue instanceName counter.Name

    // Extend Counter entity with functions
    type Counter with
      member this.ToJson() = counterJson this

    /// Functional String.Join
    let stringJoin (separator : string) (seq : string seq) =
      System.String.Join(separator, seq |> Seq.toArray)    

    /// Get json of group
    let chartJson (chart : Chart) =
      let counters = chart.Counters |> Seq.map counterJson |> stringJoin ","
      sprintf @"{""Counters"":[%s],""Name"":""%s"",""UpdateLatency"":%d}" counters chart.Name chart.UpdateLatency

    // Extend Chart entity with functions
    type Chart with
      member this.ToJson() = chartJson this