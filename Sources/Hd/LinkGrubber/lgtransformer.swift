
//
//  ManifezzClass: KrawlMaster 
//  UtilityTest
//
//  Created by william donner on 4/19/19.
//

import Foundation
import Kanna

/// add new code to write md files for Publish ing static site
public enum PublishingMode {
    case fromPublish
    case fromWithin
}

 protocol BigMachinery : class  {
    var runman: BigMachineRunner! { get set }
    var recordExporter : RecordExporter!{ get set }
    func makecsvrow() -> String
    func makecsvheader()->String
    func mskecsvtrailer()->String?
    
   // var context : Crowdable!{ get set }
    func setupController(runman: BigMachineRunner,// context  :Crowdable,
                         exporter:RecordExporter)
    func startCrawling(baseURL: URL, configURL:URL,loggingLevel:LoggingLevel,finally:@escaping ReturnsCrawlResults)
    func scraper(_ technique: ParseTechnique, url:URL,  baseURL:URL?, html: String)->ParseResults?
    func incorporateParseResults(pr:ParseResults) throws
    func partFromUrlstr(_ urlstr:URLFromString) -> URLFromString
    func kleenex(_ f:String)->String
    func kleenURLString(_ url:URLFromString )->URLFromString?
    func absorbLink(href:String? , txt:String? ,relativeTo: URL?, tag: String, links: inout [LinkElement])
}
extension BigMachinery {
     func setupController(runman: BigMachineRunner, //context  :Crowdable,
                                exporter:RecordExporter) {
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

    
     func startCrawling(baseURL: URL, configURL:URL,loggingLevel:LoggingLevel,finally:@escaping ReturnsCrawlResults) {
        let (roots,reportParams)  = runman.config.load(url: configURL)
        
        do {
            let lk = ScrapingMachine(scraper:runman.bigMachine.scraper)
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

public final class  CrawlingElement:Codable {
    
    //these are the only elements moved into the output stream
    
    var name:String? = ""
    var artist:String? = ""
    var albumurl:String? = ""
    var songurl:String = ""
    var cover_art_url:String? = ""
    var album : String?  {
        if let alurl = albumurl {
            let blurl = alurl.hasSuffix("/") ? String( alurl.dropLast()  ) : alurl
            if  let aname = blurl.components(separatedBy: "/").last {
                return aname
            }
        }
        return albumurl
    }
}
