//
//  File.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
extension Hd {
    // generate markdown in a variety of formats as neede
    
    // this is an exmple what dates shoud look like
    // date: 2020-01-05 17:42
  private  static func generateHTMLFromImagesAndMarkdown(links:[Fav]) -> (String ,String) {
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
        return (imagesbuf,pmdbuf)
    }
    
    
    private static func generateAudioHTML(links:[Fav]) -> String {
        
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
                <figcaption> </figcaption>
                <audio  controls style='margin: 0 0 0 5px; background: #B80808;'>
                <source src="\(alink.url)" type="\(htype)"/></audio>
                </figure>
                
                """
            }}
        return outbuf
    }
}


extension Hd {

        
   private static  func generateTopMdHTML(title:String, venue:String,playdate:String,tags:[String] ,links:[Fav])->String {
    
    func decomposePlayDate(_ playdate:String) -> (String,String,String) { // month day year ==> year month day
        let month = playdate.prefix(2)
        let year = playdate.suffix(2)
        
        let start = playdate.index(playdate.startIndex, offsetBy: 2)
        let end = playdate.index(playdate.endIndex, offsetBy: -2)
        let range = start..<end
        let day = playdate[range]
        return (String(year),String(month),String(day))
    }
    
    
            let tagstring = tags.joined(separator: ",")
            
            // this is an exmple what dates shoud look like
            // date: 2020-01-05 17:42
            
            let (year,month,day) = decomposePlayDate(playdate)
            
            var  x = "20" + year
            x +=    "-" + month
            x +=   "-" + day
            
            let cookie = get_fortune_cookie()
            let (imagesbuf,pmdbuf) = Self.generateHTMLFromImagesAndMarkdown(links:links)
            let ellipsis = imagesbuf.count>500 ? "..." : ""
            let top = """
            
            ---
            venue: \(venue)
            description: \(venue) \(x) \(pmdbuf.prefix(500))\(ellipsis)
            tags: \(tagstring)
            
            
            ---
            
            # \(title)
            
            <div style='margin:20px'>
            \(imagesbuf)
            
            <div style='margin:20px'>
            <h4><i>\(cookie)</i></h4>
            </div>
            \(pmdbuf)
            
            """
            
            return top
        }
    
        static public func renderMarkdown(_ s:String,venue:String ,playdate:String,tags:[String]=[],links:[Fav]=[],
                                   exportMode:ExportMode = .md )->String {
        switch exportMode {
        case .md:
            return Self.generateTopMdHTML(title:s,venue:venue,playdate:playdate,tags:tags,links:links) + Self.generateAudioHTML(links: links)
        default:fatalError("cant render \(exportMode) as markdown")
        }
    }
}
