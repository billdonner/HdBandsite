//
//  File.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Plot
import Kanna

struct ImagesAndMarkdown {
    let images: [String]
    let markdown: String
}

struct BannerAndTags {
    let banner: String
    let tags:[String]
}
struct Shredded {
    let letters: String
    let digits:String
}


/// make some tags  and banner from the alburm name
fileprivate func makeBannerAndTags(aurl:String,mode:PublishingMode)->BannerAndTags {
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
    case .fromPublish:
        // if publish is generating, then use this
        tags.append( performanceKind )
        banner = parts[2] + " \(performanceKind) " + parts[3]
        
    case .fromWithin:
        // if we are generating, call it a favorite
        //tags.append("favorites")
        banner =  parts[3]
    }
    
    return BannerAndTags(banner: banner , tags: tags )
}

fileprivate func generateImagesAndMarkdownFromRemoteDirectoryAssets(links:[Fav]) -> ImagesAndMarkdown {
    var images: [String] = []
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
                
                images.append(alink.url)
        }
    }
    if images.count == 0  {
        images.append( "/images/abhdlogo300.png")
    }
    return ImagesAndMarkdown(images:images,markdown:pmdbuf)
}


fileprivate func buildAudioBlock(idx:Int,alink:Fav)->String {
    let pext = (alink.url.components(separatedBy: ".").last ?? "fail").lowercased()
    if (pext=="mp3" || pext=="wav"){
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
fileprivate func generateAudioHTMLFromRemoteDirectoryAssets(links:[Fav]) -> String {
    var outbuf = ""
    for(idx,alink) in links.enumerated() {
        outbuf += buildAudioBlock(idx: idx,alink: alink)
    }
    return outbuf
}


fileprivate func generateAudioTopMdHTML(title:String,u sourceurl:URL, venue:String,playdate:String,tags:[String] ,links:[Fav])->String {
    
    let immd = generateImagesAndMarkdownFromRemoteDirectoryAssets(links:links)
    
    func topdiv()-> Node<HTML.BodyContext>  {
        let cookie = get_fortune_cookie()
        
        return Node.div ( .div(
            .h1("\(title)"),
            .img(.src("\(immd.images[0])"), .class("img300"),
                 .alt("\(immd.markdown.prefix(50))")),
            .h4 ( .i ("\(cookie)")),
            .p("\(immd.markdown)"))
        )
    }
    
    func markdownmetadata() -> String {
        let ellipsis = immd.markdown.count>500 ? "..." : ""
        return """
        ---
        sourceurl: \(sourceurl.absoluteString)
        venue: \(venue)
        description: \(venue) \(playdate) \(immd.markdown.prefix(500))\(ellipsis)
        tags: \(tags.joined(separator: ","))
        ---
        """
    }
    
    return markdownmetadata() + "\(topdiv().render())"
}

// this variation uses venu and playdate to form a title
func makeAudioListMarkdown(mode:PublishingMode,
                           url aurl: String,
                           venue:String,
                           playdate:String,
                           links:[Fav] ) throws {
    
    func makeAndWriteMdFile(_ title:String,tags:[String],u:URL) throws {
        var moretags:Set<String>=[]
        for link in links {
            if  let bonustag = checkForBonusTags(name: link.name )  {
                moretags.insert(bonustag)
            }
        }
        if links.count == 0 { print("[crawler] no links for \(title) - check your music tree") }
        else {
            
            var spec: String
            switch  mode {
            case  .fromPublish :
                spec =  "\(crawlerMarkDownOutputPath)/audiosessions/\(venue)\(playdate).md"
            case  .fromWithin :
                spec =  "\(crawlerMarkDownOutputPath)/specialpages/\(title).md"
            }
            let stuff =  generateAudioMarkdownPage(title,
                                                     u:u,
                                                     venue: venue ,
                                                     playdate:playdate,
                                                     tags:Array(moretags)
                                                        + tags ,
                                                     links:links,
                                                     mode:mode)
            
            let markdownData: Data? = stuff.data(using: .utf8)
            try markdownData!.write(to:URL(fileURLWithPath:  spec,isDirectory: false))
            
        }
    }
    
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
    
    // we actually dont care for the filename, it is autogenerated
    guard let u = URL(string:aurl) else { return }
    let x=makeBannerAndTags(aurl:aurl , mode: mode)
    try makeAndWriteMdFile(x.banner ,tags:x.tags,u: u)
    
}

func generateAudioMarkdownPage(_ s:String,u:URL,venue:String ,playdate:String,tags:[String]=[],links:[Fav]=[],
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
        
        return  generateAudioTopMdHTML(title:s,u:u,venue:venue,playdate:playdate,tags:newtags,links:links)
            + "\n\n\n\n"
            + generateAudioHTMLFromRemoteDirectoryAssets(links: links)
        
    default:fatalError("cant render \(exportMode) as markdown")
    }
}
