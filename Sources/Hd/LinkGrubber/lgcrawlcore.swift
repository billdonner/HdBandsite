
//touch may 14 15:00
//  VeryCommon.swift
//  grabads
//
//  Created by william donner on 4/12/19.
//  Copyright © 2019 midnightrambler. All rights reserved.
//
//
import Kanna
import Foundation

import func Darwin.fputs
import var Darwin.stderr

typealias ReturnsCrawlStats = (CrawlStats)->()
typealias ReturnsParseResults =  (ParseResults)->()
typealias ReturnsLinkElement = (LinkElement)->()

public typealias  ReturnsCrawlResults = (CrawlerStatsBlock)->()

// these really must be public, whereas the stuff below is only used within

public enum LoggingLevel {
    case none
    case verbose
}
public enum ExportMode {
    case csv
    case json
    case md
}


public struct CrawlerStatsBlock:Codable {
    enum CodingKeys: String, CodingKey {
        case elapsedSecs    = "elapsed-secs"
        case secsPerCycle     = "secs-percycle"
        case added
        case peak
        case count1
        case count2
        case status
    }
    var added:Int
    var peak:Int
    var elapsedSecs:Double
    var secsPerCycle:Double
    var count1: Int
    var count2: Int
    var status: Int
}
public protocol CrawlMeister {
    func boot(name:String, baseURL:URL,configURL: URL, opath:String,logLevel:LoggingLevel,exportMode:ExportMode,finally:@escaping ReturnsCrawlResults) throws -> (Void)
}

// global, actually


// freestanding
 var LibraryDirectoryURL:URL {
    return  URL(fileURLWithPath:  NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String )//+ "/" + "_export")// distinguish
}
var ExportDirectoryURL:URL {
    return  URL(fileURLWithPath:  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String )//+ "/" + "_export")// distinguish
}
func bootstrapExportDir() {
    //touched in crawler pile
    if !FileManager.default.fileExists(atPath:  ExportDirectoryURL.absoluteString) {
        createDir(url:ExportDirectoryURL)
    }
}
func createDir( url:URL) {
    do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    } catch   {
        fatalError("****MUST STOP CANT CREATE DIRECTORY \(url) ***** \(error)")
    }
}


// to pretty up for testing tweak the error string from cocoa into something json compatible (no duble quotes)
func safeError(error:Error) -> String {
    let matcher = """
"
""".trimmingCharacters(in: .whitespacesAndNewlines)
    let replacement = """
'
""".trimmingCharacters(in: .whitespacesAndNewlines)
    return  "\(error)".replacingOccurrences(of: matcher, with:replacement)
    
}


 func makesafe(error:Error) -> String {
    let matcher = """
"
""".trimmingCharacters(in: .whitespacesAndNewlines)
    let replacement = """
'
""".trimmingCharacters(in: .whitespacesAndNewlines)
    return  "\(error)".replacingOccurrences(of: matcher, with:replacement)
    
}

func decomposePlayDate(_ playdate:String) -> (String,String,String) { // month day year ==> year month day
    let month = playdate.prefix(2)
    let year = playdate.suffix(2)
    let start = playdate.index(playdate.startIndex, offsetBy: 2)
    let end = playdate.index(playdate.endIndex, offsetBy: -2)
    let range = start..<end
    let day = playdate[range]
    return (String(year),String(month),String(day))
}

public  struct LocalFilePath {
    private(set) var p : String
    public var path :String {
        return p//url.absoluteString
    }
    public  init(_ p:String){
        self.p = p
    }
}
public struct URLFromString :Hashable {
    public let  string : String
    public let  url: URL?
    
    public init(_ s:String ) {
        self.string = s
        self.url = URL(string:s)
    }
    
}
 
 protocol Configable:class, Decodable {
    var baseurlstr:String? {get set}
    var comment:String {get set}
    func load (url:URL? ) -> ([RootStart],ReportParams)
}

 protocol BigMachineRunner {
    var config:Configable {get set}
    var outputFilePath:LocalFilePath {get set}
    var exportMode:ExportMode  {get set}
    var logLevel:LoggingLevel  {get set}
    var custom:BigMachinery {get set}
    var crawlStats:CrawlStats {get set}
}

public struct  RootStart : Codable  {
    public let name: String
    public let technique:ParseTechnique
    public let urlstr: String
    
    public init(name:String, urlstr:String, technique: ParseTechnique = .passThru){ //, baseurlstr:String?) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.technique = technique; self.urlstr = urlstr;//self.baseurlstr = baseurlstr
    }
}

public enum OutputType: String {
    case csv = "csv"
    case json = "json"
    case text = "text"
    case unknown
    
