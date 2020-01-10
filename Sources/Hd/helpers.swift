//
//  File.swift
//  
//
//  Created by william donner on 1/9/20.
//

import Foundation
import Kanna

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


public final class RunnableStream : NSObject,CustomRunnable {
    
    public var config: Configable
    // all of these variables are rquired by RunManager Protocol
    private   var recordExporter: SingleRecordExporter!
    public   var outputFilePath:LocalFilePath
    public   var exportMode:ExportMode
    public   var logLevel:LoggingLevel
    public   var custom:CustomControllable
    public   var crawlStats:CrawlStats
    
    required public init (config:Configable, custom:CustomControllable, outputFilePath:LocalFilePath, exportMode:ExportMode,logLevel:LoggingLevel) {
        self.outputFilePath = outputFilePath
        self.exportMode = exportMode
        self.custom = custom
        self.config = config
        self.logLevel = logLevel
        self.crawlStats = CrawlStats(partCustomizer: self.custom)
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
            
            self.recordExporter = SingleRecordExporter(outputStream: outputStream, exportMode: exportMode, runman: self)
            
        }
        catch {
            consoleIO.writeMessage("Could not initialize RunnableStream \(outputFilePath) \(error)",to:.error)
            exit(0)
        }
    }
}

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

    public  enum StreamOutputType {
        case error
        case standard
    }
    public init() {
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
    
    enum CodingKeys: String, CodingKey {
        case comment
        case roots
    }
    
    public var baseurlstr:String? = nil
    public var comment: String
    var roots:[String]
    var crawlStarts:[RootStart] = []
    

    
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
// was runstats
public final class CrawlStats:NSObject {
    
    var partCustomizer:CustomControllable!
    var keyCounts:NSCountedSet!
    var goodurls :Set<URLFromString>!
    var badurls :Set<URLFromString>!
    
    // dont let an item get on both lists
    func addBonusKey(_ s:String) {
        keyCounts.add(s)
    }
    func addStatsGoodCrawlRoot(urlstr:URLFromString) {
        guard let part  = partCustomizer?.partFromUrlstr(urlstr) else { fatalError();
        }
        goodurls.insert(part )
        if badurls.contains(part)   { badurls.remove(part) }
    }
    func addStatsBadCrawlRoot(urlstr:URLFromString) {
        guard let part  = partCustomizer?.partFromUrlstr(urlstr) else { fatalError();
        }
        if goodurls.contains(part)   { return }
        badurls.insert(part)
    }
    func reset() {
        goodurls = Set<URLFromString>()
        badurls = Set<URLFromString>()
        keyCounts = NSCountedSet()
    }
    init(partCustomizer :CustomControllable) {
        self.partCustomizer = partCustomizer
        super.init()
        reset()
    }
}
