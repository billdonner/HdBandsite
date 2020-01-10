//
//  File.swift
//  
//
//  Created by william donner on 1/9/20.
//

import Foundation

var outputStream : FileHandlerOutputStream!
var traceStream : FileHandlerOutputStream!
var consoleIO = ConsoleIO()

/*
 
 build either csv or json export stream
 
 inside SingleRecordExport we'll switch on export type to decide what to dump into the output stream
 */

public final class SingleRecordExporter {
    private(set) var exportMode:ExportMode
    private var rg:CustomRunnable
    var outputStream:FileHandlerOutputStream
    private var first = true
    public init(outputStream:FileHandlerOutputStream, exportMode: ExportMode, runman:CustomRunnable) {
        self.outputStream = outputStream
        self.rg = runman
        self.exportMode = exportMode
    }
    
    
    private func emitToOutputStream(_ s:String) {
        switch exportMode {
        case .csv,.json:
            
            print(s , to: &outputStream )// dont add extra
            
        case .md:
            break
        }
    }
    
    public func addHeaderToExportStream( ) {
        
        switch exportMode {
        case .csv:
            
            emitToOutputStream(rg.custom.makeheader())
            
            
        case .json:
            
            emitToOutputStream("""
[
""")
            case .md:
                break
        }
    }
    public func addTrailerToExportStream( ) {
        print("adding trailer!!!")
        
        switch exportMode {
            
        case .csv:
            if let trailer = rg.custom.maketrailer() {
                emitToOutputStream(trailer)
            }
        case .json:
            emitToOutputStream("""
]
""")
            case .md:
                break
        }
    }
    public  func addRowToExportStream( ) {
        switch exportMode {
            
        case .csv:
            let stuff = rg.custom.makerow( )
            emitToOutputStream(stuff)
            
        case .json:
            let stuff = rg.custom.makerow( )
            let parts = stuff.components(separatedBy: ",")
            if first {
                emitToOutputStream("""
{
""")
            } else {
                emitToOutputStream("""
,{
""")
            }
            for (idx,part) in parts.enumerated() {
                emitToOutputStream("""
                    "\(idx)":"\(part)"
                    """)
                if idx == parts.count - 1 {
                    emitToOutputStream("""
}
""")
                } else {
                    emitToOutputStream(",")
                }
                
            }
        case .md:
            break
        }
        first =  false
    }
}

public protocol CustomControllable : class  {
    var runman: CustomRunnable! { get set }
    var recordExporter : SingleRecordExporter!{ get set }
    func makerow() -> String
    func makeheader()->String
    func maketrailer()->String?
    
   // var context : Crowdable!{ get set }
    func setupController(runman: CustomRunnable,// context  :Crowdable,
                         exporter:SingleRecordExporter) 
    func startCrawling(baseURL: URL, configURL:URL,loggingLevel:LoggingLevel,finally:@escaping ReturnsCrawlResults)
    func scraper(_ technique: ParseTechnique, url:URL,  baseURL:URL?, html: String)->ParseResults?
    func incorporateParseResults(pr:ParseResults)
    func partFromUrlstr(_ urlstr:URLFromString) -> URLFromString
    func kleenex(_ f:String)->String
    func kleenURLString(_ url:URLFromString )->URLFromString?
    func absorbLink(_ link: Kanna.XMLElement , relativeTo: URL?, tag: String, links: inout [LinkElement])
    
}
extension CustomControllable {
    public func setupController(runman: CustomRunnable, //context  :Crowdable,
                                exporter:SingleRecordExporter) {
        self.runman = runman
        self.recordExporter = exporter
       // self.context = context
    }

    func partFromUrlstr(_ urlstr:URLFromString) -> URLFromString {
        return urlstr//URLFromString(urlstr.url?.lastPathComponent ?? "partfromurlstr failure")
    }
    func kleenex(_ f:String)->String {
        return f.replacingOccurrences(of: ",", with: "!")
    }
    func kleenURLString(_ url: URLFromString) -> URLFromString?{
        let original = url.string
        let newer = original.replacingOccurrences(of: "%20", with: "+")
        return URLFromString(newer)
    }

    
    public func startCrawling(baseURL: URL, configURL:URL,loggingLevel:LoggingLevel,finally:@escaping ReturnsCrawlResults) {
        let (roots,reportParams)  = runman.config.load(url: configURL)
        
        do {
            let lk = ScrapingMachine(scraper:runman.custom.scraper)
            let icrawler = try InnerCrawler(roots:roots,baseURL:baseURL, grubber:lk,logLevel:loggingLevel)
            let _ = try CrawlingMac (roots: roots, reportParams:reportParams,      icrawler:icrawler,   runman: runman)
            { crawlResult in
                // here we are done, reflect it back upstream
                // print(crawlResult)
                // now here must unwind back to original caller
                finally(crawlResult)
            }
            
        }
        catch {
            invalidCommand(444);exit(0)
        }
    }
}


public final class RunnableStream : NSObject,CustomRunnable {
    
    public var config: Configable
    // all of these variables are rquired by RunManager Protocol
    private   var recordExporter: SingleRecordExporter!
    public   var outputFilePath:LocalFilePath
    public   var outputType:ExportMode
    public   var runOptions:LoggingLevel
    public   var custom:CustomControllable
    public   var crawlerContext:CrawlStats
    
