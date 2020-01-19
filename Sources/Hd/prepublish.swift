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
    static func allPrePublishingSteps ()throws  ->Int {
        let funcs : [() throws  ->  ()] = [addBillsFavorites,addBriansFavorites]
        for f in funcs {
            try f()
        }
        return funcs.count
    }
    static private func addBillsFavorites() throws {
        
        let links:[Fav] = [
            Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"favorite of all time"),
            Fav(name: "riders",url: "https://billdonner.com/foobly/riders.mp3",comment:"best of the year")
        ]
        try Audio.makeAudioListMarkdown(mode:.fromWithin,  url:"grubber://mumble012/custom/bill/bills-best-2019/",
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
        try  Audio.makeAudioListMarkdown(mode:.fromWithin, url:"grubber://mumble012/custom/brian/brians-favorites-2018/",
                                   title:"Brian's Favorites 2018",
                                   tags:["favorites"],
                                   venue: "favorites",
                                   playdate: "123118",
                                   links:links)
        print("[crawler] adding Brians Favorites")
    }
}
//MARK: - These pages are built with Plot and then AddPage

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


struct ImagesAndMarkdown {
    let images: [String]
    let markdown: String

 static func generateImagesAndMarkdownFromRemoteDirectoryAssets(links:[Fav]) -> ImagesAndMarkdown {
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
            if isImageExtension(pext) {
                // if its an image just accumulate them in a gallery
                images.append(alink.url)
        }
    }
    if images.count == 0  {
        images.append( "/images/abhdlogo300.png")
    }
    return ImagesAndMarkdown(images:images,markdown:pmdbuf)
}

}
