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

type CounterElement() =
    inherit ConfigurationElement()

    [<ConfigurationProperty(Node.Name)>]
    member self.Name = self.[Node.Name] :?> string

    [<ConfigurationProperty(Node.CategoryName)>]
    member self.CategoryName = self.[Node.CategoryName] :?> string

    [<ConfigurationProperty(Node.CounterName)>]
    member self.CounterName = self.[Node.CounterName] :?> string

    [<ConfigurationProperty(Node.InstanceName)>]
    member self.InstanceName = self.[Node.InstanceName] :?> string

    member self.Model = {
        Name = self.Name;
        CategoryName = self.CategoryName; 
        CounterName = self.CounterName; 
        InstanceName = match self.InstanceName with | null -> None | name -> Some(name);
        CurrentValue = 0.f
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
    member self.Name = self.name
    member self.UpdateLatency = self.updateLatency
    member self.Model = { Name = self.Name; UpdateLatency = intParse(self.UpdateLatency); Counters = [| for i in self do yield i.Model |] }

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

    member self.toSeq = 
        let enumerator = base.GetEnumerator()
        seq { while enumerator.MoveNext() do yield enumerator.Current :?> GroupElement }

    interface IEnumerable<GroupElement> with
        member self.GetEnumerator() = self.toSeq.GetEnumerator()

type CountersSection() =
    inherit ConfigurationSection()
    
    [<ConfigurationProperty(Node.Groups)>]
    member self.Groups = self.[Node.Groups] :?> GroupsCollection

    member self.Model = self.Groups |> Seq.map (fun group -> group.Model)


type Configuration() =
    static member Section<'a> name =  ConfigurationManager.GetSection("Alive/" + name) :?> 'a
    static member Settings : SettingsSection = Configuration.Section Node.Settings
    static member Counters : CountersSection = Configuration.Section Node.Counters