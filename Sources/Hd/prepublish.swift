//
//  File.swift
//  
//
//  Created by william donner on 1/14/20.
//

import Foundation
import Publish

// these are pages that are built from swift code that is run before we call Publish...

struct PrePublishing{
    static func allPrePublishingSteps () throws {
        try addBillsFavorites()
        try addBriansFavorites()
    }
    static private func addBillsFavorites() throws {
        
        let links:[Fav] = [
            Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"favorite of all time"),
            Fav(name: "riders",url: "https://billdonner.com/foobly/riders.mp3",comment:"best of the year")
        ]
        
        
        try makeAudioListMarkdown(mode:.fromWithin,  url:"grubber://mumble012/custom/bill/bills-best-2019/",
                                  title:"Bill's Best 2019",
                                  tags:["favorites"],
                                  venue: "favorites",
                                  playdate: "123119",
                                  links:links)
        
        print("[crawler] adding Bills Favorites")
    }
    static private func addBriansFavorites() throws{
        let links = [
            Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"not exactly my taste"),
            
            
            Fav(name: "riders",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"I like the drumming")
        ]
        
        
        try  makeAudioListMarkdown(mode:.fromWithin, url:"grubber://mumble012/custom/brian/brians-favorites-2018/", title:"Brian's Favorites 2018",     tags:["favorites"],
                                   venue: "favorites",
                                   playdate: "123118",
                                   links:links)
        print("[crawler] adding Brians Favorites")
    }
}
//MARK: - These pages are built with Plot and then AddPage

extension PublishingStep where Site == Hd {
    static func allsteps () throws -> [PublishingStep<Hd>] {
     return [try makeTestPageStep(), try makeMembersPageStep(),addSectionTitlesStep()]
    }
    static func makeTestPageStep ( ) throws -> Self {
        return PublishingStep<Hd>.addPage(Page(path:"/test",
                                               content: Content(title:"test test", description:"this is just a test" )))
    }
    static func makeMembersPageStep ( ) throws -> Self {
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
