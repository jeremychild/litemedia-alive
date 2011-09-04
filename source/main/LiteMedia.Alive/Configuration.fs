namespace LiteMedia.Alive

module Node =
    [<Literal>]
    let Settings = "settings"
    [<Literal>]
    let Counters = "counters"
    [<Literal>] 
    let Column = "column"
    [<Literal>]
    let Group = "group"
    [<Literal>]
    let Groups = "groups"
    [<Literal>]
    let Name = "name"
    [<Literal>]
    let updateLatency = "updateLatency"
    [<Literal>]
    let Counter = "counter"
    [<Literal>]
    let CategoryName = "categoryName"
    [<Literal>]
    let CounterName = "counterName"
    [<Literal>]
    let InstanceName = "instanceName"

open System.Configuration
open System.Collections
open System.Collections.Generic
open Model

type SettingsSection() =
    inherit ConfigurationSection()

    [<ConfigurationProperty(Node.Column)>] 
    member self.Columns = self.[Node.Column] :?> string

/// Counter configurations
type CounterElement() =
    inherit ConfigurationElement()

    [<ConfigurationProperty(Node.Name)>]
    member self.Name 
      with get ()      = self.[Node.Name] :?> string
      and  set (value) = self.[Node.Name] <- value

    [<ConfigurationProperty(Node.CategoryName)>]
    member self.CategoryName 
      with get ()      = self.[Node.CategoryName] :?> string
      and  set (value) = self.[Node.CategoryName] <- value

    [<ConfigurationProperty(Node.CounterName)>]
    member self.CounterName 
      with get ()      = self.[Node.CounterName] :?> string
      and  set (value) = self.[Node.CounterName] <- value

    [<ConfigurationProperty(Node.InstanceName)>]
    member self.InstanceName
      with get ()      = self.[Node.InstanceName] :?> string
      and  set (value) = self.[Node.InstanceName] <- value

    member self.Model = {
        Name = self.Name;
        CategoryName = self.CategoryName; 
        CounterName = self.CounterName; 
        InstanceName = match self.InstanceName with | null -> None | name -> Some(name);
        CurrentValue = 0.f;
    }

[<ConfigurationCollection(typedefof<CounterElement>,CollectionType = ConfigurationElementCollectionType.BasicMap,AddItemName = Node.Counter)>]
type GroupElement() =
    inherit ConfigurationElementCollection()
    [<DefaultValue>] 
    val mutable name : string
    [<DefaultValue>]
    val mutable updateLatency : string

    override self.CollectionType = ConfigurationElementCollectionType.BasicMap
    override self.ElementName = Node.Counter
    override self.CreateNewElement() = new CounterElement() :> ConfigurationElement
    override self.GetElementKey el = (el :?> CounterElement).Name :> System.Object
    override self.OnDeserializeUnrecognizedAttribute (name,value) =
      match name with
      | Node.Name -> self.name <- value
                     true
      | Node.updateLatency -> self.updateLatency <- value
                              true
      | _ -> base.OnDeserializeUnrecognizedAttribute(name, value)

    let intParse = System.Int32.Parse
    
    /// Name of the group
    member self.Name
      with get ()      = self.name
      and  set (value) = self.name <- value

    /// How often the counter group should be updated
    member self.UpdateLatency
      with get ()      = self.updateLatency
      and  set (value) = self.updateLatency <- value

    member private self.Add el = base.BaseAdd el

    /// This collection counters
    member self.Counters
      with get ()      = [| for i in self do yield i.Model |]
      and  set (value) = value |> Seq.iter self.Add

    member self.Model = 
      { 
        Name = self.Name; 
        UpdateLatency = intParse(self.UpdateLatency); 
        Counters = self.Counters 
      }

    member self.toSeq =
        let enumerator = base.GetEnumerator()
        seq { while enumerator.MoveNext() do yield enumerator.Current :?> CounterElement }

    interface IEnumerable<CounterElement> with
        member self.GetEnumerator() = self.toSeq.GetEnumerator()
    

