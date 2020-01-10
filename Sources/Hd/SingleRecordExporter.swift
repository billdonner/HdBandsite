//
//  File.swift
//  
//
//  Created by william donner on 1/9/20.
//

import Foundation
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
