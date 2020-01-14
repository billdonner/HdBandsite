//
//  File.swift
//  
//
//  Created by william donner on 1/12/20.
//

import Foundation

final public class KrawlMaster: CrawlMeister
{
    private var whenDone:ReturnsCrawlResults?
    // this is where main calls in
   class KrawlingBeast {
        
        public init(
            // context:Crowdable,
            runman:BigMachineRunner,
            baseURL: URL ,
            configURL: URL ,
            options:LoggingLevel = .none,
            xoptions:ExportMode = .json,
            whenDone:@escaping ReturnsCrawlResults) throws {
            
            let xpr = SingleRecordExporter(outputStream: outputStream, exportMode:xoptions, runman: runman)
            runman.custom.setupController(runman: runman, //context: context,
                exporter: xpr)
            runman.custom.startCrawling(baseURL:baseURL, configURL:configURL,loggingLevel: options,finally:whenDone )
            
        }
        
        enum Error: Swift.Error {
            case missingFileName
            case failedToCreateFile
            case badFilePath
        }
    }

      class KrawlStream : NSObject,BigMachineRunner {
        
        public var config: Configable
        // all of these variables are rquired by RunManager Protocol
        private   var recordExporter: SingleRecordExporter!
        public   var outputFilePath:LocalFilePath
        public   var exportMode:ExportMode
        public   var logLevel:LoggingLevel
        public   var custom:BigMachinery
        public   var crawlStats:CrawlStats
        
        required public init (config:Configable, custom:BigMachinery, outputFilePath:LocalFilePath, exportMode:ExportMode,logLevel:LoggingLevel) {
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

    
    public  func boot(name:String, baseURL:URL,configURL: URL, opath:String,logLevel:LoggingLevel,exportMode:ExportMode, finally:@escaping ReturnsCrawlResults) throws{
        self.whenDone = finally
        let fp = URL(string:opath)?.deletingPathExtension().absoluteString
        guard var fixedPath = fp else {fatalError("cant fix outpath")}
        switch exportMode {
        case .csv : fixedPath+=".csv"
        case .json : fixedPath+=".json"
        case .md : fixedPath+=".md"
        }
        
        
        let rm = KrawlStream(config:ConfigurationProcessor(baseURL),
                                custom: Transformer(artist: name,
                                                    defaultArtUrl: "booly",
                                                    exportOptions: exportMode),
                                outputFilePath: LocalFilePath(fixedPath),
                                exportMode: exportMode,
                                logLevel: logLevel )
        
        let _ = try  KrawlingBeast( runman: rm,baseURL: baseURL,  configURL: configURL,options:logLevel,xoptions:exportMode,whenDone:finally)
    }
}
