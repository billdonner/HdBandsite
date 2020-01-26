//
//  Theme+Hd.swift
//  
//
//  Created by william donner on 1/13/20.
//
import Foundation
import Publish
import Plot
import GigSiteAudio
import LinkGrubber


// these are pages that are built from swift code that is run before we call Publish...

extension Theme where Site == Hd {
    // a custom theme for bands
    static var hd: Self {
        Theme(
            htmlFactory: HdHTMLFactory(),
            resourcePaths: bandfacts.resourcePaths
        )
    }
}



//MARK: - these are all wired to Hd

struct HdHTMLFactory: HTMLFactory {
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
                                .class("tag"),  .a(.href(context.site.path(for: tag)),
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
                            .a(.href("/BigData/bigdata.csv"),
                               .text("CSV for data anaylsis")) ),
                    .li(    .class("reftag"),
                            .a(.href("/BigData/bigdata.json"),
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
            
        case "/about":  result = htmlForMembersPage(for:page,context:context)
            
        case "/test" : result =  htmlForTestPage(for:page,context:context)
            
        default: fatalError("cant makePageHTML for \(page) context:\(context.site.name)")
        }
        return result
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
                .a( .text("LinkGrubber"),  .href("https://github.com/billdonner/linkgrubber")
                ),
                .i(" updated \(now)")
            ))
    }
}


////



extension SortOrder {
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
//MARK: - These pages are built with Plot and then AddPage
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
        return x.dropLast((x.count-max)>0 ? x.count-max : 0)
    }
}

