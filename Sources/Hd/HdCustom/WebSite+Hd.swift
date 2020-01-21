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
        matchingURLPrefix: URL(string:"https://billdonner.com/halfdead")!
    )
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
        return PublishingStep<Hd>.addPage(Page(path:"/about",
                                               content: Content(title:"ABHD Members", description:"The members of ABHD" )))
    }
    
    static func addSectionTitlesStep() -> Self {
        .step(named: "Default section titles") { context in
            context.mutateAllSections { section in
                guard section.title.isEmpty else { return }
                
                switch section.id {
                case .audiosessions:
                    section.title = "Everything Ever Played"
                case .favorites:
                    section.title = "Our Hand-Picked Favorites"
                case .about:
                    section.title = "About the Band"
                case .blog:
                    section.title = "Notes From The Field"
                }
            }
        }
    }
}

// these are pages that are built from swift code that is run before we call Publish...

struct PrePublishing{
    
    static private func addBillsFavorites() throws {
        
        let links:[Fav] = [
            Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"favorite of all time"),
            Fav(name: "riders",url: "https://billdonner.com/foobly/riders.mp3",comment:"best of the year")
        ]
        try AudioSupport(bandfacts: Hd.bandfacts).makeAudioListMarkdown(mode:false,  url:"grubber://mumble012/custom/bill/bills-best-2019/",
                                                                        title:"Bill's Best 2019",
                                                                        tags:["favorites"],
                                                                        p1: "favorites",
                                                                        p2: "123119",
                                                                        links:links)
        
        print("[crawler] adding Bills Favorites")
    }
    static private func addBriansFavorites() throws{
        let links = [
            Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"not exactly my taste"),
            Fav(name: "riders",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"I like the drumming")
        ]
        try  AudioSupport(bandfacts: Hd.bandfacts).makeAudioListMarkdown(mode:false, url:"grubber://mumble012/custom/brian/brians-favorites-2018/",
                                                                         title:"Brian's Favorites 2018",
                                                                         tags:["favorites"],
                                                                         p1: "favorites",
                                                                         p2: "123118",
                                                                         links:links)
        print("[crawler] adding Brians Favorites")
    }
    static func allPrePublishingSteps () ->Int {
        do{
            let funcs : [() throws  ->  ()] = [addBillsFavorites,addBriansFavorites]
            for f in funcs {
                try f()
            }
            return funcs.count
        }
        catch {
            return 0
        }
    }
}

extension SortOrder {
    func makeASorter<T, V: Comparable>(
        forKeyPath keyPath: KeyPath<T, V>
    ) -> (T, T) -> Bool {
        switch self {
        case .ascending:
            return {
                $0[keyPath: keyPath] < $1[keyPath: keyPath]
            }
        case .descending:
            return {
                $0[keyPath: keyPath] > $1[keyPath: keyPath]
            }
        }
    }
}
//MARK: - These pages are built with Plot and then AddPage
extension PublishingContext where Site == Hd  {
    /// Return someitems within this website, sorted by a given key path.
    ///  - parameter max: Max Number of items to return
    /// - parameter sortingKeyPath: The key path to sort the items by.
    /// - parameter order: The order to use when sorting the items.
    
    
    func someItems<T: Comparable>(max:Int,
                                  sortedBy sortingKeyPath: KeyPath<Item<Site>, T>,
                                  order: SortOrder = .ascending
    ) -> [Item<Site>] {
        let items = sections.flatMap { $0.items }
        let x = items.sorted(
            by: order.makeASorter(forKeyPath: sortingKeyPath))
        return x.dropLast(x.count-max)
    }
}
