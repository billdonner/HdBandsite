import Foundation
import LinkGrubber
import GigSiteAudio
import Kanna 
import Plot
import Publish
import BandSite


let letters = CharacterSet.letters
let digits = CharacterSet.decimalDigits

public protocol   BandSiteHTMLProt: class  {
    var artist : String { get set }
    var venueShort : String { get set }
    var venueLong : String { get set }
    var crawlTags:[String] { get set }
}
let lgFuncs =  LgFuncs.standardAudioCrawlFuncs()



extension LgFuncs {
    // kanna specific
    private static func kannaScrapeAndAbsorb (lgFuncs:LgFuncs,theURL:URL, html:String ,links: inout [LinkElement]) throws -> String {
        
        func absorbLink(href:String? , txt:String? ,relativeTo: URL?, tag: String, links: inout [LinkElement]) {
            if let lk = href, //link["href"] ,
                let url = URL(string:lk,relativeTo:relativeTo) ,
                let linktype = lgFuncs.processExtension(url:url, relativeTo: relativeTo) {
                
                // strip exension if any off the title
                let parts = (txt ?? "fail").components(separatedBy: ".")
                if let ext  = parts.last,  let front = parts.first , ext.count > 0
                {
                    let subparts = front.components(separatedBy: "-")
                    if let titl = subparts.last {
                        let titw =  titl.trimmingCharacters(in: .whitespacesAndNewlines)
                        links.append(LinkElement(title:titw,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                    }
                } else {
                    // this is what happens upstream
                    if  let txt  = txt  {
                        links.append(LinkElement(title:txt,href:url.absoluteString,linktype:linktype, relativeTo: relativeTo))
                    }
                }
            }
        }// end of absorbLink
        let doc = try  Kanna.HTML(html: html, encoding: .utf8)
        let title = doc.title ?? "<untitled>"
        for link in doc.xpath("//a") {
            absorbLink(href:link["href"],
                       txt:link.text,
                       relativeTo:theURL,
                       tag: "media",links:&links )
        }
        return title
    }
    
    static  func standardAudioCrawlFuncs() -> LgFuncs {
        return LgFuncs(imageExtensions: ["jpg","jpeg","png"],
                       audioExtensions: ["mp3","mpeg","wav"],
                       markdownExtensions: ["md", "markdown", "txt", "text"],
                       scrapeAndAbsorbFunc: kannaScrapeAndAbsorb)
    }
    
}

public func bandsite_command_main(bandfacts:BandSiteFacts,rewriter:((String)->String)) {
func showCrawlStats(_ crawlResults:LinkGrubberStats,prcount:Int ) {
    // at this point we've plunked files into the designated directory
    let start = Date()
    // generate the site with the Hd theme
    let published_counts = crawlResults.count1 + prcount
    let elapsed = Date().timeIntervalSince(start) / Double(published_counts)
    print("[crawler] published \(published_counts) pages,  \(String(format:"%5.2f",elapsed*1000)) ms per page")
}
    
    func printUsage() {
        let processinfo = ProcessInfo()
        print(processinfo.processName)
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        print("\(executableName)")
        print("usage:")
        print("\(executableName) s or m or l")
        
    }
    func publishBandSite() ->Int {
        do {
            let (steps,stepcount) = try PublishingStep<Hd>.allsteps()
            try Hd().publish(withTheme: .hd, additionalSteps:steps)
            return stepcount
        }
        catch {
            print("[crawler] could not publish \(error)")
            return 0
        }
    }
    func bandSiteRunCrawler (_ roots:[RootStart],finally:@escaping (Int)->()) {
        
        let pmf = AudioHTMLSupport(bandfacts: bandfacts,
                                   lgFuncs: lgFuncs ).audioListPageMakerFunc
        
        let _ = AudioCrawler(roots:roots,
                             verbosity:  .none,
                             lgFuncs: lgFuncs,
                             pageMaker: pmf,
                           //  prepublishCount: bandfacts.allFavorites.count ,
                             //
        bandSiteParams: bandfacts) { status in // just runs
            
            
            finally(status)
        }
    }
    // the main program starts right here really starts here

    
    do {
        let bletch = { print("[crawler] bad command \(CommandLine.arguments)"  )
            printUsage()
            return
        }
        guard CommandLine.arguments.count > 1 else  { bletch(); exit(0)  }
        let arg1 =  CommandLine.arguments[1].lowercased()
        let incoming = String(arg1.first ?? "X")
        let rooturl = rewriter(incoming)
        let rs = [RootStart(name: incoming, urlstr: rooturl)]
        Hd.setup(bandfacts)
        print("[crawler] executing \(rooturl)")
        let crawler = bandSiteRunCrawler
        
        var done = false
        crawler(rs,  { status in
            switch status {
            case 200:
                
                
                break
            default:  bletch(); exit(0) 
            }
            done=true
        })
        while (done==false) { print("[crawler] sleep"); sleep(1);}
        print("[crawler] it was a perfect crawl ")
        
        // this is the first time we hit the sites
//
//        let stepcount = publishBandSite()
//        print("[crawler] Publish finished; steps:",stepcount)
        
        return
    }
} 

extension Node where Context: HTML.BodyContext {
    /// Add a `<figure>` HTML element within the current context.
    /// - parameter nodes: The element's attributes and child elements.
    static func figure(_ nodes: Node<HTML.BodyContext>...) -> Node {
        .element(named: "figure", nodes: nodes)
    }
    /// Add a `<figcaption>` HTML element within the current context.
    /// - parameter nodes: The element's attributes and child elements.
    static func figcaption(_ nodes: Node<HTML.BodyContext>...) -> Node {
        .element(named: "figcaption", nodes: nodes)
    }
}


open class AudioHTMLSupport {
    let bandfacts:FileSiteProt&BandSiteHTMLProt
    let lgFuncs: LgFuncs
    public init(bandfacts:FileSiteProt&BandSiteHTMLProt,lgFuncs:LgFuncs)
    {
        self.bandfacts = bandfacts
        self.lgFuncs = lgFuncs
    }
    func topdiv(cookie:String,links:[Fav],lgFuncs:LgFuncs)-> Node<HTML.BodyContext>  {
        let immd = AudioHTMLSupport.ImagesAndMarkdown.generateImagesAndMarkdownFromRemoteDirectoryAssets(links:links,lgFuncs:lgFuncs)
        
        return Node.div ( .div(
            .img(.src("\(immd.images[0])"), .class("img300"),
                 .alt("\(immd.markdown.prefix(50))")),
            .h4 ( .i ("\(cookie)")),
            .p("\(immd.markdown)"))
        )
    }
    struct BannerAndTags {
        let banner: String
        let tags:[String]
    }
    struct ImagesAndMarkdown {
        let images: [String]
        let markdown: String
        
        static func generateImagesAndMarkdownFromRemoteDirectoryAssets(links:[Fav],lgFuncs:LgFuncs) -> ImagesAndMarkdown {
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
                    if lgFuncs.isImageExtension(pext) {
                        // if its an image just accumulate them in a gallery
                        images.append(alink.url)
                }
            }
            if images.count == 0  {
                images.append( "/images/abhdlogo300.png")
            }
            return ImagesAndMarkdown(images:images,markdown:pmdbuf)
        }
    }
    
    private func buildAudioBlock(idx:Int,alink:Fav)->String {
        let pext = (alink.url.components(separatedBy: ".").last ?? "fail").lowercased()
        if lgFuncs.isAudioExtension(pext){
            let div = Node.div(
                .h2("\(String(format:"%02d",idx+1))    \(alink.name)"),
                .figure(
                    .figcaption(.text(alink.comment)),
                    .audio(.controls(true), .source(.src(alink.url), .type((pext == "mp3") ? .mp3:.wav))))
            )
            return  div.render()
        }
        else {
            return    ""
        }
    }
    private func generateAudioHTMLFromRemoteDirectoryAssets(links:[Fav]) -> String {
        var outbuf = ""
        for(idx,alink) in links.enumerated() {
            outbuf += buildAudioBlock(idx: idx,alink: alink)
        }
        return outbuf
    }
    
    
    
    private func generateAudioTopMdHTML(title:String,u sourceurl:URL, venue:String,playdate:String,tags:[String] ,links:[Fav])->String {
        
        let immd = ImagesAndMarkdown.generateImagesAndMarkdownFromRemoteDirectoryAssets(links:links,lgFuncs:lgFuncs)
        
        let cookie = Fortunes.get_fortune_cookie()
        
        // it seems essential to put the title in here instead of inside the plot Node above
        func   markdownmetadata(stuff:String)-> String {
            let ellipsis = stuff.count>500 ? "..." : ""
            return """
            ---
            sourceurl: \(sourceurl.absoluteString)
            venue: \(venue)
            description: \(cookie) \(stuff.prefix(500))\(ellipsis)
            tags: \(tags.joined(separator: ","))
            ---
            
            # \(title)
            
            
            """
        }
        
        // func topdiv(cookie:String,links:[Fav],lgFuncs:LgFuncs)-> Node<HTML.BodyContext>
        return markdownmetadata(stuff: immd.markdown) + "\(topdiv(cookie:cookie,links:links,lgFuncs:lgFuncs).render())"
    }
    
    
    
    // this variation uses venu and playdate to form a title
    public  func audioListPageMakerFunc(
        props:CustomPageProps,
        links:[Fav] ) throws {
        
        struct Shredded {
            let letters: String
            let digits:String
        }
        func yymmddFromDigits(digits:String)->String{
            let month = digits.prefix(2)
            let year = digits.suffix(2)
            let start = digits.index(digits.startIndex, offsetBy: 2)
            let end = digits.index(digits.endIndex, offsetBy: -2)
            let day = digits[start..<end]
            return String(year+month+day)
        }
        func pickapart(_ phrase:String) -> Shredded {
            
            var letterCount = 0
            var digitCount = 0
            var lets:String = ""
            var digs:String = ""
            
            for uni in phrase.unicodeScalars  {
                if letters.contains(uni) {
                    letterCount += 1
                    lets += String(uni)
                } else if digits.contains(uni) {
                    digitCount += 1
                    digs += String(uni)
                }
            }
            return Shredded(letters:lets, digits:digs)
        }
        func checkForBonusTags(name:String?)->String? {
            if let songName = name {
                let shorter = songName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                for tuneTag in  bandfacts.crawlTags {
                    if shorter.hasPrefix(tuneTag) {
                        return tuneTag
                    }
                }
            }
            return nil
        }
        
        func makeAndWriteMdFile(_ title:String, stuff:String,spec:String) throws {
            let markdownData: Data? = stuff.data(using: .utf8)
            try markdownData!.write(to:URL(fileURLWithPath:  spec,isDirectory: false))
        }
        
        
        
        var moretags:Set<String>=[]
        
        
        // starts here
        let fund = props.urlstr.components(separatedBy: ".").last ?? "fail"
        let shredded = pickapart(fund)
        let playdate = shredded.digits
        let venue = shredded.letters
        let ve =  venue == "" ? bandfacts.venueShort : venue
        guard playdate != "" else {return}
        
        for link in links {
            if  let bonustag = checkForBonusTags(name: link.name )  {
                moretags.insert(bonustag)
            }
        }
        if links.count == 0 { print("[crawler] no links for \(props.title) - check your music tree") }
        else {
            
            let x=makeBannerAndTags(aurl:props.urlstr , mode: props.isInternalPage)
            
            
            var spec: String
            switch  props.isInternalPage {
            case  false :
                spec =  "\(bandfacts.pathToContentDir)/audiosessions/\(ve)\(playdate).md"
            case true  :
                spec =  "\(bandfacts.pathToContentDir)/favorites/\(props.title).md"
            }
            guard let u = URL(string:props.urlstr) else { return }
            let stuff =  generateAudioMarkdownPage(x.banner,
                                                   u:u,
                                                   venue: venue ,
                                                   playdate:playdate,
                                                   tags:Array(moretags) + x.tags  + props.tags ,
                                                   links:links,
                                                   mode:props.isInternalPage)
            try makeAndWriteMdFile(props.title,  stuff: stuff, spec: spec)
        }
    }
    private func generateAudioMarkdownPage(_ title:String,u:URL,venue:String ,playdate:String,tags:[String]=[],links:[Fav]=[],
                                           mode:Bool )->String {
        var newtags = tags
        switch mode {
        case true:
            break
        case false :
            newtags.append("favorite")
        }
        
        return  generateAudioTopMdHTML(title:title,u:u,venue:venue,playdate:playdate,tags:newtags,links:links)
            + "\n\n\n\n"
            + generateAudioHTMLFromRemoteDirectoryAssets(links: links)
    }
    
    /// make some tags  and banner from the alburm name
    private func makeBannerAndTags(aurl:String,mode:Bool)->BannerAndTags {
        guard let u = URL(string:aurl) else { fatalError() }
        // take only the top two parts and use them as
        
        let parts = u.path.components(separatedBy: "/")
        var tags = [parts[1],parts[2]]
        // lets analyze parts3, if it is multispaced then lets call it a gig
        let subparts3 = parts[3].components(separatedBy: " ")
        var performanceKind = ""
        if (subparts3.count > 1) {
            performanceKind = "live"
            tags.append(subparts3[1])
        }
        else  {
            performanceKind = "rehearsal"
        }
        
        var banner:String
        switch mode {
        case true:
            // if publish is generating, then use this
            tags.append( performanceKind )
            banner = parts[2] + " \(performanceKind) " + parts[3]
            
        case false:
            
            banner =  parts[3]
        }
        
        return BannerAndTags(banner: banner , tags: tags )
    }
    
}// struct audio

