import Foundation
func command_main() {
    
    func printUsage() {
        let processinfo = ProcessInfo()
        print(processinfo.processName)
        let path = LibraryDirectoryURL.absoluteString
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

    var opath:String
    
    // -json and -csv go to adforum for now, -text goes to manifezz
    
    do {
       
        opath = Hd.pathToResourcesDir + "/bigdata.csv"
        
        guard let configurl = URL(string:CommandLine.arguments[1]) else  { exitBadCommand(); exit(0)  }
        
        Crawler(configurl, opath, verbosity, exitBadCommand)
    }
}

// really starts here

command_main()


