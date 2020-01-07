import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct Hd: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "http://shtickerz.com")!
    var name = "Hd"
    var description = "The Greatest Band In A Very Small Land"
    var language: Language { .english }
    var imagePath: Path? { nil }
}


//import SPMCrawlingCore

func printUsage() {
    let processinfo = ProcessInfo()
    print(processinfo.processName)
    let path = LibraryDirectoryURL.absoluteString
    let nam = FileManager.default.displayName(atPath: path)
    print(nam)
    
    // Get display name, version and build
    
    if let displayName =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String{
        print(displayName)
    }
    if let version =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String{
        print(version)
    }
    if let build =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as?  String {
        print(build)
    }
    if let bundleID  =
        Bundle.main.infoDictionary?[ "CFBundleIdentifier"] as? String {
        print(bundleID)
    }
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    
    print("\(executableName) 1.0.3 ")
    print("usage:")
    print("\(executableName) -j config-file-url json-output-file [base-url]")
    print("or")
    print("\(executableName) -c config-file-url csv-output-file [base-url]")
    print("or")
    print("\(executableName) -jv or -cv for vebose output")
}
func exitBadCommand() {
    print("""
        {"invalid-command":\(CommandLine.arguments), "status":401}
        """)
    printUsage()
    
}


private var verbosity:Bool = false
private var baseURL:URL? = nil
private var opath:String!

// -json and -csv go to adforum for now, -text goes to manifezz

do {
    guard CommandLine.arguments.count > 4 else { exitBadCommand(); exit(0)  }
    let arg0 = CommandLine.arguments[1].dropFirst()
    let subargs = arg0.components(separatedBy: ",")
    
    if  subargs.count>1 {
        verbosity  = subargs[1].hasPrefix("v")
    } else { verbosity = false }
    if CommandLine.arguments.count > 4  {
        guard let b =  URL(string: CommandLine.arguments[4]) else {exitBadCommand(); exit(0)  }
        baseURL =   b
    }
    opath =  (CommandLine.arguments[3])
    guard let configurl = URL(string:CommandLine.arguments[2]) else  { exitBadCommand(); exit(0)  }
    
    let options:CrawlOptions  = verbosity ? CrawlOptions.verbose :  CrawlOptions.none
    
    do {
        try  ManifezzClass().bootCrawlMeister (name: opath.components(separatedBy: ".-").first ?? opath, baseURL:baseURL!,configURL:configurl,opath:opath,options:options,whenDone: {crawlResults in
            print("[crawler] scanned \(crawlResults.count1) pages,  \(crawlResults.secsPerCycle*1000) ms per page")
            // at this point we've plunked files into the designated directory
            

            // This will generate your website using the built-in Foundation theme:
             try! Hd().publish(withTheme: .foundation)
            
//            try! Hd().publish(using: [
//                .addMarkdownFiles(),
//                .copyResources(),
//               // .addFavoriteItems(),
//               // .addDefaultSectionTitles(),
//                .generateHTML(withTheme: .foundation)
//                //.generateRSSFeed(including: [.recipes]),
//               // .generateSiteMap()
//            ])
        })
    }
    catch {
        exitBadCommand()
    }
}


