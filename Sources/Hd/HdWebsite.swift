//
//  Website.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Publish
import Plot
import Kanna



// This type acts as the configuration for your website.
// On top of John Sundell's configuration, we have everything else that's needed for LinkGrubber, etc

struct Hd: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        
        case about
        case favorites
        case audiosessions
        case blog
    }
    
    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        // var flotsam : TimeInterval = 0
        //var venue: String?
        //var date: String?
        var sourceurl: String?
    }
    
    // Update these properties to configure your website:
    var url = URL(string: "http://abouthalfdead.com")!
    var name = "About Half Dead " // + "\(Date())".dropLast(14)
    var description = "A Jamband Featuring Doors, Dead, ABB Long Form Performances"
    var language: Language { .english }
    var imagePath: Path? { "images/ABHDLogo.png" }
    var favicon: Favicon?  { Favicon(path: "images/favicon.png")}
 
}





//MARK: - pass thru the music and art files, only
extension Transformer {
    func processExtension(url:URL,relativeTo:URL?)->Linktype?{
        let pext = url.pathExtension.lowercased()
        let hasextension = pext.count > 0
        let linktype:Linktype = hasextension == false ? .hyperlink:.leaf
        guard url.absoluteString.hasPrefix(relativeTo!.absoluteString) else {
            return nil
        }
        
        if hasextension {
            guard isImageExtension(pext) || isAudioExtension(pext) else {
                return nil
            }
            if isImageExtension(pext) || isMarkdownExtension(pext) {
                print("Processing \(pext) file from \(url)")
            }
        } else
        {
            //  print("no ext: ", url)
        }
        return linktype
    }
    
    //MARK: - cleanup special folders for this site
    func cleanOuputs(outpath:String) {
        do {
            // clear the output directory
            let fm = FileManager.default
            var counter = 0
            for folder in ["/favorites","/audiosessions"] {
                
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
}
// MARK:- CSV
extension Transformer {
    

    
}


/// make some tags  and banner from the alburm name
func makeBannerAndTags(aurl:String,mode:PublishingMode)->BannerAndTags {
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
    
        banner =  parts[3]
    }
    
    return BannerAndTags(banner: banner , tags: tags )
}
