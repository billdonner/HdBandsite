//
//  File.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Kanna
func cleanOuputs(outpath:String) {
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
  
extension Hd {
    // generate markdown in a variety of formats as needed
    
    // this is an exmple what dates shoud look like
    // date: 2020-01-05 17:42
    
    struct ImagesAndMarkdown {
        let images: String
        let markdown: String
    }
    private  static func generateHTMLFromRemoteDirectoryAssets(links:[Fav]) -> ImagesAndMarkdown {
        var imagesbuf = ""
        var pmdbuf = "\n"
        for(_,alink) in links.enumerated() {
            let pext = (alink.url.components(separatedBy: ".").last ?? "fail").lowercased()
            if (pext=="md") {
                // copy the bytes inline from remote md file
                if let surl = URL(string:alink.url) {
                    do {
                        pmdbuf +=   try String(contentsOf: surl) + "\n\n\n"
                    }
                    catch {
                        print("[crawler] Couldnt read bytes from \(alink.url) \(error)")
                    }
                }
            } else
                if (pext=="jpg" || pext=="jpeg" || pext=="png"){
                    // if its an image just accumulate them in a gallery
                    imagesbuf += "<img src='\(alink.url)' width='300' />"
            }
        }
        if imagesbuf=="" { imagesbuf = "<img src='/images/abhdlogo300.png' />" }
        return ImagesAndMarkdown(images:imagesbuf,markdown:pmdbuf)
    }
    
    
    private static func generateAudioHTMLFromRemoteDirectoryAssets(links:[Fav]) -> String {
        
        var outbuf = """
       <br/>
        
"""
        for(idx,alink) in links.enumerated() {
            
            let pext = (alink.url.components(separatedBy: ".").last ?? "fail").lowercased()
            if (pext=="mp3" || pext=="wav"){
                let htype = (pext == "mp3") ? "audio/mpeg" : "audio/wav"
                outbuf += """
                \n<h2> \(String(format:"%02d",idx+1))    \(alink.name)</h2>
                <figure>
                <figcaption> \(alink.comment) </figcaption>
                <audio  controls>
                <source src="\(alink.url)" type="\(htype)"/>
                </audio>
                </figure>
                
                """
            }}
        return outbuf
    }
}


extension Hd {
    
    private static  func generateTopMdHTML(title:String, venue:String,playdate:String,tags:[String] ,links:[Fav])->String {
        
        let tagstring = tags.joined(separator: ",")
        
        // this is an exmple what dates shoud look like
        // date: 2020-01-05 17:42
        
        let (year,month,day) = decomposePlayDate(playdate)
        
        var  x = "20" + year
        x +=    "-" + month
        x +=   "-" + day
        
        let cookie = get_fortune_cookie()
        let immd = Self.generateHTMLFromRemoteDirectoryAssets(links:links)
        let ellipsis = immd.markdown.count>500 ? "..." : ""
        let top = """
        
        ---
        venue: \(venue)
        description: \(venue) \(x) \(immd.markdown.prefix(500))\(ellipsis)
        tags: \(tagstring)
        
        
        ---
        
        # \(title)
        
        <div class="modest">
        \(immd.images)
        </div>
        <div class="modest">
        <h4><i>\(cookie)</i></h4>
        </div>
        \(immd.markdown)
        
        """
        
        return top
    }
    
    static func generateAudioMarkdownPage(_ s:String,venue:String ,playdate:String,tags:[String]=[],links:[Fav]=[],
                                          exportMode:ExportMode = .md,
                                          mode:PublishingMode )->String {
        switch exportMode {
            
        case .md:
            var newtags = tags
            switch mode {
            case .fromPublish:
                break
            case .fromWithin:
                newtags.append("favorite")
            }

            return Self.generateTopMdHTML(title:s,venue:venue,playdate:playdate,tags:newtags,links:links)
                + "\n\n\n\n"
                + Self.generateAudioHTMLFromRemoteDirectoryAssets(links: links)
            
        default:fatalError("cant render \(exportMode) as markdown")
        }
    }
}

// this variation uses venu and playdate to form a title
func makeAudioListMarkdown(mode:PublishingMode,
                           url aurl: String,
                           venue:String,
                           playdate:String,
                           links:[Fav] ) throws {
    
    var tags:[String] = []
    func checkForBonusTags(name:String?)->String? {
        
        if let songName = name {
            let shorter = songName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            for tuneTag in Hd.crawlerKeyTags {
                if shorter.hasPrefix(tuneTag) {
                    return tuneTag
                }
            }
        }
        // print("Checked \(String(describing: name)) fail")
        return nil
    }
    
    func makeAndWriteMdFile(_ title:String) throws {
        var moretags:Set<String>=[]
        for link in links {
            if  let bonustag = checkForBonusTags(name: link.name )  {
                moretags.insert(bonustag)
            }
        }
        if links.count == 0 { print("[crawler] no links for \(title) - check your music tree") }
        else {
            
            let stuff = Hd.generateAudioMarkdownPage(title,
                                                     venue: venue ,
                                                     playdate:playdate,
                                                     tags:Array(moretags)
                                                        + tags ,
                                                     links:links,
                                                     mode:mode)
            
            let markdownData: Data? = stuff.data(using: .utf8)
            // create md file with temp
            //session\(String(format:"%011d",mdseqnum)
           // do {
                var spec: String
                switch  mode {
                case  .fromPublish :
                    spec =  "\(crawlerMarkDownOutputPath)/audiosessions/\(venue)\(playdate).md"
                case  .fromWithin :
                    spec =  "\(crawlerMarkDownOutputPath)/specialpages/\(title).md"
                    
                }
                try markdownData!.write(to:URL(fileURLWithPath:  spec,isDirectory: false))
//            } catch {
//                print("Cant write file \(error)")
//            }
        }
    }
    
    /// make some tags from the alburm name
    
    guard let u = URL(string:aurl) else { return }
    // take only the top two parts and use them as
    let parts = u.path.components(separatedBy: "/")
    tags = [parts[1],parts[2]]
    // lets analyze parts3, if it is multispaced then lets call it a gig
    let subparts3 = parts[3].components(separatedBy: " ")
    var performanceKind = ""
    if (subparts3.count > 1) {
        performanceKind = "live"
        tags.append(subparts3[1])
    }
    else  {
        performanceKind = "rehearsal"
    }
    
    var banner:String
    switch mode {
    case .fromPublish:
        // if publish is generating, then use this
        tags.append( performanceKind )
        banner = parts[2] + " \(performanceKind) " + parts[3]
        
    case .fromWithin:
        // if we are generating, call it a favorite
        //tags.append("favorites")
        banner =  parts[3]
    }
    // we actually dont care for the filename, it is autogenerated
   try makeAndWriteMdFile(banner)
    
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
    
    func  incorporateParseResults(pr:ParseResults) throws {
        
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
          
            try makeAudioListMarkdown(mode: .fromPublish, url:aurl,  venue: ve, playdate: String(year+month+day), links:mdlinks )
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

