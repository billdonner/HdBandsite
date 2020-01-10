
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

typealias ReturnsCrawlerContext = (CrawlStats)->()
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
public var LibraryDirectoryURL:URL {
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

public func makesafe(error:Error) -> String {
    let matcher = """
"
""".trimmingCharacters(in: .whitespacesAndNewlines)
    let replacement = """
'
""".trimmingCharacters(in: .whitespacesAndNewlines)
    return  "\(error)".replacingOccurrences(of: matcher, with:replacement)
    
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
public enum RunManagerOptions {
    case none
    case verbose
}
public protocol Configable:class, Decodable {
    var baseurlstr:String? {get set}
    var comment:String {get set}
    func load (url:URL? ) -> ([RootStart],ReportParams)
}

public protocol CustomRunnable {
    var config:Configable {get set}
    var outputFilePath:LocalFilePath {get set}
    var outputType:ExportMode  {get set}
    var runOptions:LoggingLevel  {get set}
    var custom:CustomControllable {get set}
    var crawlerContext:CrawlStats {get set}
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
    var trb = TestResultsBlock()
    trb.status = code
    trb.reportTitle = "-- config couldnt open \(safeError(error: error))"
    emitResultsAsTrace(trb)//, traceStream)
    exit(0)
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
// public, inner
//public
private final class InnerCrawler : NSObject {
    private(set)  var ct =  CrawlTable()
    private var crawloptions: LoggingLevel
    private(set) var baseURL:URL?
    
    public init(roots:[RootStart],baseURL:URL?, grubber:ScrapingMachine,logLevel:LoggingLevel = .none) throws {
        self.places = roots
        self.grubber = grubber
        self.crawloptions = logLevel
        self.baseURL = baseURL
    }
    private(set) var grubber:ScrapingMachine
    private(set) var places: [RootStart] = [] // set by crawler
    private var first = true
    
    func crawlingStats()->(Int,Int) {
        return ct.crawlStats()
    }
    
    func addToCrawlList(_ f:URL ) {
        ct.addToListUnquely(f)
    }
    func crawlDone( _ crawlerContext: CrawlStats, _ didFinishUserCall: inout Bool, _ finally: ReturnsCrawlerContext) {
        // here we should output the very last trailer record
        //        print("calling whendone from crawldone from crawlingcore with crawlcontext \(crawlerContext)  ")
        finally( crawlerContext)// everything alreadt passed
        didFinishUserCall = true
    }
    
    
    func crawlOne(rootURL:URL,technique:ParseTechnique,stats:CrawlStats,exportone:@escaping (ReturnsParseResults)) {
        
        // this is really where the action starts, we crawl from RootStart
        
        // the baseURL for the crawling hierarchy if any, is gleened from RootStart
        
        let topurlstr = URLFromString(rootURL.absoluteString)
        
        switch technique {
            
        case .parseTop:
            
            // in this case the brandujrl is the topurl
            self.loadAndScrape(rootURL, baseURL: baseURL,technique:.parseTop) {parserez in
                // take all these urls and put them on the end of the crawl list as Leafs
                guard let _ = parserez.url else {
                    return
                }
                
                guard parserez.status == .succeeded else {
                    stats.addStatsBadCrawlRoot(urlstr: topurlstr)
                    return
                }
                guard  parserez.links.count > 0 else {
                    stats.addStatsBadCrawlRoot(urlstr: topurlstr)
                    return
                }
                
                stats.addStatsGoodCrawlRoot(urlstr: topurlstr)
                if self.crawloptions == .verbose  {
                    print("\(self.ct.items.count),",terminator:"")//,\u{001B}[;m
                    fflush(stdout)
                }
                
                parserez.links.forEach(){ linkElement in
                    switch linkElement.linktype {
                    case .hyperlink:
                        if  let z = linkElement.href,
                            z.pathExtension == "" {
                            self.addToCrawlList(z)
                        }
                    case .leaf:
                        break /// exportone(linkElement)
                    }
                }//roots for each
                exportone(parserez)
            }
        case .parseLeaf:
            
            assert(true,"Never get here")
            
            self.loadAndScrape(rootURL, baseURL:baseURL, technique:.parseLeaf) {leafparserez in
                if self.crawloptions == .verbose  {  print("\(self.ct.items.count),",terminator:"")
                    fflush(stdout)
                }
                //exportone(leafparserez)
            }
        case .indexDir:
            consoleIO.writeMessage("> indexDir support coming soon \(topurlstr)",to:.error)
        case .passThru:
            consoleIO.writeMessage("> passthru \(topurlstr)",to:.error)
            
        }
    }
    
    
    
    
    func bigCrawlLoop(crawlerContext:CrawlStats, exportOnePageWorth:@escaping ReturnsParseResults, whenDone:@escaping ReturnsCrawlerContext) {
        
        var didFinishUserCall = false
        var savedExportOne = exportOnePageWorth
        var savedWhenDone = whenDone
        
        defer {
            // if we are ever really ever gonna leave via return, perhaps with out calling when done, it means WE ARE NOT DONE, just gonna a set a tiny timer to let things unwind then call the loope again
            if didFinishUserCall == false {
                // we never returned to the user and we are not going to do that instead, delay a bit to let closures unwind?
                //                delay(0.001){
                //                    consoleIO.writeMessage("> restarting the BigCrawlLoop",to:.error)
                //                    self.bigCrawlLoop(stats:stats, exportOnePageWorth:savedExportOne, whenDone: savedWhenDone)
                //                }
            }
        }
        
        // the places come in from the config file when it is parsed so add them to the crawl list now
        places.forEach(){ place  in
            guard  let url = URL(string:place.urlstr) else { fatalError() }
            addToCrawlList(url)
        }
        
        ct.crawlMeUp(whenDone: whenDone, baseURL: baseURL, stats: crawlerContext, innerCrawler: self, didFinishUserCall: &didFinishUserCall, savedExportOne: savedExportOne)
    }
}

extension InnerCrawler {
    private  func loadAndScrape(_ rootURL:URL, baseURL:URL?,
                                technique:ParseTechnique,
                                finito:@escaping ReturnsParseResults)
    {
        
        // take this into the background
        grubber.scrapeFromURL(rootURL, baseURL: baseURL, parsingTechnique: technique){  parseres  in
            
            // take whatever we have scraped back to the foreground
            finito (parseres)
        }
    }
    private func outString (_ s:String) {
        print(s)
    }
    
    func trace(_ cat:String,msg:String?=nil,quotes:Bool=true,last:Bool=false) {
        guard let mess = msg else { outString(cat); return }
        let comma = last ? "" : ","
        switch quotes {
        case true:
            let t = """
            "\(cat)":"\(mess)"\(comma)
            """
            outString (t)
        case false:
            let t = """
            "\(cat)":\(mess)\(comma)
            """
            outString (t)
        }
    }
    
    func delay(_ delay:Double, completion:@escaping ()->()){ // thanks Matt
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: completion)
    }
}

// public for testing only hmm
private final class CrawlingMac {
    
    init(roots:[RootStart],
         reportParams:ReportParams,
         icrawler :InnerCrawler,
         runman:CustomRunnable,
         returnsResults:@escaping ReturnsCrawlResults)
        throws {
            self.icrawler =   icrawler
            self.reportParams = reportParams
            self.runman = runman
            self.returnsCrawlResults = returnsResults
            startMeUp(roots)
    }
    
    private var returnsCrawlResults:ReturnsCrawlResults
    private var reportParams : ReportParams
    private var runman : CustomRunnable
    fileprivate  var icrawler : InnerCrawler
    
    func onepageworth(pr:ParseResults)->() {
        //each page we hit gets scraped and incorporated
        runman.custom.incorporateParseResults(pr: pr)
    }
    
    private func startMeUp(_ roots:[RootStart]) {
        let startTime = Date()
        let baseurltag = (icrawler.baseURL != nil) ?  icrawler.baseURL!.absoluteString : "baseurl fail"
        print("[crawler] starting \(startTime), baseURL \(baseurltag) please be patient")
        
        icrawler.bigCrawlLoop( crawlerContext: runman.crawlerContext, exportOnePageWorth: onepageworth) {
            _ in
            // finally finished !
            
            let (count,peak) = self.icrawler.crawlingStats()
            let crawltime = Date().timeIntervalSince(startTime)
            
            self.finalSummary(stats: self.runman.crawlerContext,
                              reportParams: self.reportParams,
                              count:count,
                              peak:peak,
                              crawltime:crawltime)
            
            let crawlResults = CrawlerStatsBlock(added:count,peak:peak,elapsedSecs:crawltime,secsPerCycle:crawltime/Double(count), count1: self.runman.crawlerContext.goodurls.count, count2:self.runman.crawlerContext.badurls.count, status:200)
            /// this is where we will finally wind up, need to call the user routine that was i
            
            
            self.returnsCrawlResults(crawlResults)
            
            // print("***** Returning CrawlResults \(crawlResults)")
        }
    }
    
    
    
    
    private   func finalSummary (stats:CrawlStats,reportParams:ReportParams,count:Int,peak:Int,crawltime:TimeInterval) {
        // copy into  TestResultsBlock
        var fb = TestResultsBlock()
        fb.reportTitle = reportParams.reportTitle
        // this is not always good
        fb.command = CommandLine.arguments
        fb.rootcrawlpoints = stats.goodurls.map() { runman.custom.kleenURLString($0)!.string }
        fb.leafpoints = stats.badurls.map() { runman.custom.kleenURLString($0)!.string }
        fb.status = stats.badurls.count > 0 && stats.goodurls.count > 0 ? 201:(stats.goodurls.count > 0 ? 200:202)
        //let elapsed = String(format:"%02.3f ",crawltime)
        let percycle = count <= 0 ? 0.0 : (crawltime / Double(count))
        
        
        let statsblock = CrawlerStatsBlock(added:count,peak:peak,elapsedSecs:crawltime,secsPerCycle:percycle,
                                           count1: self.runman.crawlerContext.goodurls.count, count2:self.runman.crawlerContext.badurls.count,
                                           status:200)
        
        fb .crawlStats = statsblock
        
        //emitResultsAsTrace(fb)//), trace)
    }
}


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

// public only for testing
public final class ScrapingMachine:NSObject {
    private var scraperx:PageScraperFunc
    public init(scraper:@escaping PageScraperFunc) {
        self.scraperx = scraper
        super.init()
    }
    // this could be improved to work asynchronously in the background??
    private func fetchHTMLFromURL( _ url:URL)->(String,String){
        do{
            let htmlstuff = try String(contentsOf: url)
            return (url.absoluteString,htmlstuff )
        }
        catch {
            consoleIO.writeMessage("Cant fetch string contents of \(url)",to: .error)
        }
        return ("","")
    }
    
    // this is the major entry point
    public func scrapeFromURL( _ urlget:URL, baseURL:URL?,
                               parsingTechnique:ParseTechnique,
                               whenDone:@escaping (( ParseResults ) ->())){
        
        let  (  _, html) = fetchHTMLFromURL(urlget)
        do {
            // [3] if no incoming, just get out of here
            if html.count == 0 {
                whenDone(  ParseResults(url:nil, baseurl:baseURL,
                                        technique: parsingTechnique,
                                        status: .failed(code:-98), pagetitle:"", links: [],  props: [], tags: []))
                return
            }
            // [4] parse the incoming and stash the results, regardless
            // note = html must already be filled in and hence urget is for info
            let  parseResultz  =  scraperx(parsingTechnique,urlget,  baseURL, html)
            
            guard let parseResults = parseResultz else {
                
                whenDone( ParseResults(url:urlget, baseurl: baseURL,
                                       technique: parsingTechnique,
                                       status: .failed(code: -99), pagetitle:"" , links: [], props: [], tags: []))
                return
                
            }
            // [5] figure out what to do
            let status:ParseStatus = parseResults.status
            switch status {
                
            case .failed(let code):
                whenDone( ParseResults(url:urlget, baseurl: baseURL,
                                       technique: parsingTechnique,
                                       status: .failed(code: code), pagetitle:"", links: [], props: [], tags: [])
                )
                return
                
            case .succeeded:
                whenDone(
                    ParseResults(url:urlget, baseurl: baseURL,
                                 technique: parsingTechnique,
                                 status: .succeeded, pagetitle:parseResultz!.pagetitle, links:parseResults.links,  props: parseResults.props,  tags: [])
                )
                return
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


var outputStream : FileHandlerOutputStream!
var traceStream : FileHandlerOutputStream!
var consoleIO = ConsoleIO()

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
