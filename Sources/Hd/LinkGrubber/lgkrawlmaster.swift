//
//  File.swift
//  
//
//  Created by william donner on 1/12/20.
//

import Foundation

final public class LinkGrubber: CrawlMeister
{
    class KrawlStream : NSObject {
  
       var config: Configable
        // all of these variables are rquired by RunManager Protocol
       // private var recordExporter: RecordExporter!
        var logLevel:LoggingLevel
        var transformer:Transformer
        var crawlStats:CrawlStats
        
        required   init (config:Configable, transformer:Transformer, csvoutPath:LocalFilePath,jsonoutPath:LocalFilePath, logLevel:LoggingLevel) {
     
            self.transformer = transformer
            self.config = config
            self.logLevel = logLevel
            self.crawlStats = CrawlStats(transformer: self.transformer)
            bootstrapExportDir()
            
            do {
                // Some of the APIs that we use below are available in macOS 10.13 and above.
                guard #available(macOS 10.13, *) else {
                    consoleIO.writeMessage("need at least 10.13",to:.error)
                    exit(0)
                }
                let url = URL(fileURLWithPath:  csvoutPath.path,relativeTo: ExportDirectoryURL)
                try  "".write(to: url, atomically: true, encoding: .utf8)
                let fileHandle = try FileHandle(forWritingTo: url)
                csvOutputStream = FileHandlerOutputStream(fileHandle)
                
                let url2 = URL(fileURLWithPath:  jsonoutPath.path,relativeTo: ExportDirectoryURL)
                    try  "".write(to: url2, atomically: true, encoding: .utf8)
                    let fileHandle2 = try FileHandle(forWritingTo: url2)
                    jsonOutputStream = FileHandlerOutputStream(fileHandle2)
                
                
                super.init()
                //let exporttype = url.pathExtension == "csv" ? RecordExportType.csv : .json
                
                //self.recordExporter = RecordExporter( runman: self)
                
            }
            catch {
                consoleIO.writeMessage("Could not initialize RunnableStream  \(error)",to:.error)
                exit(0)
            }
        }
    }

    public  func grub(name:String,configURL: URL, opath:String,logLevel:LoggingLevel, finally:@escaping ReturnsCrawlResults) throws {
     
        guard let fixedPath = URL(string:opath)?.deletingPathExtension().absoluteString
            else {  fatalError("cant fix outpath") }

        let rm = KrawlStream(config:ConfigurationProcessor(),
                           transformer: Transformer(artist: name, defaultArtUrl: "booly"),
                                csvoutPath: LocalFilePath(fixedPath+".csv"),
                                jsonoutPath: LocalFilePath(fixedPath+".json"),
                                logLevel: logLevel )
         
        let xpr = RecordExporter(  bigMachineRunner: rm)
        
        rm.setupKrawler(exporter: xpr)
     
        rm.startCrawling(  configURL:configURL,loggingLevel: logLevel,finally:finally )
    }
}