    required public init (config:Configable, custom:CustomControllable, outputFilePath:LocalFilePath, outputType:ExportMode,runOptions:LoggingLevel) {
        self.outputFilePath = outputFilePath
        self.outputType = outputType
        self.custom = custom
        self.config = config
        self.runOptions = runOptions
        self.crawlerContext = CrawlStats(partCustomizer: self.custom)
        bootstrapExportDir()
        
        do {
            // Some of the APIs that we use below are available in macOS 10.13 and above.
            guard #available(macOS 10.13, *) else {
                consoleIO.writeMessage("need at least 10.13",to:.error)
                exit(0)
            }
            let url = URL(fileURLWithPath: self.outputFilePath.path,relativeTo: ExportDirectoryURL)
            try  "".write(to: url, atomically: true, encoding: .utf8)
            let fileHandle = try FileHandle(forWritingTo: url)
            outputStream = FileHandlerOutputStream(fileHandle)
            
            super.init()
            //let exporttype = url.pathExtension == "csv" ? RecordExportType.csv : .json
            
            self.recordExporter = SingleRecordExporter(outputStream: outputStream, exportMode: outputType, runman: self)
            
        }
        catch {
            consoleIO.writeMessage("Could not initialize RunnableStream \(outputFilePath) \(error)",to:.error)
            exit(0)
        }
    }
}
// public only for testing
final class CrawlTable {
    public init() {
    }
    
    private  var crawlCountPeak: Int = 0
    private  var crawlCount = 0 //    var urlstouched: Int = 0
    private  var crawlState :  CrawlState = .crawling
    
    func crawlStats() -> (Int,Int) {
        return (crawlCount,crawlCountPeak)
    }
    //
    // urls serviced from the top of this list
    // urls are added to the bottom
    //
    private(set)  var  items:[URL] = []
    private var touched:Set<String> = [] // optimization to see if item on either list
    
    
    func addToListUnquely(_ url:URL) {
        let urlstr = url.absoluteString
        if !touched.contains(urlstr){
            
            items.append(url)
            touched.insert( urlstr)
            crawlCount += 1
            let now = items.count
            if now > crawlCountPeak { crawlCountPeak = now }
            //print("----added \(crawlCount) -  \(urlstr) to crawllist \(now) \(crawlCountPeak)")
            
        }
    }
    
    func popFromTop() -> URL?{
        if items.count == 0 {return nil}
        let topurl =  items.removeFirst() // get next to process
        return topurl
    }
    
    
  fileprivate  func crawlMeUp (whenDone:  ReturnsCrawlerContext, baseURL:URL?, stats: CrawlStats, innerCrawler:InnerCrawler,    didFinishUserCall: inout Bool,  savedExportOne: @escaping  ReturnsParseResults) {
        while crawlState == .crawling {
            if items.count == 0 {
                crawlState = .done
                
                innerCrawler.crawlDone( stats, &didFinishUserCall,whenDone)
                return // ends here
            }
            // get next to process
            guard  let rootStart = popFromTop() else {
                return
            }
            // squeeze down before crawling to keep memory reasonable
            autoreleasepool {
                innerCrawler.crawlOne(rootURL: rootStart, technique:.parseTop ,stats:stats,exportone:savedExportOne)
            }
        }
    }
}

////////
////////
///MARK- : STREAM IO STUFF

struct StderrOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}
public struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding
    
    public init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }
    
    mutating public func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}




public class ConsoleIO {
    public init() {
    }
    public  enum StreamOutputType {
        case error
        case standard
    }
    public func writeMessage(_ message: String, to: StreamOutputType = .standard, terminator: String = "\n") {
        switch to {
        case .standard:
            print("\(message)",terminator:terminator)
        case .error:
            fputs("\(message)\n", stderr)
        }
    }
}

public final  class ConfigurationProcessor :Configable {
    public var baseurlstr:String? = nil
    public var comment: String
    var roots:[String]
    var crawlStarts:[RootStart] = []
    
    enum CodingKeys: String, CodingKey {
        case comment
        case roots
    }
    
    init(_ baseURL:URL?) {
        baseurlstr = baseURL?.absoluteString
        comment = ""
        roots = []
    }
    
    public func load (url:URL? = nil) -> ([RootStart],ReportParams) {
        do {
            let obj =    try configLoader(url!)
            return (convertToRootStarts(obj: obj))
        }
        catch {
            invalidCommand(550); exit(0)
        }
    }
    func configLoader (_ configURL:URL) throws -> ConfigurationProcessor {
        do {
            let contents =  try Data.init(contentsOf: configURL)
            // inner
            do {
                let    obj = try JSONDecoder().decode(ConfigurationProcessor.self, from: contents)
                return obj
            }
            catch {
                exitWith(503,error: error)
            }
            // end inner
        }
        catch {
            exitWith(504,error: error)
        }// outer
        fatalError("should never get here")
    }
    func convertToRootStarts(obj:ConfigurationProcessor) -> ([RootStart], ReportParams){
        var toots:[RootStart] = []
        for root in obj.roots{
            toots.append(RootStart(name:root.components(separatedBy: ".").last ?? "?root?",
                                   urlstr:root,
                                   technique: .parseTop))
        }
        crawlStarts = toots
        let r = ReportParams(r: obj.comment)
        return (toots,r)
    }
}
