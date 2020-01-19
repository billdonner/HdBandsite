//
//  makeAudioListMarkdown.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Plot
import Kanna



struct BannerAndTags {
    let banner: String
    let tags:[String]
}
struct Shredded {
    let letters: String
    let digits:String
}

struct Audio {
    static private func buildAudioBlock(idx:Int,alink:Fav)->String {
        let pext = (alink.url.components(separatedBy: ".").last ?? "fail").lowercased()
        if isAudioExtension(pext){
            let div = Node.div(
                .h2("\(String(format:"%02d",idx+1))    \(alink.name)"),
                .figure(
                    .figcaption(.text(alink.comment)),
                    .audio(.controls(true), .source(.src(alink.url), .type((pext == "mp3") ? .mp3:.wav))))
            )
            return  div.render()
        }
        else {
            return    ""
        }
    }
      static private func generateAudioHTMLFromRemoteDirectoryAssets(links:[Fav]) -> String {
        var outbuf = ""
        for(idx,alink) in links.enumerated() {
            outbuf += buildAudioBlock(idx: idx,alink: alink)
        }
        return outbuf
    }
    
    
      static private func generateAudioTopMdHTML(title:String,u sourceurl:URL, venue:String,playdate:String,tags:[String] ,links:[Fav])->String {
        
        let immd = ImagesAndMarkdown.generateImagesAndMarkdownFromRemoteDirectoryAssets(links:links)
        let cookie = get_fortune_cookie()
        func topdiv()-> Node<HTML.BodyContext>  {
            
            
            return Node.div ( .div(
                .img(.src("\(immd.images[0])"), .class("img300"),
                     .alt("\(immd.markdown.prefix(50))")),
                .h4 ( .i ("\(cookie)")),
                .p("\(immd.markdown)"))
            )
        }
        // it seems essential to put the title in here instead of inside the plot Node above
        func   markdownmetadata()-> String {
            let ellipsis = immd.markdown.count>500 ? "..." : ""
            return """
            ---
            sourceurl: \(sourceurl.absoluteString)
            venue: \(venue)
            description: \(cookie) \(immd.markdown.prefix(500))\(ellipsis)
            tags: \(tags.joined(separator: ","))
            ---
            
            # \(title)
            
            
            """
        }
        
        return markdownmetadata() + "\(topdiv().render())"
    }
    
    // this variation uses venu and playdate to form a title
    static func makeAudioListMarkdown(mode:PublishingMode,
                               url aurl: String,
                               title:String,
                               tags:[String],
                               venue:String,
                               playdate:String,
                               links:[Fav] ) throws {
        
        
        func checkForBonusTags(name:String?)->String? {
            if let songName = name {
                let shorter = songName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                for tuneTag in Hd.crawlerKeyTags {
                    if shorter.hasPrefix(tuneTag) {
                        return tuneTag
                    }
                }
            }
            return nil
        }
        
        func makeAndWriteMdFile(_ title:String, stuff:String,spec:String) throws {
            let markdownData: Data? = stuff.data(using: .utf8)
            try markdownData!.write(to:URL(fileURLWithPath:  spec,isDirectory: false))
        }
        
        
        var moretags:Set<String>=[]
        for link in links {
            if  let bonustag = checkForBonusTags(name: link.name )  {
                moretags.insert(bonustag)
            }
        }
        if links.count == 0 { print("[crawler] no links for \(title) - check your music tree") }
        else {
            
            let x=makeBannerAndTags(aurl:aurl , mode: mode)
            
            
            var spec: String
            switch  mode {
            case  .fromPublish :
                spec =  "\(Hd.pathToContentDir)/audiosessions/\(venue)\(playdate).md"
            case  .fromWithin :
                spec =  "\(Hd.pathToContentDir)/favorites/\(title).md"
            }
            guard let u = URL(string:aurl) else { return }
            let stuff =  generateAudioMarkdownPage(x.banner,
                                                   u:u,
                                                   venue: venue ,
                                                   playdate:playdate,
                                                   tags:Array(moretags) + x.tags
                                                    + tags ,
                                                   links:links,
                                                   mode:mode)
            try makeAndWriteMdFile(title,  stuff: stuff, spec: spec)
        }
    }
    
      static private func generateAudioMarkdownPage(_ title:String,u:URL,venue:String ,playdate:String,tags:[String]=[],links:[Fav]=[],
                                               mode:PublishingMode )->String {
        var newtags = tags
        switch mode {
        case .fromPublish:
            break
        case .fromWithin:
            newtags.append("favorite")
        }
        
        return  generateAudioTopMdHTML(title:title,u:u,venue:venue,playdate:playdate,tags:newtags,links:links)
            + "\n\n\n\n"
            + generateAudioHTMLFromRemoteDirectoryAssets(links: links)
    }
    
}// struct audio