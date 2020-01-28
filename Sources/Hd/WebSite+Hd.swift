//
//  Website.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Publish
import Plot
import GigSiteAudio
import LinkGrubber


// Standard BandSite Stuff

// This type acts as the configuration for your website.
// On top of John Sundell's configuration, we have everything else that's needed for LinkGrubber, etc



// open class
public struct Hd: Website {
     public static var bandfacts: BandSiteFacts!
    // public static var xlgFuncs: LgFuncs!
    
    public static func setup(_ bf:BandSiteFacts){//}, lgFuncs lf:LgFuncs){
        bandfacts = bf
       // xlgFuncs = lf
    }

    public enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case about
        case favorites
        case audiosessions
        case blog
    }
    
   public  struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        // var flotsam : TimeInterval = 0
        //var venue: String?
        //var date: String?
        var sourceurl: String?
    }
    
    // Update these properties to configure your website:
   public var url =  URL(string:bandfacts.url)!
   public  var name =  bandfacts.name// + "\(Date())".dropLast(14)
   public  var description =  bandfacts.description
   public  var language =  bandfacts.language
   public   var imagePath =   bandfacts.imagePath
   public   var favicon =  bandfacts.favicon
  
}


extension Hd {
    public static func publisher() ->Int {
        do {
        let (steps,stepcount) = try PublishingStep<Hd>.allsteps()
                   try Hd().publish(withTheme: .hd, additionalSteps:steps)
            return stepcount
        }
        catch {
            print("[crawler] could not publish \(error)")
            return 0
        }
    }
   static func bandSiteRunCrawler (_ roots:[RootStart],finally:@escaping (Int)->()) {

        let pmf = AudioHTMLSupport(bandfacts: bandfacts,
                          lgFuncs: lgFuncs ).audioListPageMakerFunc
    
        let _ = AudioCrawler(roots:roots,
                        verbosity:  .none,
                        lgFuncs: lgFuncs,
                        pageMaker: pmf,
                        bandSiteParams: bandfacts) { status in // just runs
                            
                            
                        finally(status)
        }
    }
}

extension PublishingStep where Site == Hd {
    static var madePageCount = 0
    static func allsteps () throws -> ([PublishingStep<Hd>],Int) {
        return ([try makeTestPageStep(), try makeMembersPageStep(),addSectionTitlesStep()],madePageCount)
    }
    static func makeTestPageStep ( ) throws -> Self {
        madePageCount += 1
        return PublishingStep<Hd>.addPage(Page(path:"/test",
                                               content: Content(title:"test test", description:"this is just a test" )))
    }
    static func makeMembersPageStep ( ) throws -> Self {
        madePageCount += 1
        let x = Hd.bandfacts!
        return PublishingStep<Hd>.addPage(Page(path:"/about",
                                               content: Content(title:x.titleForMembersPage, description:x.description )))
    }
    static func addSectionTitlesStep() -> Self {
        .step(named: "Default section titles") { context in
            context.mutateAllSections { section in
                guard section.title.isEmpty else { return }
                
                switch section.id {
                case .audiosessions:
                    section.title = Hd.bandfacts!.titleForAudioSessions
                case .favorites:
                    section.title = Hd.bandfacts!.titleForFavoritesSection
                case .about:
                    section.title = Hd.bandfacts!.titleForMembersPage
                case .blog:
                    section.title = Hd.bandfacts!.titleForBlog
                }
            }
        }
    }
}



public typealias IndexPageSig = (Index,PublishingContext<Hd>) throws -> HTML
public typealias GeneralPageSig = (Page,PublishingContext<Hd>) throws -> HTML



open class BandSiteFacts:BandSiteHTMLProt&FileSiteProt {
    
    public var artist : String
    public var venueShort : String
    public var venueLong : String
    public var crawlTags:[String]
    public var pathToContentDir : String
    public var pathToResourcesDir : String
    public var pathToOutputDir: String
    public var matchingURLPrefix : String
    public var specialFolderPaths: [String]
    public var language : Language
    public var url : String
    public var name : String
    public var shortname: String
    public var titleForAudioSessions: String
    public var titleForFavoritesSection: String
    public var titleForBlog: String
    public var titleForMembersPage: String
    public var resourcePaths:Set<Path>
    public var description : String
    public var topNavStuff:Node<HTML.BodyContext>
    public var indexUpper :Node<HTML.BodyContext>
    public var indexLower:Node<HTML.BodyContext>
    public var memberPageFull:Node<HTML.BodyContext>
    public var allFavorites: [Node<HTML.BodyContext>]
    public var imagePath : Path?
    public var favicon: Favicon?
    
    public init(
        artist : String = "",
        venueShort : String = "",
        venueLong : String  = "",
        crawlTags:[String]  = [],
        pathToContentDir : String = "",
        pathToOutputDir : String = "",
        pathToResourcesDir: String = "",
        matchingURLPrefix :String = "",
        specialFolderPaths :[String] = [],
        language : Language = .english,
        url : String = "",
        name : String = "",
        shortname : String = "",
        description : String = "",
        titleForAudioSessions: String = "",
        titleForFavoritesSection: String = "",
        titleForBlog: String = "",
        titleForMembersPage: String = "",
        resourcePaths: Set<Path> = [],
        indexUpper: Node<HTML.BodyContext>,
        indexLower: Node<HTML.BodyContext>,
        memberPageFull: Node<HTML.BodyContext>,
        topNavStuff:Node<HTML.BodyContext>,
        allFavorites: [Node<HTML.BodyContext>],
        
        imagePath : Path? = nil,
        favicon:Favicon? = nil
    ){
        self.artist = artist
        self.venueShort = venueShort
        self.venueLong = venueLong
        self.crawlTags = crawlTags
        self.pathToContentDir = pathToContentDir
        self.pathToOutputDir = pathToOutputDir
        self.pathToResourcesDir = pathToResourcesDir
        self.matchingURLPrefix = matchingURLPrefix
        self.specialFolderPaths = specialFolderPaths
        self.language = language
        self.url = url
        self.name = name
        self.shortname = shortname
        self.titleForAudioSessions = titleForAudioSessions
        self.titleForFavoritesSection = titleForFavoritesSection
        self.titleForBlog = titleForBlog
        self.titleForMembersPage = titleForMembersPage
        self.resourcePaths = resourcePaths
        self.description = description
        self.indexUpper = indexUpper
        self.indexLower = indexLower
        self.memberPageFull = memberPageFull
        self.topNavStuff = topNavStuff
        self.allFavorites = allFavorites
        self.imagePath = imagePath
        self.favicon = favicon
        //
    }
    
}





public typealias CrawlingSignature =  ([RootStart] , @escaping (Int)->()) -> ()


