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
    
    static func meth1(links:[(String,String)]) -> String {
        var method1 = """
       <br/>
        
""" // copy
        for(idx,alink) in links.enumerated() {
            let (name,url) = alink
            let pext = (url.components(separatedBy: ".").last ?? "fail").lowercased()
            if (pext=="mp3" || pext=="wav"){
                let htype = (pext == "mp3") ? "audio/mpeg" : "audio/wav"
                method1 += """
                \n<h2> \(String(format:"%02d",idx+1))    \(name)</h2>
                
                <figure>
                <figcaption> </figcaption>
                <audio  controls style='margin: 0 0 0 5px; background: #B80808;'>
                <source src="\(url)" type="\(htype)"/></audio>
                </figure>
                
                """
            }}
        return method1
    }
    static func renderMarkdown(_ s:String,venue:String ,playdate:String,tags:[String]=[],links:[(String,String)]=[],
                               exportMode:ExportMode = .md )->String {
        func toppart()->String {
        let tagstring = tags.joined(separator: ",")
        var imagesbuf = ""
        var pmdbuf = "\n"  
        for(_,alink) in links.enumerated() {
            let (_,url) = alink
            let pext = (url.components(separatedBy: ".").last ?? "fail").lowercased()
            if (pext=="md") {
                // copy the bytes inline from remote md file
                if let surl = URL(string:url) {
                    do {
                        pmdbuf +=   try String(contentsOf: surl) + "\n\n\n"
                    }
                    catch {
                        print("[crawler] Couldnt read bytes from \(url) \(error)")
                    }
                }
            } else
                if (pext=="jpg" || pext=="jpeg" || pext=="png"){
                    // if its an image just accumulate them in a gallery
                    imagesbuf += "<img src='\(url)' width='300' />"
            }
        }
        if imagesbuf=="" { imagesbuf = "<img src='/images/abhdlogo300.png' />" }
            // this is an exmple what dates shoud look like
            // date: 2020-01-05 17:42
        
            let month = playdate.prefix(2)
            let year = playdate.suffix(2)
            
            let start = playdate.index(playdate.startIndex, offsetBy: 2)
            let end = playdate.index(playdate.endIndex, offsetBy: -2)
            let range = start..<end
 
            let day = playdate[range]
            
            var  x = "20" + year
            x +=    "-" + month
            x +=   "-" + day
            
         //     date: \(date)
            
        //let date = x + " 04:20:00"
        let cookie = get_fortune_cookie()
        let top = """
        
        ---
        venue: \(venue)
        description: \(s)
        tags: \(tagstring)
        
        
        ---
        
        # \(s)
            
        <div style='margin:20px'>
       \(imagesbuf)
      
            <div style='margin:20px'>
            <h4><i>\(cookie)</i></h4>
          </div>
        \(pmdbuf)
        
"""
            
            return top
        }
        
        
        switch exportMode {
        case .md:
            return toppart() + Self.meth1(links: links)
        default:fatalError("cant render \(exportMode) as markdown")
        }
    }
}
//
//  .audio(.controls(true), .source(.src("b.wav"), .type(.wav))),
//