[<ConfigurationCollection(typedefof<GroupElement>,CollectionType = ConfigurationElementCollectionType.BasicMap,AddItemName = Node.Group)>]
type GroupsCollection() =
    inherit ConfigurationElementCollection()

    override self.CollectionType = ConfigurationElementCollectionType.BasicMap
    override self.ElementName = Node.Group
    override self.CreateNewElement() = new GroupElement() :> ConfigurationElement
    override self.GetElementKey el = (el :?> GroupElement).Name :> System.Object

    member private self.Add el = base.BaseAdd el
    member self.AddRange elements = elements |> Seq.iter self.Add

    member self.toSeq = 
        let enumerator = base.GetEnumerator()
        seq { while enumerator.MoveNext() do yield enumerator.Current :?> GroupElement }

    interface IEnumerable<GroupElement> with
        member self.GetEnumerator() = self.toSeq.GetEnumerator()

type CountersSection() =
    inherit ConfigurationSection()
    
    /// Charts that contain counters
    [<ConfigurationProperty(Node.Groups)>]
    member self.Groups 
      with get ()      = self.[Node.Groups] :?> GroupsCollection
      and  set (value) = self.[Node.Groups] <- value

    member self.Model = self.Groups |> Seq.map (fun group -> group.Model)

type Configuration() =
  /// Same as C# ?? operator but with Some/None
  /// Example: Some(1) >>> 2 -> 1
  /// Example: None >>> 2 -> 2
  static let (>>>) a b = match a with | None -> b | _ -> a.Value

  // Default counters if no configuration was supplied
  static let defaultCounters : CountersSection =
    let result = new CountersSection()
    let groups = new GroupsCollection()
    groups.AddRange 
      [|
        new GroupElement(Name = "Hardware", UpdateLatency = "1000", Counters = 
          [|
            new CounterElement(Name = "CPU", CategoryName = "Processor Information", CounterName = "% Processor Time", InstanceName = "_Total");
            new CounterElement(Name = "CPU #1", CategoryName = "Processor Information", CounterName = "% Processor Time", InstanceName = "0,0");
            new CounterElement(Name = "CPU #2", CategoryName = "Processor Information", CounterName = "% Processor Time", InstanceName = "0,1")
          |]);
        new GroupElement(Name = "Memory", UpdateLatency = "5000", Counters = 
          [|
            new CounterElement(Name = "Memory %", CategoryName = "Memory", CounterName = "% Committed Bytes In Use");
            new CounterElement(Name = "Paging File %", CategoryName = "Paging File", CounterName = "% Processor Time", InstanceName = "_Total")
          |]);
        new GroupElement(Name = "ASP.NET Requests", UpdateLatency = "5000", Counters = 
          [|
            new CounterElement(Name = "Queued", CategoryName = "ASP.NET", CounterName = "Requests Queued")
          |]);
        new GroupElement(Name = "Connections", UpdateLatency = "5000", Counters = 
          [|
            new CounterElement(Name = "SQL", CategoryName = "ASP.NET Applications", CounterName = "Session SQL Server connections total", InstanceName = "__Total__");
            new CounterElement(Name = "State Server", CategoryName = "ASP.NET Applications", CounterName = "Session State Server connections total", InstanceName = "__Total__")
          |]);
      |]
    result.Groups <- groups
    result

  // No settings at the moment but in the future
  static let defaultSettings : SettingsSection =
    new SettingsSection()

  /// Return a configuration section of type 'a or None if does not exist
  static member Section<'a> name =  
    match ConfigurationManager.GetSection("Alive/" + name) with
    | null -> None
    | :? 'a as config -> Some(config)
    | _ -> None

  static member Settings : SettingsSection = (Configuration.Section Node.Settings) >>> defaultSettings
  static member Counters : CountersSection = (Configuration.Section Node.Counters) >>> defaultCounters