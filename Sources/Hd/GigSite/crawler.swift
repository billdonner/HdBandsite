//
//  cli.swift
//  
//
//  Created by william donner on 1/16/20.
//

import Foundation
import Publish 

// this is the main "ctrawler program", used by both the mac and ios versions

struct Crawler {
    
    init( configurl: URL,  verbosity: LoggingLevel,     bandSiteParams:  BandSiteParams,  specialFolderPaths: [String],finally:@escaping (Int) -> ()) {
        var status  = 200
        func publishNow(_ crawlResults: CrawlerStatsBlock) {
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
                status = 404
            }
        }
        
        do {
            try  LinkGrubber(pageMakerFunc: Audio(bandfacts: Hd.bandfacts).makeAudioListMarkdown).grub (name: "BigData",
                                     configURL: configurl ,
                                     opath:bandSiteParams.pathToResourcesDir + "/bigdata.csv",
                                     
                                     bandSiteParams:  bandSiteParams,
                                     
                                     specialFolderPaths: specialFolderPaths,
                                     logLevel: verbosity)
            {  crawlResults  in
                publishNow(crawlResults)
                finally(status)
            }
        }
        catch {
            print("[crawler] encountered error \(error)")
            finally(status)
        }
    }
}
