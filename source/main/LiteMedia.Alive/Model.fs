module Model
    open System.Runtime.Serialization

    let XsltEnableDebug = true
    let XsltEnableDocumentFunction = true
    let XsltEnableScript = true
    let IndexTemplate = "Index.xslt"

    [<DataContract>]
    type Counter = { 
        [<field : DataMember(Name = "CategoryName")>]
        CategoryName: string; 
        [<field : DataMember(Name = "CounterName")>]
        CounterName: string; 
        [<field : DataMember(Name = "InstanceName")>]
        InstanceName : string Option;
        [<field : DataMember(Name = "Name")>]
        Name : string; 
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

//    let GetConfiguration = [|
//            { Name = "Hardware";
//              Counters = [|{ CategoryName = "Processor Information"; CounterName = "% Processor Time"; InstanceName = Some("_Total"); Name = "CPU"; CurrentValue = 50.f }|]
//            }
//          |]