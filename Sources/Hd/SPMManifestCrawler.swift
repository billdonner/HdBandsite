
//
//  ManifezzClass: KrawlMaster 
//  UtilityTest
//
//  Created by william donner on 4/19/19.
//

import Foundation
import Kanna
//import SPMCrawlingCore


/**
 {
 "name": "Song Name 3",
 "artist": "Artist Name",
 "album": "Album Name",
 "url": "/song/url.mp3",
 "cover_art_url": "/cover/art/url.jpg",
 "made_up_key": "I'm made up completely"
 }
 */

final public class ManifezzClass: CrawlMeister
{
    
    
    private var whenDone:ReturnsCrawlResults?
    private final class  ManifezzContext:Codable,Crawlable {
        
        func headerReport() -> String { return  "Name,Artist,Album,SongURL,AlbumURL,CoverArtURL" }
        func trailerReport() -> String { return  "==ManifezzContext==" }
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
        
        
        static  func cleanItUp(_ rr:(Crawlable&Codable), kleenex:(String)->(String)) -> String {
            guard let r = rr as?  ManifezzContext  else {
                fatalError()
            }
            let z =
            """
            \(kleenex(r.name ?? "")),\(kleenex(r.artist ?? "")),\(kleenex(r.album ?? "")),\(kleenex(r.songurl)),\(kleenex(r.albumurl ?? "")),\(kleenex(r.cover_art_url ?? ""))
            """
            return z
        }
    }
    
    private final class ManifezzController:NSObject,CustomControllable {
        
        var runman : CustomRunnable!
        var recordExporter : SingleRecordExporter!
        var context : Crowdable!
        
        private var firstTime = true
        private var coverArtUrl : String?
        private var artist : String
        
        required  init(artist:String, defaultArtUrl:String? = nil ) {
            self.coverArtUrl = defaultArtUrl
            self.artist = artist
            super.init()
        }
        deinit  {
            recordExporter.addTrailerToExportStream()
        }
        
        let writemdfiles = true
        var mdsequencenum = 0
        
        var mdlinks : [(String,String)] = []
        
        let tempFolderPath =  "/Users/williamdonner/hd/Content/posts" // NSTemporaryDirectory()
        
        /// add new code to write md files for Publish ing static site
        
        func createMdFile(_ s:String,tags:[String]=[] ) {
            mdsequencenum += 1
            //date: 2020-01-05 17:42
            let date = "\(Date())".dropLast(9)
            let tagstring = tags.joined(separator: ",")
            var mdbuf : String = """
            
            ---
            date: \(date)
            description: \(s)
            tags: \(tagstring)
            ---
            
            # \(s)
            
            tunes played:
            
            """ // copy
            for(idx,alink) in mdlinks.enumerated() {
                let (name,url) = alink
                mdbuf += """
                \n\(String(format:"%02d",idx+1))    [\(name)](\(url))\n
                <figure>
                <figcaption> </figcaption>
                <audio
                controls
                src="\(url)">
                Your browser does not support the
                <code>audio</code> element.
                </audio>
                </figure>
                
                """
            }
            
            
            let cafe: Data? = mdbuf.data(using: .utf8)
            // create md file with temp
            //FileManager.default.createFile(atPath: "\(mdsequencenum).md", contents: cafe, attributes:nil)
            do {
                let spec = "\(tempFolderPath)/\(String(format:"%04d",mdsequencenum)).md"
                try cafe!.write(to:URL(fileURLWithPath:  spec,isDirectory: false))
                //print("Wrote to \(spec)")
            } catch {
                print("Cant write file \(error)")
            }
        }
        
        
        func  incorporateParseResults(pr:ParseResults) {
            
            // move the props into a record
            guard let url = pr.url else { fatalError() }
            
            guard  let cont = context as? ManifezzContext
                else { fatalError() }
            
            mdlinks = []  // must reset each time !!
            
            for link in pr.links {
                let href =  link.href!.absoluteString
                if !href.hasSuffix("/" ) {
                    cont.albumurl = url.absoluteString
                    cont.name = link.title
                    cont.songurl = href
                    cont.artist = artist
                    cont.cover_art_url = self.coverArtUrl
                    mdlinks.append((cont.name ?? "??",cont.songurl))
                    recordExporter.addRowToExportStream()
                }
            }
            if let aurl = cont.albumurl,
                writemdfiles==true {
                /// make some tags from the alburm name
                
                if  let u = URL(string:aurl){
                    // take only the top two parts and use them as
                    let parts = u.path.components(separatedBy: "/")
                    var tags:[String]=[parts[1],parts[2]]
                    tags.append("rehearsal")
                    // we actually dont care for the filename, it is autogenerated
                    createMdFile(parts[2] + " rehearsal " + parts[3], tags:tags)
                }
                else{
                    // print("cant \(String(describing: cont.albumurl))")
                }
            }//writemdfiles==true
        }//createMdFile
        
