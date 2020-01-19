//
//  Igcrawlwidedeep.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation


fileprivate final class CrawlTable {

    private  var crawlCountPeak: Int = 0
    private  var crawlCount = 0 //    var urlstouched: Int = 0
    private  var crawlState :  CrawlState = .crawling
    
    
    //
    // urls serviced from the top of this list
    // urls are added to the bottom
    //
    private(set)  var  items:[URL] = []
    private var touched:Set<String> = [] // optimization to see if item on either list
    
    func crawlStats() -> (Int,Int) {
        return (crawlCount,crawlCountPeak)
    }
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
    
    
    fileprivate func crawlLoop (finally:  ReturnsCrawlStats,  stats: CrawlStats, innerCrawler:InnerCrawler,    didFinishUserCall: inout Bool,  savedExportOne: @escaping  ReturnsParseResults) {
        while crawlState == .crawling {
            if items.count == 0 {
                crawlState = .done
                
                innerCrawler.crawlDone( stats, &didFinishUserCall,finally)
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

fileprivate final class InnerCrawler : NSObject {
    private(set)  var ct =  CrawlTable()
    private var crawloptions: LoggingLevel
    
    private(set) var grubber:ScrapingMachine
    private(set) var places: [RootStart] = [] // set by crawler
    private var first = true
    
    init(roots:[RootStart], grubber:ScrapingMachine,logLevel:LoggingLevel = .none) throws {
        self.places = roots
        self.grubber = grubber
        self.crawloptions = logLevel
        
    }
    
    
    func crawlingStats()->(Int,Int) {
        return ct.crawlStats()
    }
    
    func addToCrawlList(_ f:URL ) {
        ct.addToListUnquely(f)
    }
    func crawlDone( _ crawlerContext: CrawlStats, _ didFinishUserCall: inout Bool, _ finally: ReturnsCrawlStats) {
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
            self.loadAndScrape(rootURL, technique:.parseTop) {parserez in
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
            
            self.loadAndScrape(rootURL,  technique:.parseLeaf) {leafparserez in
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
    
    func bigCrawlLoop(crawlStats:CrawlStats, exportOnePageWorth:@escaping ReturnsParseResults, finally:@escaping ReturnsCrawlStats) {
        
        var didFinishUserCall = false
        var savedExportOne = exportOnePageWorth
        var savedWhenDone = finally
        
        defer {
            // if we are ever really ever gonna leave via return, perhaps with out calling when done, it means WE ARE NOT DONE, just gonna a set a tiny timer to let things unwind then call the loope again
            if didFinishUserCall == false {
                // we never returned to the user and we are not going to do that instead, delay a bit to let closures unwind?
                
            }
        }
        
        // the places come in from the config file when it is parsed so add them to the crawl list now
        places.forEach(){ place  in
            guard  let url = URL(string:place.urlstr) else { fatalError() }
            addToCrawlList(url)
        }
        
        ct.crawlLoop(finally: finally,stats: crawlStats, innerCrawler: self, didFinishUserCall: &didFinishUserCall, savedExportOne: savedExportOne)
    }
}

fileprivate extension InnerCrawler {
    private  func loadAndScrape(_ rootURL:URL,
                                technique:ParseTechnique,
                                finito:@escaping ReturnsParseResults)
    {
        
        // take this into the background
        grubber.scrapeFromURL(rootURL,  parsingTechnique: technique){  parseres  in
            
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

final class OuterCrawler {
    private var returnsCrawlResults:ReturnsCrawlResults
    private  var icrawler : InnerCrawler
    private var crawlStats : CrawlStats
    private var transformer:Transformer
    
    init(roots:[RootStart],transformer:Transformer,
         loggingLevel:LoggingLevel,
         returnsResults:@escaping ReturnsCrawlResults)
        throws {
            self.transformer = transformer
            self.crawlStats = CrawlStats(transformer:transformer)
            self.returnsCrawlResults = returnsResults
            let lk = ScrapingMachine(scraper: transformer.scraper)
            // we start the inner crawler right here
            self.icrawler =  try InnerCrawler(roots:roots,  grubber:lk,logLevel:loggingLevel)
            startMeUp(roots, icrawler: icrawler )
    }
    
    
    
    func onepageworth(pr:ParseResults)->() {
        //each page we hit gets scraped and incorporated
        do {
            try transformer.incorporateParseResults(pr: pr)
        }
        catch {
            print("couldnt scrape onpageworth \(error)")
        }
    }
    
    
    private func startMeUp(_ roots:[RootStart],icrawler:InnerCrawler) {
        let startTime = Date()
        // let baseurltag = (icrawler.baseURL != nil) ?  icrawler.baseURL!.absoluteString : "baseurl fail" //XXXXXXXX
        print("[crawler] starting \(startTime), root \(roots[0].urlstr) please be patient")
        
        icrawler.bigCrawlLoop( crawlStats: crawlStats, exportOnePageWorth: onepageworth) {
            _ in
            // finally finished !
            
            let (count,peak) = self.icrawler.crawlingStats()
            let crawltime = Date().timeIntervalSince(startTime)
            
            self.finalSummary(stats: self.crawlStats,
                              count:count,
                              peak:peak,
                              crawltime:crawltime)
            
            let crawlResults = CrawlerStatsBlock(added:count,peak:peak,elapsedSecs:crawltime,secsPerCycle:crawltime/Double(count), count1: self.crawlStats.goodurls.count, count2:self.crawlStats.badurls.count, status:200)
            /// this is where we will finally wind up, need to call the user routine that was i
            
            self.returnsCrawlResults(crawlResults)
            
        }
    }
    
    private   func finalSummary (stats:CrawlStats, count:Int,peak:Int,crawltime:TimeInterval) {
        // copy into  TestResultsBlock
        var fb = TestResultsBlock()
        fb.reportTitle = "Crawl Summary"
        // this is not always good
        fb.command = CommandLine.arguments
        fb.rootcrawlpoints = stats.goodurls.map() {  kleenURLString($0)!.string }
        fb.leafpoints = stats.badurls.map() {  kleenURLString($0)!.string }
        fb.status = stats.badurls.count > 0 && stats.goodurls.count > 0 ? 201:(stats.goodurls.count > 0 ? 200:202)
        //let elapsed = String(format:"%02.3f ",crawltime)
        let percycle = count <= 0 ? 0.0 : (crawltime / Double(count))
        
        
        let statsblock = CrawlerStatsBlock(added:count,peak:peak,elapsedSecs:crawltime,secsPerCycle:percycle,
                                           count1: self.crawlStats.goodurls.count, count2:self.crawlStats.badurls.count,
                                           status:200)
        
        fb .crawlStats = statsblock
        
        //emitResultsAsTrace(fb)//), trace)
    }
}


// public only for testing
fileprivate final class ScrapingMachine:NSObject {
    private var scraperx:PageScraperFunc
    init(scraper:@escaping PageScraperFunc) {
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
    func scrapeFromURL( _ urlget:URL,
                        parsingTechnique:ParseTechnique,
                        whenDone:@escaping (( ParseResults ) ->())){
        
        let  (  _, html) = fetchHTMLFromURL(urlget)
        do {
            // [3] if no incoming, just get out of here
            if html.count == 0 {
                whenDone(  ParseResults(url:nil,
                                        technique: parsingTechnique,
                                        status: .failed(code:-98), pagetitle:"", links: [],  props: [], tags: []))
                return
            }
            // [4] parse the incoming and stash the results, regardless
            // note = html must already be filled in and hence urget is for info
            let  parseResultz  =  scraperx(parsingTechnique,urlget,   html)
            
            guard let parseResults = parseResultz else {
                
                whenDone( ParseResults(url:urlget,  
                                       technique: parsingTechnique,
                                       status: .failed(code: -99), pagetitle:"" , links: [], props: [], tags: []))
                return
                
            }
            // [5] figure out what to do
            let status:ParseStatus = parseResults.status
            switch status {
                
            case .failed(let code):
                whenDone( ParseResults(url:urlget,
                                       technique: parsingTechnique,
                                       status: .failed(code: code), pagetitle:"", links: [], props: [], tags: [])
                )
                return
                
            case .succeeded:
                whenDone(
                    ParseResults(url:urlget,  
                                 technique: parsingTechnique,
                                 status: .succeeded, pagetitle:parseResultz!.pagetitle, links:parseResults.links,  props: parseResults.props,  tags: [])
                )
                return
            }
        }
    }
}







