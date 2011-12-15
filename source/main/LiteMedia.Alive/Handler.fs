
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

type Handler() =
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
        let data = { 
          Groups = (Configuration.SectionHandler.Instance.Counters.Model |> Seq.toArray); 
          Settings = Configuration.SectionHandler.Instance.Settings.Model 
        }

        let document = new System.Xml.XmlDocument()
        let stream = new MemoryStream()
        let writer = new StreamWriter(stream)
        let serializer = new DataContractSerializer(typedefof<XmlDocumentData>)
        serializer.WriteObject(stream, data)
        // Reset stream
        stream.Position <- 0L
        document.Load(stream)

        let documentReader = new XmlNodeReader(document.DocumentElement)
        let stylesheet = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(Model.IndexTemplate)
        RenderPage (documentReader, XmlReader.Create(stylesheet), context.Response.OutputStream)

    let RawResponse (response : HttpResponse) path =
        // Add client caching here
        let fileStream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(path)
        use reader = new System.IO.StreamReader(fileStream)
        response.Output.Write(reader.ReadToEnd())

    let xn s = XName.Get(s)

    let writeErrorResponse (response : HttpResponse) (exn : System.Exception) = 
      System.Web.HttpContext.Current.Server.ClearError() |> ignore
      response.TrySkipIisCustomErrors <- true
      response.ContentType <- "text/plain"
      response.StatusCode <- int (System.Net.HttpStatusCode.InternalServerError)
      response.Write(exn.Message)

    let BuildSingleDataResponse (response : HttpResponse) chart =
      try
        let result = chart |> PerfMon.measureChart
        response.Write(result.ToJson())
      with
        | :? PerfMon.NoSuchPerformanceCounterException as exn -> writeErrorResponse response exn
        | :? System.TimeoutException as exn -> writeErrorResponse response exn

    interface IHttpHandler with
        member x.IsReusable = false
        
        member x.ProcessRequest(context : HttpContext) =
          match context.Request.["file"], context.Request.["data"] with
          | null, null -> BuildContentResponse context
          | file, null -> RawResponse context.Response file
          | null, data -> BuildSingleDataResponse context.Response (Configuration.SectionHandler.Instance.Counters.Charts |> Seq.find (fun chart -> chart.Name = data))
          | _, _ -> failwith "Unknown Operation"