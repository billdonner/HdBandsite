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
 
    static let bandfacts = BandSiteParams(
        venueShort: "thorn",
    venueLong: "Highline Studios, Thornwood, NY",
    crawlTags: ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light"],
    pathToContentDir: "/Users/williamdonner/hd/Content",
    pathToResourcesDir: "/Users/williamdonner/hd",
    matchingURLPrefix: URL(string:"https://billdonner.com/halfdead")!)
}




