//
//  File.swift
//  
//
//  Created by william donner on 1/13/20.
//
import Foundation
import Publish
import Plot

extension Theme where Site == Hd {
    /// The default "Foundation" theme that Publish ships with, a very
    /// basic theme mostly implemented for demonstration purposes.
    static var hd: Self {
        Theme(
            htmlFactory: HdHTMLFactory(),
            resourcePaths: ["Resources/HdTheme/hdstyles.css"]
        )
    }

}

//MARK: - These pages are built with Plot and then AddPage

extension PublishingStep where Site == Hd {
    static func allsteps () throws -> [PublishingStep<Hd>] {
     return [try makeTestPageStep(), try makeMembersPageStep(),addSectionTitlesStep()]
    
    }

    static func makeTestPageStep ( ) throws -> Self {
        return PublishingStep<Hd>.addPage(Page(path:"/test",
                                               content: Content(title:"test test", description:"this is just a test" )))
    }
    static func makeMembersPageStep ( ) throws -> Self {
        return PublishingStep<Hd>.addPage(Page(path:"/about",
                                               content: Content(title:"ABHD Members", description:"The members of ABHD" )))
    }
        static func addSectionTitlesStep() -> Self {
            .step(named: "Default section titles") { context in
                context.mutateAllSections { section in
                    guard section.title.isEmpty else { return }
                    
                    switch section.id {
                    case .audiosessions:
                        section.title = "Audio"
                    case .specialpages:
                        section.title = "Favorites"
                    case .about:
                        section.title = "About"
                        
                    }
                }
            }
        }
         
}

//MARK: - the  Publish addPage call comes here where we can generate custom HTML using plot for these spcial pages

extension HdHTMLFactory {
    func makePageHTML(for page: Page,
                      context: PublishingContext<Hd>) throws -> HTML {
        
        var result : HTML
        switch page.path {
            
        case "/about":  result = HdHTMLFactory.htmlForMembersPage(for:page,context:context)
            
        case "/test" : result =  HdHTMLFactory.htmlForTestPage(for:page,context:context)
            
        default: fatalError("cant make page for \(page.title)")
        }
        return result
    }
    
    static   func htmlForTestPage(for page: Page,
                                  context: PublishingContext<Site>) -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(.h2(.text("TEST PAGE"))),
                .footer(for: context.site)
            )
        )
    }
    
    static   func htmlForMembersPage(for page: Page,
                                     context: PublishingContext<Site>) -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h2("Who Are We?"),
                    .div(
                        .img(.src("/images/roseslogo.png"))),
                    .span("We play in \(Hd.default_venue_description)") ,
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
                    
                ),
                .footer(for: context.site)
            )
        )
    }
    
}


private struct HdHTMLFactory: HTMLFactory {
    
    
    
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Hd>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(.text(index.title)),
                    .p(
                        .class("description"),
                        .text(context.site.description)
                    ),
                    .h2("Home Sweet Home")
                    //                    .itemList(
                    //                        for: context.allItems(
                    //                            sortedBy: \.date,
                    //                            order: .descending
                    //                        ),
                    //                        on: context.site
                    //                    )
                ),
                .footer(for: context.site)
            )
        )
    }
    
    
    func makeSectionHTML(for section: Section<Hd>,
                         context: PublishingContext<Hd>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: section.id),
                .wrapper(
                    .h1(.text(section.title)),
                    .itemList(for: section.items, on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }
    
    func makeItemHTML(for item: Item<Hd>,
                      context: PublishingContext<Hd>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .class("item-page"),
                .header(for: context, selectedSection: item.sectionID),
                .wrapper(
                    .article(
                        .div(
                            .class("content"),
                            .contentBody(item.body)
                        ),
                        .span("Tagged with: "),
                        .tagList(for: item, on: context.site)
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
    
    
    
    
    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Hd>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1("Browse all tags"),
                    .ul(
                        .class("all-tags"),
                        .forEach(page.tags.sorted()) { tag in
                            .li(
                                .class("tag"),
                                .a(
                                    .href(context.site.path(for: tag)),
                                    .text(tag.string)
                                )
                            )
                        }
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
    
    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Hd>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(
                        "Tagged with ",
                        .span(.class("tag"), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .itemList(
                        for: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}

private extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }
    
    static func header<T: Website>(
        for context: PublishingContext<T>,
        selectedSection: T.SectionID?
    ) -> Node {
        let sectionIDs = T.SectionID.allCases
        
        return .header(
            .wrapper(
                .a(.class("site-name"), .href("/"), .text(context.site.name)),
                .if(sectionIDs.count > 1,
                    .nav(
                        .ul(
                            .li(.a(
                                .href("/tags"),
                                .text("Tags"))),
                            .li(.a(
                                .href("/specialpages"),
                                .text("Favorites"))),
                            .li(.a(
                                .href("/about"),
                                .text("Contact"))),
                            .li(.a(
                                .href("/audiosessions"),
                                .text("Audio")))
                            
                        )
                    )
                )// if
            )//wrapper
        )
    }
    
    static func itemList<T: Website>(for items: [Item<T>], on site: T) -> Node {
        return .div(//.p(.text("itemlist preamble")),
            .ul(
                .class("item-list"),
                .forEach(items) { item in
                    .li(.article(
                        .h1(.a(
                            .href(item.path),
                            .text(item.title)
                            )),
                        .tagList(for: item, on: site),
                        .p(.text(item.description))
                        ))
                    
                }
            )
        )
    }
    
    static func tagList<T: Website>(for item: Item<T>, on site: T) -> Node {
        return .div(//.p(.text("taglist preamble")),
            .ul(.class("tag-list"), .forEach(item.tags) { tag in
                .li(.a(
                    .href(site.path(for: tag)),
                    .text(tag.string)
                    ))
                }))
    }
    
    static func footer<T: Website>(for site: T) -> Node {
        let now = "\(Date())".dropLast(9)
        return .footer(
            .p(
                .text("Generated using "),
                .a(
                    .text("Publish"),
                    .href("https://github.com/johnsundell/publish")
                ),
                .text(" and "),
                .a( .text("LinkGrubber"),
                    .href("https://github.com/johnsundell/publish")
                ),
                
                .p(.a(
                    .text("last updated \(now)")
                    ))
            )
        )
    }
}