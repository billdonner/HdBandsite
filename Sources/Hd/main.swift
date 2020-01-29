//
//  File.swift
//  
//
//  Created by william donner on 1/28/20.
//

import Foundation
import Publish
import Plot
import BandSite
import LinkGrubber

  func standardAudioCrawlFuncs() -> LgFuncs {
     return LgFuncs(imageExtensions: ["jpg","jpeg","png"],
                    audioExtensions: ["mp3","mpeg","wav"],
                    markdownExtensions: ["md", "markdown", "txt", "text"],
                    scrapeAndAbsorbFunc: LgFuncs.kannaScrapeAndAbsorb)
 }

let dirpath = "/Users/williamdonner/hd"

let bandfacts = BandSiteFacts(
    venueShort: "thorn",
    venueLong: "Highline Studios, Thornwood, NY",
    crawlTags: ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light"],
    pathToContentDir: dirpath + "/Content",
    pathToOutputDir: dirpath + "/Resources/BigData",
    matchingURLPrefix:  "https://billdonner.com/halfdead" ,
    specialFolderPaths: ["/audiosessions","/favorites"],
    language: Language.english,
    url: "http://abouthalfdead.com",
    name: "About Half Dead ",
    shortname: "ABHD",
    description:"A Jamband Featuring Doors, Dead, ABB Long Form Performances",
    resourcePaths:   ["Resources/HdTheme/hdstyles.css"],
    imagePath:  Path("images/ABHDLogo.png") ,
    favicon:  Favicon(path: "images/favicon.png")
)
    
    // places to test, or simply to use
    func command_rewriter(c:String)->String {
        let rooturl:String
        switch c {
        case "s": rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
        case "m": rooturl =  "https://billdonner.com/halfdead/2019/"
        case "l": rooturl =  "https://billdonner.com/halfdead/"
        default:  rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
        }
        return rooturl
    }
    
// this will run for a bit while crawlinig the internect, it generates .MD files
generateBandSite(bandfacts:bandfacts,rewriter:command_rewriter, lgFuncs: standardAudioCrawlFuncs())

// this publishes a new version of the static website based on the Publish and Plot spm
let _ =  publishBandSite() // turn it over to John Sundell
