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
        [<field : DataMember(Name = "CurrentValue")>]
        CurrentValue : float32
    }

    [<DataContract>]
    type Group = {
        [<field : DataMember(Name = "Name")>]  
        Name : string
        [<field : DataMember(Name = "UpdateLatency")>]
        UpdateLatency : int
        [<field : DataMember(Name = "Counters")>] 
        Counters : Counter[] 
    }

    let counterJson (counter : Counter) =
      sprintf @"{""CategoryName"":""%s"",""CounterName"":""%s"",""CurrentValue"":%f,""InstanceName"":""%s"",""Name"":""%s""}"
        counter.CategoryName counter.CounterName counter.CurrentValue counter.InstanceName.Value counter.Name

    // Extend Counter entity with functions
    type Counter with
      member x.Json = counterJson

    /// Functional String.Join
    let stringJoin (separator : string) (seq : string seq) =
      System.String.Join(separator, seq |> Seq.toArray)    

    /// Get json of group
    let groupJson (group : Group) =
      let counters = group.Counters |> Seq.map counterJson |> stringJoin ","
      sprintf @"{""Counters"":[%s],""Name"":""%s"",""UpdateLatency"":%d}" counters group.Name, group.UpdateLatency

    // Extend Group entity with functions
    type Group with
      member x.Json = groupJson

//{"Counters":[{"CategoryName":"ASP.NET","CounterName":"Requests Queued","CurrentValue":0,"InstanceName":{"value":""},"Name":"Queued"}],"Name":"ASP.NET Requests","UpdateLatency":1000}

//    let GetConfiguration = [|
//            { Name = "Hardware";
//              Counters = [|{ CategoryName = "Processor Information"; CounterName = "% Processor Time"; InstanceName = Some("_Total"); Name = "CPU"; CurrentValue = 50.f }|]
//            }
//          |]