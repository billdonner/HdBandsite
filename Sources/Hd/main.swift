import Foundation
import Publish
import Plot

// extra properties for crawling


let crawlerKeyTags:[String] = ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light"]

let crawlerMarkDownOutputPath =  "/Users/williamdonner/hd/Content/audiosessions" // NSTemporaryDirectory()


// this is an exmple what dates shoud look like
// date: 2020-01-05 17:42
func renderMarkdown(_ s:String,tags:[String]=[],links:[(String,String)]=[] )->String {
    let date = "\(Date())".dropLast(9)
    let tagstring = tags.joined(separator: ",")
    var mdbuf : String = """
    
    ---
    date: \(date)
    description: \(s)
    tags: \(tagstring)
    players: "XBill","XMark","Marty","Anthony","Brian"
    flotsam: 600
    ---
    <img src="/images/abhdlogo300.jpg" />
    
    # \(s)
    
    tunes played:
    
    """ // copy
    for(idx,alink) in links.enumerated() {
        let (name,url) = alink
        mdbuf += """
        \n\(String(format:"%02d",idx+1))    [\(name)](\(url))\n
        <figure>
        <figcaption> </figcaption>
        <audio
        controls
        src="\(url)">
        Your browser does not support the
        <code>audio</code> element.
        </audio>
        </figure>
        
        """
    }
    return mdbuf
}


// This type acts as the configuration for your website.
struct Hd: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        
        case specialpages
        case about
        case audiosessions
        case home
    }
    
    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        var players: [String] = ["Bill","Mark","Marty","Anthony","Brian"]
        var flotsam : TimeInterval = 0
    }
    
    // Update these properties to configure your website:
    var url = URL(string: "http://abouthalfdead.com")!
    var name = "About Half Dead " // + "\(Date())".dropLast(14)
    var description = "The Greatest Band In A Very Small Land - published on " + "\(Date())".dropLast(9)
    var language: Language { .english }
    var imagePath: Path? { "images/ABHDLogo.png" }
    var favicon: Favicon?  { Favicon(path: "images/favicon.png") }
    
    
}

extension PublishingStep where Site == Hd {
    static func addDefaultSectionTitles() -> Self {
        .step(named: "Default section titles") { context in
            context.mutateAllSections { section in
                guard section.title.isEmpty else { return }
                
                switch section.id {
                case .audiosessions:
                    section.title = "* Audio Sessions *"
                case .specialpages:
                    section.title = "* Greaatest Hits *"
                case .about:
                    section.title = "* About ABHD *"
                
                case .home:
                           section.title = "* Home *"
                       }
            }
        }
    }
}

extension PublishingStep where Site == Hd {
    static func makeMembersPage()->PublishingStep<Hd> {
        let html = HTML(.body(
            .h2("Who Are We?"),
            .img(.src("/images/roseslogo.png")),
            .ul(
                .li("Anthony"),
                .li("Bill"),
                .li("Brian"),
                .li("Mark"),
                .li("Marty")
            )
            ))
        let   b = html.render(indentedBy: .tabs(1))
        return PublishingStep<Hd>.addItem(Item(
            path: "Members of ABHD",
            sectionID: .about,
            metadata: Hd.ItemMetadata(
                players: ["Bill","Mark","Marty","Anthony","Brian"],
                flotsam: 10 * 60
            ),
            tags: [ "featured"],
            content: Content(
                title: "About Us",
                description:"Members of the Band",
                body: """
                \(b)
                """
            )
            )
        )
    }
}
extension PublishingStep where Site == Hd {
    static  func makeBookUsPage()->PublishingStep<Hd> {
        let _ =  """
                    <img src="/images/roseslogo.png">
                    <h2>Hire Us</h2>
                    <form action="mailto:bildonner@gmail.com" method="get" enctype="text/plain">
                      <p>Name: <input type="text" name="name"/></p>
                      <p>Email: <input type="text" name="email"/></p>
                      <p>Comments:
                        <br />
                        <textarea name="comments" rows = "12" cols = "35">Tell Us About Your Party</textarea>
                        <br>
                      <p><input type="submit" name="submit" value="Send" />
                        <input type="reset" name="reset" value="Clear Form" />
                      </p>
                    </form>
    """
        
        let html = HTML(.body(
             .img(.src("/images/roseslogo.png")),
            .form(
                .action("mailto:bildonner@gmail.com"),
              
                    .h2( "Hire Us"),
             
                    .p("We Don't Play For Free"),
                    
                .fieldset(
                    .label(.for("name"), "Name"),
                    .input(.name("name"), .type(.text), .autofocus(false), .required(true))
                ),
                .fieldset(
                    .label(.for("email"), "Email"),
                    .input(.name("email"), .type(.email), .autocomplete(true), .required(true))
                ),
                 .textarea(.name("comment"), .cols(50), .rows(10), .required(false), .text("Tell us about your party")),
               
                .input(.type(.submit), .value("Send"))
            )
            ))
        let   b = html.render(indentedBy: .tabs(1))
        
        return   PublishingStep<Hd>.addItem(Item(
            path: "Book ABHD",
            sectionID: .about,
            metadata: Hd.ItemMetadata(
                players: ["XBill","Mark","Marty","Anthony","Brian"],
                flotsam: 10 * 60
            ),
            tags: ["favorite", "featured"],
            content: Content(
                title: "Book Us For Your Next Party",
                description:"Book Us For Your Next Party, we play all over Westchester",
                body:"""
                \(b)
                """
            )
            )
        ) 
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
    var xoptions:ExportMode
    
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
            try  KrawlMaster().boot (name: opath.components(separatedBy: ".-").first ?? opath,
                                                   baseURL:baseURL!,
                                                   configURL:configurl,
                                                   opath:opath,
                                                   logLevel: verbosity ? LoggingLevel.verbose :  LoggingLevel.none,
                                                   exportMode:xoptions)
            { crawlResults in
                print("[crawler] scanned \(crawlResults.count1) pages,  \(String(format:"%5.2f",crawlResults.secsPerCycle*1000)) ms per page")
                // at this point we've plunked files into the designated directory
                let start = Date()
                
                // This will generate your website using the built-in Foundation theme:
                let additionalSteps:[PublishingStep<Hd>] =  [PublishingStep<Hd>.makeMembersPage(),
                                                             PublishingStep<Hd>.makeBookUsPage(),
                                                             PublishingStep<Hd>.addDefaultSectionTitles()]
                do {
                try Hd().publish(withTheme: .foundation,
                                  additionalSteps:additionalSteps)
                
                let elapsed = Date().timeIntervalSince(start) / Double(crawlResults.count1)
                print("[crawler] published \(crawlResults.count1) pages,  \(String(format:"%5.2f",elapsed*1000)) ms per page")
                    
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
}

// really starts here

command_main()

