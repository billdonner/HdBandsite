//
//  makeAudioListMarkdown.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Plot
import LinkGrubber

struct Audio {
    private var bandfacts:BandSiteParams
    init(bandfacts:BandSiteParams)
    {
        self.bandfacts = bandfacts
    }
    struct BannerAndTags {
        let banner: String
        let tags:[String]
    }
  private func buildAudioBlock(idx:Int,alink:Fav)->String {
        let pext = (alink.url.components(separatedBy: ".").last ?? "fail").lowercased()
    if LgFuncs.isAudioExtension(pext){
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
     private func generateAudioHTMLFromRemoteDirectoryAssets(links:[Fav]) -> String {
        var outbuf = ""
        for(idx,alink) in links.enumerated() {
            outbuf += buildAudioBlock(idx: idx,alink: alink)
        }
        return outbuf
    }
    
    
    private func generateAudioTopMdHTML(title:String,u sourceurl:URL, venue:String,playdate:String,tags:[String] ,links:[Fav])->String {
        
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
    func makeAudioListMarkdown(mode:Bool, // true means from Publish
                               url aurl: String,
                               title:String,
                               tags:[String],
                               p1 venue:String,
                               p2 playdate:String,
                               links:[Fav] ) throws {
        
        
        func checkForBonusTags(name:String?)->String? {
            if let songName = name {
                let shorter = songName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                for tuneTag in  bandfacts.crawlTags {
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
            case  true :
                spec =  "\( bandfacts.pathToContentDir)/audiosessions/\(venue)\(playdate).md"
            case false  :
                spec =  "\( bandfacts.pathToContentDir)/favorites/\(title).md"
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
     private func generateAudioMarkdownPage(_ title:String,u:URL,venue:String ,playdate:String,tags:[String]=[],links:[Fav]=[],
                                               mode:Bool )->String {
        var newtags = tags
        switch mode {
        case true:
            break
        case false :
            newtags.append("favorite")
        }
        
        return  generateAudioTopMdHTML(title:title,u:u,venue:venue,playdate:playdate,tags:newtags,links:links)
            + "\n\n\n\n"
            + generateAudioHTMLFromRemoteDirectoryAssets(links: links)
    }

    /// make some tags  and banner from the alburm name
   private func makeBannerAndTags(aurl:String,mode:Bool)->BannerAndTags {
        guard let u = URL(string:aurl) else { fatalError() }
        // take only the top two parts and use them as
        
        let parts = u.path.components(separatedBy: "/")
        var tags = [parts[1],parts[2]]
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
        case true:
            // if publish is generating, then use this
            tags.append( performanceKind )
            banner = parts[2] + " \(performanceKind) " + parts[3]
            
        case false:
        
            banner =  parts[3]
        }
        
        return BannerAndTags(banner: banner , tags: tags )
    }

}// struct audio
