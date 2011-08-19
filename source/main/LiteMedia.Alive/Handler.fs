
namespace LiteMedia.Alive

open Model

open System.Web
open System.Xml
open System.Xml.Xsl
open System.Xml.Linq
open System.IO
open System.Diagnostics
open System.Collections.Generic
open System.Runtime.InteropServices
open System.Runtime.Serialization.Json
open System.Runtime.Serialization

open LiteMedia.Alive

// Only want the script tag to not self close on render
type HtmlTextWriter(tw) =
    inherit XmlTextWriter(tw)
    let fullEndElements = ["script"; "title"]
    let mutable lastStartElement : string = null
    override x.WriteStartElement(prefix : string, localName : string, ns : string) =
        lastStartElement <- localName
        base.WriteStartElement(prefix, localName, ns)
    override x.WriteEndElement() =
        match fullEndElements |> List.exists ((=) lastStartElement) with
        | true -> base.WriteFullEndElement()
        | false -> base.WriteEndElement()

type Handler() as this =
    [<DllImport(@"Kernel32.dll", CallingConvention = CallingConvention.StdCall)>]
    extern void QueryPerformanceCounter (int64 byref)


    let RenderPage (documentReader : XmlReader, stylesheetReader : XmlReader, outputStream : Stream) =
        let transformer = new XslCompiledTransform(Model.XsltEnableDebug)
        let settings = new XsltSettings(Model.XsltEnableDocumentFunction, Model.XsltEnableScript)
        let resolver : XmlResolver = null

        transformer.Load(stylesheetReader, settings, resolver)
        transformer.Transform(documentReader, new HtmlTextWriter(new StreamWriter(outputStream)))

    let GetRequestParam (request : HttpRequest) paramName =
        match request.[paramName] with
        | null -> None
        | value -> Some value

    let BuildContentResponse (context : HttpContext) =
        let document = new System.Xml.XmlDocument()
        let stream = new MemoryStream()
        let writer = new StreamWriter(stream)
        let serializer = new DataContractSerializer(typedefof<Group[]>)
        serializer.WriteObject(stream, Configuration.Counters.Model |> Seq.toArray)
        // Reset stream
        stream.Position <- 0L
        document.Load(stream)

        let documentReader = new XmlNodeReader(document.DocumentElement)
        let stylesheet = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(Model.IndexTemplate)
        RenderPage (documentReader, XmlReader.Create(stylesheet), context.Response.OutputStream)

    let RawResponse (response : HttpResponse) path =
        // Add client caching here
        Debug.WriteLine "RawResponse" |> ignore
        let fileStream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(path)
        use reader = new System.IO.StreamReader(fileStream)
        response.Output.Write(reader.ReadToEnd())

    let xn s = XName.Get(s)

    let BuildSingleDataResponse (response : HttpResponse) group =
      let result = group |> PerfMon.measureGroup
      let serializer = new DataContractJsonSerializer(result.GetType())
      serializer.WriteObject(response.OutputStream, result) |> ignore

    interface IHttpHandler with
        member x.IsReusable = false
        
        member x.ProcessRequest(context : HttpContext) =
            match context.Request.PathInfo with
            | "/" -> 
                match context.Request.["file"], context.Request.["data"] with
                | null, null -> BuildContentResponse context
                | file, null -> RawResponse context.Response file
                | null, data -> BuildSingleDataResponse context.Response (Configuration.Counters.Model |> Seq.find (fun g -> g.Name = data))