import Foundation


func command_main(crawler:CrawlingSignature) {
     func printUsage() {
        let processinfo = ProcessInfo()
        print(processinfo.processName)
        let path = ExportDirectoryURL.absoluteString
        let nam = FileManager.default.displayName(atPath: path)
        print(nam)
        
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        print("\(executableName)")
        print("usage:")
        print("\(executableName) -j config-file-url json-output-file [base-url]")
        print("or")
        print("\(executableName) -c config-file-url csv-output-file [base-url]")
        print("or")
        print("\(executableName) -jv or -cv for vebose output")
    }
    

    // -json and -csv go to adforum for now, -text goes to manifezz
    
    do {
        let bletch = { print("[crawler] bad command \(CommandLine.arguments)"  ) ; printUsage(); return; }
        guard CommandLine.arguments.count > 1 else  { bletch(); exit(0)  }
        let arg1 =  CommandLine.arguments[1].lowercased()
        let c = String(arg1.first ?? "X")
        
        crawler(c,  { status in
            switch status {
            case 200:   print("[crawler] it was a perfect crawl ")
            default:  bletch()
            }
        })
        
    }
}

// the main program starts right here really starts here

command_main(crawler:Hd.crawler)


