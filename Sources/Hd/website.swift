//
//  File.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Publish
import Plot

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
                    section.title = "º Audio º"
                    
                case .specialpages:
                    section.title = "º Favorites º"
                case .about:
                    section.title = "º About º"
                    
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
        print("[crawling] adding About Us page")
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
//extension PublishingStep where Site == Hd {
//    static  func makeBookUsPage()->PublishingStep<Hd> {
//        
//        let html = HTML(.body(
//            .img(.src("/images/roseslogo.png"),.class("image"),.alt("ABHD LOGO")),
//            .form(
//                .action("mailto:bildonner@gmail.com"),
//                
//                .h2( "Hire Us"),
//                
//                .p("We Don't Play For Free"),
//                
//                .fieldset(
//                    .label(.for("name"), "Name"),
//                    .input(.name("name"), .type(.text), .autofocus(false), .required(true))
//                ),
//                .fieldset(
//                    .label(.for("email"), "Email"),
//                    .input(.name("email"), .type(.email), .autocomplete(true), .required(true)),
//                    .textarea(.name("comments"), .cols(50), .rows(10), .required(false), .text("Tell us about your party"))
//                ),
//                
//                .input(.type(.submit), .value("Send")),
//                .input(.type(.reset), .value("Clear"))
//            )
//            ))
//        let   b = html.render(indentedBy: .tabs(1))
//        
//        return   PublishingStep<Hd>.addItem(Item(
//            path: "Book ABHD",
//            sectionID: .about, metadata: Hd.ItemMetadata(),
//            //            metadata: Hd.ItemMetadata(
//            //                players: ["XBill","Mark","Marty","Anthony","Brian"],
//            //                flotsam: 10 * 60
//            //            ),
//            tags: ["favorite", "featured"],
//            content: Content(
//                title: "Book Us For Your Next Party",
//                description:"Book Us For Your Next Party, we play all over Westchester",
//                body:"""
//                \(b)
//                """
//            )
//            )
//        )
//    }
//}
////        let _ =  """
////                    <img src="/images/roseslogo.png">
////                    <h2>Hire Us</h2>
////                    <form action="mailto:bildonner@gmail.com" method="get" enctype="text/plain">
////                      <p>Name: <input type="text" name="name"/></p>
////                      <p>Email: <input type="text" name="email"/></p>
////                      <p>Comments:
////                        <br />
////                        <textarea name="comments" rows = "12" cols = "35">Tell Us About Your Party</textarea>
////                        <br>
////                      <p><input type="submit" name="submit" value="Send" />
////                        <input type="reset" name="reset" value="Clear Form" />
////                      </p>
////                    </form>
////    """
//
//        let p = Page(path:"/foo",content:Content(
//            title: "About Us",
//            description:"Members of the Band",
//            body:"""
//        \(bod)
//""")
//        )
//        return PublishingStep<Hd>.addPage(p)



//
//        let html = HTML(.comment("We Need Contributions From Band Members"),
//                        .head(.style("header nav a { color: #cb3018; padding: 10px 10px; }; dd {font-size:.6em}"),
//                                     .title("ABHD Members"),
//                                     .description("We can play cover tunes and jam tunes"),
//                                     .socialImageLink("/images/roseslogo.png"),
//                                     .twitterCardType(.summaryLargeImage),
//
