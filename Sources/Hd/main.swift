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
    var url = URL(string: "http://abouthalfdead.com")!
    var name = "About Half Dead " + "\(Date())".dropLast(14)
    var description = "The Greatest Band In A Very Small Land " + "\(Date())".dropLast(9)
    var language: Language { .english }
    var imagePath: Path? { "images/ABHDLogo.png" }
}

extension PublishingStep where Site == Hd {
    static func addDefaultSectionTitles() -> Self {
        .step(named: "Default section titles") { context in
            context.mutateAllSections { section in
                guard section.title.isEmpty else { return }
                
                switch section.id {
                case .posts:
                    section.title = " Audio from ABHD "
                case .links:
                    section.title = " Stuff "
                case .about:
                    section.title = " About Half Dead "
                }
            }
        }
    }
}
extension PublishingStep where Site == Hd {
    
    static func steps() ->[ PublishingStep<Hd> ]{
        
        let step1 =      PublishingStep<Site>.addItem(Item(
            path: "my-favorite-recipe",
            sectionID: .links,
            metadata: Hd.ItemMetadata(
                players: ["XBill","Mark","Marty","Anthony","Brian"],
                flotsam: 10 * 60
            ),
            tags: ["favorite", "featured"],
            content: Content(
                title: "Check out my favorite recipe!",
                description:"recipe1 description",
                body: "<h2>E pluribus unim 2</h2><p>foobar</p>")
            )
        )
        
        let step2 =      PublishingStep<Site>.addItem(Item(
            path: "my-favorite-recipe2",
            sectionID: .links,
            metadata: Hd.ItemMetadata(
                players: ["XBill","Mark","Marty","Anthony","Brian"],
                flotsam: 10 * 60
            ),
            tags: ["favorite", "featured"],
            content: Content(
                title: "Check out my favorite recipe!2",
                description:"recip;e description2",
                body: "<h2>E pluribus unim2</h2><p>foobar2</p>")
            )
        )
        return [step1,step2,addDefaultSectionTitles()]
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
    var opath:String 
     var xoptions:ExportOptions
    
    // -json and -csv go to adforum for now, -text goes to manifezz
    
    do {
        guard CommandLine.arguments.count > 4 else { exitBadCommand(); exit(0)  }
        let arg0 = CommandLine.arguments[1].dropFirst()
        let subargs = arg0.components(separatedBy: ",")
        
        if  subargs.count>1 {
            verbosity  = subargs[1].hasPrefix("v")
        } else {
            verbosity = false
            
        }
        
        switch subargs[0] {
        case "c": xoptions = .csv
        case "j": xoptions = .json
        case "m": xoptions = .md
        default: exitBadCommand(); exit(0)
        }
        
        if CommandLine.arguments.count > 4  {
            guard let b =  URL(string: CommandLine.arguments[4]) else {exitBadCommand(); exit(0)  }
            baseURL =   b
        }
        opath =  (CommandLine.arguments[3])
        guard let configurl = URL(string:CommandLine.arguments[2]) else  { exitBadCommand(); exit(0)  }
        
        do {
            try  ManifezzClass().bootCrawlMeister (name: opath.components(separatedBy: ".-").first ?? opath,
                                                   baseURL:baseURL!,
                                                   configURL:configurl,
                                                   opath:opath,
                                                   options: verbosity ? CrawlOptions.verbose :  CrawlOptions.none,
                                                   xoptions:xoptions)
            { crawlResults in
                print("[crawler] scanned \(crawlResults.count1) pages,  \(String(format:"%5.2f",crawlResults.secsPerCycle*1000)) ms per page")
                // at this point we've plunked files into the designated directory
                let start = Date()
                
                // This will generate your website using the built-in Foundation theme:
                
                try! Hd().publish(withTheme: .foundation,
                                  additionalSteps: PublishingStep<Hd>.steps()
                )
                let elapsed = Date().timeIntervalSince(start) / Double(crawlResults.count1)
                print("[crawler] published \(crawlResults.count1) pages,  \(String(format:"%5.2f",elapsed*1000)) ms per page")
            }
        }
        catch {
            exitBadCommand()
        }
    }
}

// really starts here

command_main()


//            try! Hd().publish(using: [
//                .addMarkdownFiles(),
//                .copyResources(),
//               // .addFavoriteItems(),
//               // .addDefaultSectionTitles(),
//                .generateHTML(withTheme: .foundation)
//                //.generateRSSFeed(including: [.recipes]),
//               // .generateSiteMap()
//            ])
