
import Foundation
let matchingURLPrefix = URL(string:"https://billdonner.com/halfdead")!
command_main()



 func generateImagesAndMarkdownFromRemoteDirectoryAssets(links:[Fav]) -> ImagesAndMarkdown {
    var images: [String] = []
    var pmdbuf = "\n"
    for(_,alink) in links.enumerated() {
        let pext = (alink.url.components(separatedBy: ".").last ?? "fail").lowercased()
        if (pext=="md") {
            // copy the bytes inline from remote md file
            if let surl = URL(string:alink.url) {
                do {
                    pmdbuf +=   try String(contentsOf: surl) + "\n\n\n"
                }
                catch {
                    print("[crawler] Couldnt read bytes from \(alink.url) \(error)")
                }
            }
        } else
            if isImageExtension(pext) {
                // if its an image just accumulate them in a gallery
                images.append(alink.url)
        }
    }
    if images.count == 0  {
        images.append( "/images/abhdlogo300.png")
    }
    return ImagesAndMarkdown(images:images,markdown:pmdbuf)
}
 func makeAndWriteMdFile(_ title:String, stuff:String,spec:String) throws {
          let markdownData: Data? = stuff.data(using: .utf8)
          try markdownData!.write(to:URL(fileURLWithPath:  spec,isDirectory: false))
      }