    public init(value: String) {
        switch value {
        case "csv": self = .csv
        case "json": self = .json
        case "text": self = .text
        default: self = .unknown
        }
    }
}
public struct ReportParams {
    public var style:ExportMode
    public var reportTitle:String
    public var outputFilePath:String
    public var traceFilePath:String
    public init(r:String = "reportTitle",
                o:String =  "outputFilePath",
                f:ExportMode = ExportMode.csv ,
                t:String = "traceFilePath") {
        reportTitle = r
        outputFilePath = o
        style = f
        traceFilePath = t
    }
    public static func mock()->ReportParams {
        return ReportParams()
    }
}
//from apple via khanalou - i improved this to add an exclusive task segment before going to the concurrent queue
public final class LimitedWorker {
    private let serialQueue = DispatchQueue(label: "com.midnightrambler.serial.queue")
    private let concurrentQueue = DispatchQueue(label: "com.midnightrambler.concurrent.queue", attributes: .concurrent)
    private let semaphore: DispatchSemaphore
    
    public init(limit: Int) {
        semaphore = DispatchSemaphore(value: limit)
    }
    
    func enqueue(withLock: @escaping () -> (),concurrently: @escaping () -> ()) {
        serialQueue.async(execute: {
            self.semaphore.wait()
            withLock()
            self.concurrentQueue.async(execute: {
                concurrently()
                self.semaphore.signal()
            })
        })
    }
}

public func invalidCommand(_ code:Int) {
    print("""
        {"invalid-command":\(CommandLine.arguments), "status":\(code)}
        """)
    exit(0)
}



private enum ScrapeTechnique {
    case forcedFail
    case kannaLinksAndElementsCSS
    case kannaLinksAndElementsPath
}
public enum ParseTechnique :String, Codable {
    case passThru
    case parseTop
    case parseLeaf
    case indexDir
    private func scrapeTechniqueFor() -> ScrapeTechnique
    {
        switch self {
        case .parseTop:
            return ScrapeTechnique.kannaLinksAndElementsPath
        case .parseLeaf:
            return ScrapeTechnique.kannaLinksAndElementsPath
        case .indexDir:
            return ScrapeTechnique.forcedFail
        case .passThru:
            return scrapeTechniqueFor()
        }
    }
}


// scraping is not  Specific to any 3rd party libraries, custom scraping in the custom package
//public only for testing
public typealias PageScraperFunc = (ParseTechnique,URL,URL?,String)->ParseResults?
public typealias Crowdable = (Codable)

typealias TraceFuncSig =  (String,String?,Bool,Bool) -> ()

public enum Linktype {
    case leaf
    case hyperlink
}

public  struct LinkElement  {
    public let title: String
    public let href: URL?
    public let linktype: Linktype
    
    public var urlstr: String {
        if let url = href {
            return url.absoluteString
        }
        else {
            return "bad url"
        }
    }
    // when a LinkElement is creted, it tries to make a url from the supplied string
    public init(title:String,href:String,linktype:Linktype,relativeTo:URL?) {
        self.title = title; self.href=URL(string:href,relativeTo:relativeTo); self.linktype=linktype
    }
}
public enum ParseStatus:Equatable  {
    case failed(code:Int)
    case succeeded
}
public struct Props : Codable,Hashable {
    public let key: String
    public let value: String
    public init(key:String,value:String) {
        self.key = key
        self.value = value
    }
}
public struct ParseResults {
    public  let url : URL?
    public let baseurl: URL?
    public  let technique : ParseTechnique
    public  let status : ParseStatus
    
    public  let pagetitle: String
    public  let links :  [LinkElement]
    public  let props : [Props]
    public  let tags : [String]
    public init(url:URL?,baseurl:URL?,
                technique:ParseTechnique,
                status:ParseStatus,
                pagetitle:String,
                links:[LinkElement],
                props:[Props],
                tags:[String]) {
        
        self.url = url
        self.baseurl = baseurl
        self.technique = technique
        self.status = status
        self.pagetitle = pagetitle
        self.links = links
        self.props = props
        self.tags = tags
    }
}

enum CrawlState {
    case crawling
    case done
    case failed
}

struct TestResultsBlock:Codable {
    enum CodingKeys: String, CodingKey {
        case crawlStats    = "crawl-stats"
        case crawlerStarted     = "crawler-started"
        case reportTitle = "report-title"
        case status
        //        case leafpoints
        //        case rootcrawlpoints
        case command
    }
    var status:Int = 0
    var leafpoints:[String]? = []
    var rootcrawlpoints:[String]? = []
    var command:[String] = []
    var reportTitle:String = ""
    var crawlStats:CrawlerStatsBlock?
    var crawlerStarted: String =  ""
    
}
public  func exitWith( _ code:Int, error:Error) {

    func emitResultsAsTrace(_ fb: TestResultsBlock){//}, _ trace: TraceFuncSig) {
        // convert to json and put the whole chunk out
        do {
            let enc = JSONEncoder()
            enc.outputFormatting = .prettyPrinted
            let data = try enc.encode(fb)
            if let json = String(data:data,encoding:.utf8) {
                // trace(json,nil,true,false)
                print(json)
            }
        }
        catch {
            print("Could  not encode fullparseblock ", error)
        }
    }

    
    var trb = TestResultsBlock()
    trb.status = code
    trb.reportTitle = "-- config couldnt open \(safeError(error: error))"
    emitResultsAsTrace(trb)//, traceStream)
    exit(0)
}
