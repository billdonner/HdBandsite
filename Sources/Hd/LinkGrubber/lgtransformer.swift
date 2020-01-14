
//
//  ManifezzClass: KrawlMaster 
//  UtilityTest
//
//  Created by william donner on 4/19/19.
//

import Foundation
import Kanna


fileprivate func cleanOuputs(outpath:String) {
    do {
        // clear the output directory
        let fm = FileManager.default
                var counter = 0
        for folder in ["/specialpages","/audiosessions"] {
        
        let dir = URL(fileURLWithPath:outpath+folder)

        let furls = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        for furl in furls {
            try fm.removeItem(at: furl)
            counter += 1
        }
        }
        print("[crawler] Cleaned \(counter) files from ", outpath )
    }
    catch {print("[crawler] Could not clean outputs \(error)")}
}

/// add new code to write md files for Publish ing static site
public enum PublishingMode {
    case fromPublish
    case fromWithin
}


 protocol BigMachinery : class  {
    var runman: BigMachineRunner! { get set }
    var recordExporter : SingleRecordExporter!{ get set }
    func makerow() -> String
    func makeheader()->String
    func maketrailer()->String?
    
   // var context : Crowdable!{ get set }
    func setupController(runman: BigMachineRunner,// context  :Crowdable,
                         exporter:SingleRecordExporter)
    func startCrawling(baseURL: URL, configURL:URL,loggingLevel:LoggingLevel,finally:@escaping ReturnsCrawlResults)
    func scraper(_ technique: ParseTechnique, url:URL,  baseURL:URL?, html: String)->ParseResults?
    func incorporateParseResults(pr:ParseResults)
    func partFromUrlstr(_ urlstr:URLFromString) -> URLFromString
    func kleenex(_ f:String)->String
    func kleenURLString(_ url:URLFromString )->URLFromString?
    func absorbLink(href:String? , txt:String? ,relativeTo: URL?, tag: String, links: inout [LinkElement])
}
extension BigMachinery {
     func setupController(runman: BigMachineRunner, //context  :Crowdable,
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

    
     func startCrawling(baseURL: URL, configURL:URL,loggingLevel:LoggingLevel,finally:@escaping ReturnsCrawlResults) {
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




private final class  CrawlingElement:Codable {
    
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


final class Transformer:NSObject,BigMachinery{
    
    let letters = CharacterSet.letters
     let digits = CharacterSet.decimalDigits
    
    
    var runman : BigMachineRunner!
    var recordExporter : SingleRecordExporter!
    fileprivate var cont = CrawlingElement()
    var exportOptions:ExportMode!
    
    var firstTime = true
    var coverArtUrl : String?
    var artist : String
    
    func makeheader( ) -> String {
        return  "Name,Artist,Album,SongURL,AlbumURL,CoverArtURL"
    }
    func maketrailer( ) -> String?  {
        return    "==CrawlingContext=="
    }
    func makerow( ) -> String {
        func cleanItUp(_ r:CrawlingElement, kleenex:(String)->(String)) -> String {
            let z =
            """
            \(kleenex(r.name ?? "")),\(kleenex(r.artist ?? "")),\(kleenex(r.album ?? "")),\(kleenex(r.songurl)),\(kleenex(r.albumurl ?? "")),\(kleenex(r.cover_art_url ?? ""))
            """
            return z
        }
        return  cleanItUp(cont, kleenex:kleenex)
    }
    
    required  init(artist:String, defaultArtUrl:String? = nil, exportOptions:ExportMode = .csv ) {
        self.coverArtUrl = defaultArtUrl
        self.artist = artist
        self.exportOptions = exportOptions
        super.init()
        cleanOuputs(outpath: crawlerMarkDownOutputPath)
        
    }
    deinit  {
        recordExporter.addTrailerToExportStream()
    }
    
    func  incorporateParseResults(pr:ParseResults) {
        
        var mdlinks : [Fav] = []  // must reset each time !!
        // move the props into a record
        guard let url = pr.url else { fatalError() }
        // regardless of the type of export
        // var name:String = "no links!"
        
        
        for link in pr.links {
            let href =  link.href!.absoluteString
            if !href.hasSuffix("/" ) {
                cont.albumurl = url.absoluteString
                cont.name = link.title
                cont.songurl = href
                cont.artist = artist
                cont.cover_art_url = self.coverArtUrl
                mdlinks.append(Fav(name:cont.name ?? "??", url:cont.songurl,comment:""))
                recordExporter.addRowToExportStream()
            }
        }
        
        // if we are writing md files for Publish
        if let aurl = cont.albumurl,
            exportOptions == .md {
            // figure out venue and playdate from the url
     
            let fund = url.lastPathComponent
            let shredded = pickapart(fund)
            let playdate = shredded.digits
            let venue = shredded.letters
            
                        guard playdate != "" else {return}
            
            let ve =  venue == "" ? Hd.default_venue_acronym : venue
                       let month = playdate.prefix(2)
                       let year = playdate.suffix(2)
                       
                       let start = playdate.index(playdate.startIndex, offsetBy: 2)
                       let end = playdate.index(playdate.endIndex, offsetBy: -2)
                   
                       let day = playdate[start..<end]
                        
            // when naming the file, put the date part first and then the venu, the date is YYMMDD for sorting
          
            createMarkDown(mode: .fromPublish, url:aurl,  venue: ve, playdate: String(year+month+day), links:mdlinks )
        }//writemdfiles==true
    }//incorporateParseResults
    struct Shredded {
        let letters: String
        let digits:String
    }
    
    func pickapart(_ phrase:String) -> Shredded {
 

        var letterCount = 0
        var digitCount = 0
        var lets:String = ""
        var digs:String = ""

        for uni in phrase.unicodeScalars  {
            if letters.contains(uni) {
                letterCount += 1
                lets += String(uni)
            } else if digits.contains(uni) {
                digitCount += 1
                digs += String(uni)
            }
        }
    
        return Shredded(letters:lets, digits:digs)
        
    }
    
    func scraper(_ parseTechnique:ParseTechnique, url theURL:URL,
                 baseURL:URL?, html: String)   -> ParseResults? {
        
        var title: String = ""
        var links : [LinkElement] = []
        
        guard theURL.absoluteString.hasPrefix(baseURL!.absoluteString) else
        {
            return nil
        }
        // starts here
        if firstTime {
            recordExporter.addHeaderToExportStream()
            firstTime = false
        }
        
        
        do {
            assert(html.count != 0 , "No html to parse")
            let doc = try  Kanna.HTML(html: html, encoding: .utf8)
            title = doc.title ?? "<untitled>"
            
            switch parseTechnique {
                
            case .parseTop,.parseLeaf:
                for link in doc.xpath("//a") {
                    absorbLink(href:link["href"],txt:link.text,relativeTo:theURL, tag: "media",links:&links )
                }
                
            case .indexDir:
                fatalError("forcedFailure induced")
                break;
            case .passThru:
                fatalError("forcedFailure induced")
            }
        }
        catch {
            print("cant parse error is \(error)")
            return  ParseResults(url: theURL, baseurl:baseURL, technique: parseTechnique,
                                 status: .failed(code: 0), pagetitle:title,
                                 links: links, props: [], tags: [])
        }
        
        return  ParseResults(url: theURL, baseurl:baseURL, technique: parseTechnique,
                             status: .succeeded, pagetitle: title,
                             links: links, props:[], tags: [])
    }
}

