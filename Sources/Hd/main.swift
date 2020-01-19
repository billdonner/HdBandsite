import Foundation
func command_main() {
    
    func printUsage() {
        let processinfo = ProcessInfo()
        print(processinfo.processName)
        let path = ExportDirectoryURL.absoluteString
        let nam = FileManager.default.displayName(atPath: path)
        print(nam)
         
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
 
    
    let verbosity:LoggingLevel = .verbose


    
    // -json and -csv go to adforum for now, -text goes to manifezz
    
    do {
        
        var configurl :URL?
        guard CommandLine.arguments.count > 1 else  { exitBadCommand(); exit(0)  }
        let arg1 =  CommandLine.arguments[1].lowercased()
        let c = arg1.first
        switch c {
        case "m": configurl = URL(string: "https://billdonner.com/linkgrubber/manifezz-medium.json")
        case "l": configurl = URL(string: "https://billdonner.com/linkgrubber/manifezz-full.json")
        default: configurl = URL(string: "https://billdonner.com/linkgrubber/manifezz-small.json")
        }
        guard let gurl = configurl else { exitBadCommand(); exit(0)  }
        print("[crawler] executing \(gurl)")
        let _ = Crawler(configurl: gurl, verbosity: verbosity) { status in // just runs
            print("Crawler complete with status \(status)")
            exit(0)
        }
    }
}

// the main program starts right here really starts here

command_main()


