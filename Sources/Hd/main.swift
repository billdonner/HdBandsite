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
import HTMLExtractor

let LOGGING_LEVEL = LoggingLevel.none

let dirpath = "/Users/williamdonner/hd"

let bandfacts = BandInfo(
    crawlTags: ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light","love"],
    pathToContentDir: dirpath + "/Content",
    pathToOutputDir: dirpath + "/Resources/BigData",
    matchingURLPrefix:  "https://billdonner.com/halfdead" ,
    specialFolderPaths: ["/audiosessions","/favorites"],
    shortname: "ABHD"  
 
)
  // This type acts as the configuration for your bandsite.
  // On top of John Sundell's configuration, we have everything else that's needed for LinkGrubber, etc
   
public struct Hd: Website {

    
      public enum SectionID: String, WebsiteSectionID {
          // Add the sections that you want your website to contain here:
          case about
          case favorites
          case audiosessions
          case blog
      }
      
      public  struct ItemMetadata: WebsiteItemMetadata {
    
          var sourceurl: String?
      }
      // Update these properties to configure your website:
      public var url =  URL(string:"http://abouthalfdead.com")!
      public var name =  "About Half Dead"
      public var description =  "A Jamband Featuring Doors, Dead, ABB Long Form Performances"
      public var language =      Language.english
      public var imagePath: Path? {"images/ABHDLogo.png"}
      public var favicon =  Favicon(path: Path( "images/favicon.png"))
  }


public struct  FileTypeFuncs:BandSiteProt {
    
    
    public init() {}
    
    
    public func pageMakerFunc(_ props: CustomPageProps, _ links: [Fav]) throws {
       let _    = try AudioHTMLSupport(bandinfo: bandfacts,
                                   lgFuncs: self ).audioListPageMakerFunc(props:props,links:links)
    }
    
    public func matchingFunc(_ u: URL) -> Bool {
        return  u.absoluteString.hasPrefix(bandfacts.matchingURLPrefix)
    }
    
    public func scrapeAndAbsorbFunc ( theURL:URL, html:String ) throws ->  ScrapeAndAbsorbBlock {
        let x   = HTMLExtractor.extractFrom (  html:html )
        return HTMLExtractor.converttoScrapeAndAbsorbBlock(x,relativeTo:theURL)
    }

    public func isImageExtensionFunc (_ s:String) -> Bool {
         ["jpg","jpeg","png"].includes(s)
     }

    public func isAudioExtensionFunc(_ s:String) -> Bool {
        ["mp3","mpeg","wav"].includes(s)
    }
    public func isMarkdownExtensionFunc(_ s:String) -> Bool{
        ["md", "markdown", "txt", "text"].includes(s)
    }
    public func isNoteworthyExtensionFunc(_ s: String) -> Bool {
        isImageExtensionFunc(s) || isMarkdownExtensionFunc(s)
    }
   public  func isInterestingExtensionFunc (_ s:String) -> Bool {
        isImageExtensionFunc(s) || isAudioExtensionFunc(s)
    }
}

 // places to test, or simply to use
    func command_rewriter(c:String)->URL {
        let rooturl:String
        switch c {
        case "s": rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
        case "m": rooturl =  "https://billdonner.com/halfdead/2019/"
        case "l": rooturl =  "https://billdonner.com/halfdead/"
        default:  rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
        }
        let url = URL(string:rooturl)
        guard let nrl  = url else { print("bad roourl \(rooturl)"); exit(0)}
        return nrl
    }
    
// this will run for a bit while crawlinig the internect, it generates .MD files
 
generateBandSite(bandinfo:bandfacts,rewriter:command_rewriter, lgFuncs: FileTypeFuncs(), logLevel: LOGGING_LEVEL)

// this publishes a new version of the static website based on the Publish and Plot spm
let _ =  publishBandSite() // turn it over to John Sundell
