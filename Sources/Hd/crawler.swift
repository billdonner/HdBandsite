//
//  cli.swift
//  
//
//  Created by william donner on 1/16/20.
//

import Foundation
import Publish 

// tweak
func Crawler(_ configurl: URL, _ opath: String, _ verbosity: LoggingLevel, _ exitBadCommand: () -> ()) {
    do {
        try  LinkGrubber().grub (name: "BigData",
                                 configURL:configurl,
                                 opath:opath,
                                 logLevel: verbosity)
        { crawlResults in
            
            print("[crawler] linkgrubber scanned \(crawlResults.count1), \(crawlResults.count2) pages,  \(String(format:"%5.2f",crawlResults.secsPerCycle*1000)) ms per page")
            
            
            // at this point we've plunked files into the designated directory
            let start = Date()
            
            // generate the site with the Hd theme
            
            do {
                
                let prepublishcount = try   PrePublishing.allPrePublishingSteps()
                let (steps,stepcount) = try PublishingStep<Hd>.allsteps()
                try Hd().publish(withTheme: .hd, additionalSteps:steps)
                let published_counts = crawlResults.count1 + prepublishcount + stepcount
                let elapsed = Date().timeIntervalSince(start) / Double(published_counts)
                
                print("[crawler] published \(published_counts) pages,  \(String(format:"%5.2f",elapsed*1000)) ms per page")
                
            }
            catch {
                print("[crawler] notices Publish has crashed - \(error)")
            }
        }
    }
    catch {
        exitBadCommand()
    }
}

