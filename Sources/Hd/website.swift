//
//  File.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation


// This type acts as the configuration for your website.


let crawlerKeyTags:[String] = ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light"]

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
extension Hd {
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
