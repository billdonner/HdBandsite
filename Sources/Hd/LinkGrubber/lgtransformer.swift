
//
//  ManifezzClass: KrawlMaster 
//  UtilityTest
//
//  Created by william donner on 4/19/19.
//

import Foundation
import Kanna

func partFromUrlstr(_ urlstr:URLFromString) -> URLFromString {
    return urlstr//URLFromString(urlstr.url?.lastPathComponent ?? "partfromurlstr failure")
}

func kleenURLString(_ url: URLFromString) -> URLFromString?{
    let original = url.string
    let newer = original.replacingOccurrences(of: "%20", with: "+")
    return URLFromString(newer)
}

    func kleenex(_ f:String)->String {
        return f.replacingOccurrences(of: ",", with: "!")
    }

extension BigMachineRunner {
    
    mutating func setupKrawler( exporter:RecordExporter) { 
        self.recordExporter = exporter
    }

    
    func startCrawling(  configURL:URL,loggingLevel:LoggingLevel,finally:@escaping ReturnsCrawlResults) {
        let (roots)  = self.config.load(url: configURL)
        
        do {
            
            let _ = try OuterCrawler (roots: roots,
                                       loggingLevel: loggingLevel,
                                      bigMachineRunner: self)
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