        func makerow( ) -> String {
            let kleenex = runman.custom.kleenex
            guard context is ManifezzContext
                else { fatalError() }
            return ManifezzContext.cleanItUp(context as! ManifezzContext, kleenex:kleenex)
        }
        
        func makeheader( ) -> String {
            return context.headerReport()
        }
        func maketrailer( ) -> String?  {
            return context.trailerReport()
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
        
        func absorbLink(_ link: Kanna.XMLElement , relativeTo: URL?, tag: String, links: inout [LinkElement]) {
            if let lk = link["href"] ,
                let url = URL(string:lk,relativeTo:relativeTo) {
                let pextension = url.pathExtension.lowercased()
                let hasextension = pextension.count > 0
                let linktype:Linktype = hasextension == false ? .hyperlink:.leaf
                let txt = link.text ?? "-notext-"
                guard url.absoluteString.hasPrefix(relativeTo!.absoluteString) else {
                    return
                }
                
                if hasextension {
                    guard pextension == "mp3" || pextension == "wav" else {
                        return
                        
                    }
                } else
                {
                    //  print("no ext: ", url)
                }
                
                // strip exension if any off the title
                let parts = txt.components(separatedBy: ".")
                if let ext  = parts.last,  let front = parts.first , ext.count > 0
                    // ext.lowercased() == "mp3"
                {
                    let subparts = front.components(separatedBy: "-")
                    if let titl = subparts.last {
                        let titw =  titl.trimmingCharacters(in: .whitespacesAndNewlines)
                        links.append(LinkElement(title:titw,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                    }
                    
                } else {
                    // this is what happens upstream
                    links.append(LinkElement(title:txt,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                    
                }
            }
        }// end of absorbLink
        
        
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
                let doc = try  HTML(html: html, encoding: .utf8)
                title = doc.title ?? "<untitled>"
                
                switch parseTechnique {
                    
                case .parseTop,.parseLeaf:
                    for link in doc.xpath("//a") { //[contains(@class, 'media-object')]
                        
                        absorbLink(link,relativeTo:theURL, tag: "media",links:&links )
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
    
    private final    class ManifezzConfig :Configable {
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
        func configLoader (_ configURL:URL) throws -> ManifezzConfig {
            do {
                let contents =  try Data.init(contentsOf: configURL)
                // inner
                do {
                    let    obj = try JSONDecoder().decode(ManifezzConfig.self, from: contents)
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
        func convertToRootStarts(obj:ManifezzConfig) -> ([RootStart], ReportParams){
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
    
    
    public  func bootCrawlMeister(name:String, baseURL:URL,configURL: URL, opath:String,options:CrawlOptions,whenDone:@escaping ReturnsCrawlResults) throws{
        self.whenDone = whenDone
        let runoptions : RunManagerOptions  = ( options == CrawlOptions.verbose ) ? .verbose : .none
        let ext = URL(string:opath)?.pathExtension ?? OutputType.csv.rawValue
        let outtype = OutputType(value:ext)
        let rm = RunnableStream(config:ManifezzConfig(baseURL),
                                custom: ManifezzController(artist: name),
                                outputFilePath: LocalFilePath(opath),
                                outputType: outtype,
                                runOptions: runoptions )
        
        let _ = try  CrawlingBeast(context:ManifezzContext(),  runman: rm,baseURL: baseURL,  configURL: configURL,options:options,whenDone:whenDone)
    }
}
