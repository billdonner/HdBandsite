//
//  File.swift
//  
//
//  Created by william donner on 1/14/20.
//

import Foundation

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
        
        
        try  makeAudioListMarkdown(mode:.fromWithin, url:"grubber://mumble012/custom/brian/brians-favorites-2018/",
                                   venue: "favorites",
                                   playdate: "123118",
                                   links:links)
        print("[crawler] adding Brians Favorites")
    }
}
