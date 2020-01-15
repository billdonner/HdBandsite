//
//  transformer.swift
//  
//
//  Created by william donner on 1/15/20.
//

import Foundation
import Kanna

let letters = CharacterSet.letters
let digits = CharacterSet.decimalDigits
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

fileprivate func pickapart(_ phrase:String) -> Shredded {
     
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


final class Transformer:NSObject,BigMachinery{
    

    
    
    var runman : BigMachineRunner!
    var recordExporter : SingleRecordExporter!
    fileprivate var cont = CrawlingElement()
    var exportOptions:ExportMode!
    
    var firstTime = true
    var coverArtUrl : String?
    var artist : String
    
    
    func absorbLink(href:String? , txt:String? ,relativeTo: URL?, tag: String, links: inout [LinkElement]) {
        if let lk = href, //link["href"] ,
            let url = URL(string:lk,relativeTo:relativeTo) ,
            
            let linktype = processExtension(url:url, relativeTo: relativeTo) {
            
            // strip exension if any off the title
            let parts = (txt ?? "fail").components(separatedBy: ".")
            if let ext  = parts.last,  let front = parts.first , ext.count > 0
            {
                let subparts = front.components(separatedBy: "-")
                if let titl = subparts.last {
                    let titw =  titl.trimmingCharacters(in: .whitespacesAndNewlines)
                    links.append(LinkElement(title:titw,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                }
                
            } else {
                // this is what happens upstream
                if  let txt  = txt  {
                    links.append(LinkElement(title:txt,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                }
                
            }
        }
    }// end of absorbLink
    
    func makecsvheader( ) -> String {
        return  "Name,Artist,Album,SongURL,AlbumURL,CoverArtURL"
    }
    func mskecsvtrailer( ) -> String?  {
        return    "==CrawlingContext=="
    }
    func makecsvrow( ) -> String {
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