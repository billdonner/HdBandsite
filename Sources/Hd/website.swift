//
//  Website.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Publish
import Plot
import Kanna

// This type acts as the configuration for your website.

struct Hd: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        
        case about
        case specialpages
        case audiosessions
    }
    
    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        // var flotsam : TimeInterval = 0
        //var venue: String?
        //var date: String?
    }
    
    // Update these properties to configure your website:
    var url = URL(string: "http://abouthalfdead.com")!
    var name = "About Half Dead " // + "\(Date())".dropLast(14)
    var description = "The Greatest Band In A Very Small Land - published on " + "\(Date())".dropLast(9)
    var language: Language { .english }
    var imagePath: Path? { "images/ABHDLogo.png" }
    var favicon: Favicon?  { Favicon(path: "images/favicon.png")}
    
    static let default_venue_acronym : String = "thorn"
    static let default_venue_description: String = "Highline Studios, Thornwood, NY"
    static let crawlerKeyTags:[String] = ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light"]
}



extension PublishingStep where Site == Hd {
    static func addDefaultSectionTitles() -> Self {
        .step(named: "Default section titles") { context in
            context.mutateAllSections { section in
                guard section.title.isEmpty else { return }
                
                switch section.id {
                case .audiosessions:
                    section.title =  "Audio" 
                case .specialpages:
                    section.title = "Favorites"
                case .about:
                    section.title = "About"
                    
                }
            }
        }
    }
}

extension PublishingStep where Site == Hd {
    static func makeMembersPage()->PublishingStep<Hd> {
        
        let bod = Node.body(
            .style("header nav a { color: #cb3018; padding: 10px 10px; };  dd {font-size:.6em}"),
            .h2("Who Are We?"),
            .img(.src("/images/roseslogo.png")),
            .span("We play in \(Hd.default_venue_description)"),
            .ul(
                .li(.dl(
                    .dt("Anthony"),
                    .dd("Rhythm Guitar and ",.strong( "Vocals"))
                    )),
                .li(.dl(
                    .dt("Bill"),
                    .dd("Keyboards")
                    )),
                .li(.dl(
                    .dt("Brian"),
                    .dd("Drums ", .s("and Vocals"))
                    )),
                
                .li(.dl(
                    .dt("Mark"),
                    .dd("Lead Guitar and ", .ins("Vocals"))
                    )),
                
                .li(.dl(
                    .dt("Marty"),
                    .dd("Bass")
                    ))),
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
                    .input(.name("email"), .type(.email), .autocomplete(true), .required(true)),
                    .textarea(.name("comments"), .cols(50), .rows(10), .required(false), .text("Tell us about your party"))
                ), 
                .input(.type(.submit), .value("Send")),
                .input(.type(.reset), .value("Clear"))
            )
        )
        
        let   b = bod.render(indentedBy: .tabs(1))
        print("[crawler] adding About Us page")
        return PublishingStep<Hd>.addItem(Item(
            path: "/", // this will put it at /about which will take us directly there from top menu
            sectionID: .about,
            metadata: Hd.ItemMetadata(),
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

//MARK: - pass thru the music and art files, only
extension Transformer {
    func absorbLink(href:String? , txt:String? ,relativeTo: URL?, tag: String, links: inout [LinkElement]) {
        if let lk = href, //link["href"] ,
            let url = URL(string:lk,relativeTo:relativeTo) {
            let pextension = url.pathExtension.lowercased()
            let hasextension = pextension.count > 0
            let linktype:Linktype = hasextension == false ? .hyperlink:.leaf
            guard url.absoluteString.hasPrefix(relativeTo!.absoluteString) else {
                return
            }
            
            if hasextension {
                guard pextension == "mp3" || pextension == "wav" || pextension == "jpg" || pextension == "jpeg" || pextension == "png" ||  pextension == "md" else {
                    return
                }
                if pextension == "jpg" || pextension == "jpeg" || pextension == "png" || pextension == "md"  {
                    print("Processing \(pextension) file from \(url)")
                }
            } else
            {
                //  print("no ext: ", url)
            }
            
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
}
