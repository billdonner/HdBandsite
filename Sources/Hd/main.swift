import Foundation
import Publish
import Plot

// extra properties for crawling


let crawlerMarkDownOutputPath =  "/Users/williamdonner/hd/Content" // NSTemporaryDirectory()

public struct Fav {
    let name: String
    let url: String
    let comment: String
}
    
    
fileprivate func addBillsFavorites() {
 
    let links:[Fav] = [
        Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"favorite of all time"),
        Fav(name: "riders",url: "https://billdonner.com/foobly/riders.mp3",comment:"best of the year")
    ]
    
    
    createMarkDown(mode:.fromWithin,  url:"grubber://mumble012/custom/bill/bills-best-2019/",
                   venue: "favorites",
                   playdate: "123119",
                   links:links)
    
    print("[crawler] adding Bills Favorites")
}
fileprivate func addBriansFavorites() {
    let links = [
        Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"not exactly my taste"),
                 
                 
        Fav(name: "riders",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"I like the drumming")
    ]
    
    
    createMarkDown(mode:.fromWithin, url:"grubber://mumble012/custom/brian/brians-favorites-2018/",
                   venue: "favorites",
                   playdate: "123118",
                   links:links)
     print("[crawler] adding Brians Favorites")
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
    
    var verbosity:LoggingLevel = .none
    var baseURL:URL? = nil
    var opath:String 
    var exportMode:ExportMode
    
    // -json and -csv go to adforum for now, -text goes to manifezz
    
    do {
        guard CommandLine.arguments.count > 4 else { exitBadCommand(); exit(0)  }
        let arg0 = CommandLine.arguments[1].dropFirst()
        let subargs = arg0.components(separatedBy: ",")
        
        if  subargs.count>1 {
            verbosity  = subargs[1].hasPrefix("v") ? .verbose: .none
        } else {
            verbosity = .none
        }
        
        switch subargs[0] {
            case "c": exportMode = .csv
            case "j": exportMode = .json
            case "m": exportMode = .md
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
                                                   logLevel: verbosity,
                                                   exportMode:exportMode)
            { crawlResults in
                print("[crawler] scanned \(crawlResults.count1) pages,  \(String(format:"%5.2f",crawlResults.secsPerCycle*1000)) ms per page")
                
                addBillsFavorites()
                 addBriansFavorites()
                
                let published_counts = crawlResults.count1 + 3
                
                // at this point we've plunked files into the designated directory
                let start = Date()
                
                // This will generate your website using the built-in Foundation theme:
                let additionalSteps:[PublishingStep<Hd>] =  [PublishingStep<Hd>.makeMembersPage(), 
                                                             PublishingStep<Hd>.addDefaultSectionTitles()]
                do {
                try Hd().publish(withTheme: .foundation,
                                  additionalSteps:additionalSteps)
                
                let elapsed = Date().timeIntervalSince(start) / Double(crawlResults.count1)
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
}

// really starts here

command_main()
