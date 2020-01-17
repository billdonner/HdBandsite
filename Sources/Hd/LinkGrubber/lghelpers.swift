//
//  File.swift
//  
//
//  Created by william donner on 1/9/20.
//

import Foundation
import Kanna

var csvOutputStream : FileHandlerOutputStream!
var jsonOutputStream : FileHandlerOutputStream!
var traceStream : FileHandlerOutputStream!
var consoleIO = ConsoleIO()

/*
 
 build either csv or json export stream
 
 inside SingleRecordExport we'll switch on export type to decide what to dump into the output stream
 */

final class RecordExporter {
    private(set) var exportMode:ExportMode
    private var rg:BigMachineRunner
    private var first = true
    init(exportMode: ExportMode, runman:BigMachineRunner) {
    
        self.rg = runman
        self.exportMode = exportMode
    }
    
    private func emitToJSONStream(_ s:String) {
            print(s , to: &jsonOutputStream )// dont add extra
    
    }
//
//    private func emitToOutputStream(_ s:String) {
//            print(s , to: &csvOutputStream )// dont add extra
//            print(s , to: &jsonOutputStream )// dont add extra
//
//    }
    
   func addHeaderToExportStream( ) {
    
    print(rg.bigMachine.makecsvheader(), to: &csvOutputStream )// dont add extra
    print("""
      [
    """ ,
            to: &jsonOutputStream )// dont add extra
        

    }
    func addTrailerToExportStream( ) {
        print("adding trailer!!!")
         
            if let trailer = rg.bigMachine.mskecsvtrailer() {
               print(trailer , to: &csvOutputStream )
            }
     //emitToJSONStream(trailer)
    }
    func addRowToExportStream( ) {
        //switch exportMode {
            
       // case .csv:
            let stuff = rg.bigMachine.makecsvrow( )
                    print(stuff , to: &csvOutputStream )
            
       // case .json:
          //  let stuff = rg.custom.makecsvrow( )
            let parts = stuff.components(separatedBy: ",")
            if first {
                emitToJSONStream("""
{
""")
            } else {
                emitToJSONStream("""
,{
""")
            }
            for (idx,part) in parts.enumerated() {
                emitToJSONStream("""
                    "\(idx)":"\(part)"
                    """)
                if idx == parts.count - 1 {
                    emitToJSONStream("""
}
""")
                } else {
                    emitToJSONStream(",")
                }
                
            }
//        case .md:
//            break
//        }
        first =  false
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

 final  class ConfigurationProcessor :Configable {
    
    enum CodingKeys: String, CodingKey {
        case comment
        case roots
    }
    
   var baseurlstr:String? = nil
     var comment: String
    var roots:[String]
    var crawlStarts:[RootStart] = []
     
    init(_ baseURL:URL?) {
        baseurlstr = baseURL?.absoluteString
        comment = ""
        roots = []
    }
    
 func load (url:URL? = nil) -> ([RootStart],ReportParams) {
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
  final class CrawlStats:NSObject {
    
    var partCustomizer:BigMachinery!
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
    init(partCustomizer :BigMachinery) {
        self.partCustomizer = partCustomizer
        super.init()
        reset()
    }
}
