//
//  customHTML.swift
//  
//
//  Created by william donner on 1/15/20.
//

import Foundation
import Plot
import Publish

internal extension SortOrder {
    func makeASorter<T, V: Comparable>(
        forKeyPath keyPath: KeyPath<T, V>
    ) -> (T, T) -> Bool {
        switch self {
        case .ascending:
            return {
                $0[keyPath: keyPath] < $1[keyPath: keyPath]
            }
        case .descending:
            return {
                $0[keyPath: keyPath] > $1[keyPath: keyPath]
            }
        }
    }
}
extension PublishingContext where Site == Hd  {
    /// Return someitems within this website, sorted by a given key path.
    ///  - parameter max: Max Number of items to return
    /// - parameter sortingKeyPath: The key path to sort the items by.
    /// - parameter order: The order to use when sorting the items.
    func someItems<T: Comparable>(max:Int,
                                  sortedBy sortingKeyPath: KeyPath<Item<Site>, T>,
                                  order: SortOrder = .ascending
    ) -> [Item<Site>] {
        let items = sections.flatMap { $0.items }
        let x = items.sorted(
            by: order.makeASorter(forKeyPath: sortingKeyPath))
        return x.dropLast(x.count-max)
        
    }
}
// 
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

extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }
    
    // this is the header for the whole site, customized
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
                                .href("/blog"),
                                .text("Blog"))),
                            .li(.a(
                                .href("/tags"),
                                .text("Tags"))),
                            .li(.a(
                                .href("/favorites"),
                                .text("Favorites"))),
                            .li(.a(
                                .href("/about"),
                                .text("About"))),
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
                        .p(.text(item.description)) ,
                        .tagList(for: item, on: site)
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
                }
            ))
    }
    
    static func footer<T: Website>(for site: T) -> Node {
        let now = "\(Date())".dropLast(9)
        return .footer(
            .p(
                .text("Generated using "),
                .a(
                    .text("Publish"),  .href("https://github.com/johnsundell/publish")
                ),
                .text(" and "),
                .a( .text("LinkGrubber"),  .href("https://github.com/johnsundell/publish")
                ),
                .i(" updated \(now)")
            ))
    }
}
extension HdHTMLFactory {
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
                        .text("New Home for  About Half Dead")
                    ),
                    
                    .h2("Recent Posts"),
                    .itemList( for: context.someItems(max:5, sortedBy: \.date,
                                                      order: .descending
                        ),
                               on: context.site
                    )),
                
                .h4("Data Assets"),
                .ul(
                    
                    .li(    .class("reftag"),
                            .a(.href("/bigdata.csv"),
                               .text("CSV for data anaylsis")) ),
                    .li(    .class("reftag"),
                            .a(.href("/bigdata.json"),
                               .text("JSON for apps")) ),
                    .li(    .class("reftag"),
                            .a(
                                .href("/sitemap.xml"),
                                .text("Sitemap")) ),
                    .li(    .class("reftag"),
                            .a(.text("RSS feed"),
                               .href("/feed.rss")))
                ),
                
                .footer(for: context.site)
            )
        )
    }
    
    
    
    func makePageHTML(for page: Page,
                      context: PublishingContext<Hd>) throws -> HTML {
        
        var result : HTML
        switch page.path {
            
        case "/about":  result = HdHTMLFactory.htmlForMembersPage(for:page,context:context)
            
        case "/test" : result =  HdHTMLFactory.htmlForTestPage(for:page,context:context)
            
        default: fatalError("cant makePageHTML for \(page) context:\(context.site.name)")
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
                    .h2( "Hire Us"),
                    .p("We Don't Play For Free"),
                    .form(
                        .action("mailto:bildonner@gmail.com"),
                        
                        .fieldset(
                            .label(.for("name"), "Name"),
                            .input(.name("name"), .type(.text), .autofocus(false), .required(true))
                        ),
                        .fieldset(
                            .label(.for("email"), "Email"),
                            .input(.name("email"), .type(.email), .autocomplete(true), .required(true))),
                        .fieldset(
                            .label(.for("comments"), "Comments"),
                            .input(.name("comments"), .type(.text) )
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
