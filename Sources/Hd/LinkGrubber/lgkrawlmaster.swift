//
//  File.swift
//  
//
//  Created by william donner on 1/12/20.
//

import Foundation

final public class LinkGrubber: CrawlMeister
{
    private var whenDone:ReturnsCrawlResults?
    // this is where main calls in
   class KrawlingBeast {
          init(
            // context:Crowdable,
            runman:BigMachineRunner,
            baseURL: URL ,
            configURL: URL ,
            options:LoggingLevel = .none,
            whenDone:@escaping ReturnsCrawlResults) throws {
            
            let xpr = RecordExporter(  runman: runman)
            runman.bigMachine.setupController(runman: runman, //context: context,
                exporter: xpr)
            runman.bigMachine.startCrawling(baseURL:baseURL, configURL:configURL,loggingLevel: options,finally:whenDone )
            
        }
        
        enum Error: Swift.Error {
            case missingFileName
            case failedToCreateFile
            case badFilePath
        }
    }

    class KrawlStream : NSObject,BigMachineRunner {
       var config: Configable
        // all of these variables are rquired by RunManager Protocol
        private   var recordExporter: RecordExporter!
         var logLevel:LoggingLevel
       var bigMachine:BigMachinery
        var crawlStats:CrawlStats
        
        required   init (config:Configable, custom:BigMachinery, csvoutPath:LocalFilePath,jsonoutPath:LocalFilePath, logLevel:LoggingLevel) {
     
            self.bigMachine = custom
            self.config = config
            self.logLevel = logLevel
            self.crawlStats = CrawlStats(partCustomizer: self.bigMachine)
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
                
                self.recordExporter = RecordExporter( runman: self)
                
            }
            catch {
                consoleIO.writeMessage("Could not initialize RunnableStream  \(error)",to:.error)
                exit(0)
            }
        }
    }

    
    public  func grub(name:String, baseURL:URL,configURL: URL, opath:String,logLevel:LoggingLevel, finally:@escaping ReturnsCrawlResults) throws{
        self.whenDone = finally
        let fp = URL(string:opath)?.deletingPathExtension().absoluteString
        guard let fixedPath = fp
            else {  fatalError("cant fix outpath") }

        let rm = KrawlStream(config:ConfigurationProcessor(baseURL),
                                custom: Transformer(artist: name,
                                                    defaultArtUrl: "booly"),
                                csvoutPath: LocalFilePath(fixedPath+".csv"),
                                jsonoutPath: LocalFilePath(fixedPath+".json"),
                                logLevel: logLevel )
        
        let _ = try  KrawlingBeast( runman: rm,baseURL: baseURL,  configURL: configURL,options:logLevel,whenDone:finally)
    }
}
