//
//  File.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
extension Hd {
    // this is an exmple what dates shoud look like
    // date: 2020-01-05 17:42
    static func renderMarkdown(_ s:String,tags:[String]=[],links:[(String,String)]=[] )->String {
        let date = "\(Date())".dropLast(9)
        let tagstring = tags.joined(separator: ",")
        var imagesbuf = ""
        var pmdbuf = ""
        for(_,alink) in links.enumerated() {
            let (_,url) = alink
            let pext = (url.components(separatedBy: ".").last ?? "fail").lowercased()
            if (pext=="md") {
                // copy the bytes inline
                if let surl = URL(string:url) {
                    do {
                        pmdbuf += try String(contentsOf: surl) + "\n"
                    }
                    catch {
                        print("Couldnt read bytes from \(url) \(error)")
                    }
                }
            } else
                if !(pext=="mp3" || pext=="wav"){
                    //print("Handling pic file \(url)")
                    imagesbuf += "<img src='\(url)' height='300' />"
            }
        }
        if imagesbuf=="" { imagesbuf = "<img src='/images/abhdlogo300.jpg' />" }
        
        var mdbuf = """
        
        ---
        date: \(date)
        description: \(s)
        tags: \(tagstring)
        
        ---
        
        
        
        # \(s)
        
        \(imagesbuf)
        
        \(pmdbuf)
        
        
        tunes played:
        
        """ // copy
        for(idx,alink) in links.enumerated() {
            let (name,url) = alink
            let pext = (url.components(separatedBy: ".").last ?? "fail").lowercased()
            if (pext=="mp3" || pext=="wav"){
                //
                //  .audio(.controls(true), .source(.src("b.wav"), .type(.wav))),
                //
                
                let htype = (pext == "mp3") ? "audio/mpeg" : "audio/wav"
                mdbuf += """
                \n\(String(format:"%02d",idx+1))    [\(name)](\(url))\n
                <figure>
                <figcaption> </figcaption>
                <audio  controls><source src="\(url)" type="\(htype)"/></audio>
                </figure>
                
                """
            }}
        return mdbuf
    }
}
