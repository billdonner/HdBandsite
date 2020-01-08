import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct Hd: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        
        case links
        case about
        case posts
    }
    
    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        var players: [String] = ["Bill","Mark","Marty","Anthony","Brian"]
        var flotsam : TimeInterval = 0
    }
    
    // Update these properties to configure your website:
    var url = URL(string: "http://shtickerz.com")!
    var name = "About Half Dead " + "\(Date())".dropLast(14)
    var description = "The Greatest Band In A Very Small Land " + "\(Date())".dropLast(9)
    var language: Language { .english }
    var imagePath: Path? { "https://billdonner.com/images/austinmay2019.jpg" }
}

extension PublishingStep where Site == Hd {
    static func addDefaultSectionTitles() -> Self {
        .step(named: "Default section titles") { context in
            context.mutateAllSections { section in
                guard section.title.isEmpty else { return }

                switch section.id {
                case .posts:
                    section.title = "Audio from ABHD"
                case .links:
                    section.title = "External links"
                case .about:
                    section.title = "About Half Dead"
                }
            }
        }
    }
}

func command_main() {
    
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
    
    var verbosity:Bool = false
    var baseURL:URL? = nil
    var opath:String!
    
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
                print("[crawler] scanned \(crawlResults.count1) pages,  \(String(format:"%5.2f",crawlResults.secsPerCycle*1000)) ms per page")
                // at this point we've plunked files into the designated directory
                let start = Date()
                
                // This will generate your website using the built-in Foundation theme:
                
                let step1 =      PublishingStep<Hd>.addItem(Item(
                                                 path: "my-favorite-recipe",
                                                 sectionID: .links,
                                                 metadata: Hd.ItemMetadata(
                                                     players: ["XBill","Mark","Marty","Anthony","Brian"],
                                                    flotsam: 10 * 60
                                                 ),
                                                 tags: ["favorite", "featured"],
                                                 content: Content(
                                                     title: "Check out my favorite recipe!",
                                                     description:"some short description",
                                                     body: "<h2>E pluribus unim</h2><p>foobar</p>")
                                                 )
                                             )
                
                let step2 =      PublishingStep<Hd>.addItem(Item(
                                                           path: "my-favorite-recipe2",
                                                           sectionID: .links,
                                                           metadata: Hd.ItemMetadata(
                                                               players: ["XBill","Mark","Marty","Anthony","Brian"],
                                                              flotsam: 10 * 60
                                                           ),
                                                           tags: ["favorite", "featured"],
                                                           content: Content(
                                                               title: "Check out my favorite recipe!2",
                                                               description:"some short description2",
                                                               body: "<h2>E pluribus unim2</h2><p>foobar2</p>")
                                                           )
                                                       )
                try! Hd().publish(withTheme: .foundation,
                
                additionalSteps: [
                                  // Add an item programmatically
                    step1,step2
                             ]
                )
                let elapsed = Date().timeIntervalSince(start) / Double(crawlResults.count1)
                 print("[crawler] published \(crawlResults.count1) pages,  \(String(format:"%5.2f",elapsed*1000)) ms per page")
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
}

// really starts here

command_main()
