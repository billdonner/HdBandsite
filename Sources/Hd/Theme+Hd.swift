//
//  Theme+Hd.swift
//  
//
//  Created by william donner on 1/13/20.
//
import Foundation
import Publish
import Plot

// these are pages that are built from swift code that is run before we call Publish...

extension Theme where Site == Hd {
    // a custom theme for bands
    static var hd: Self {
        Theme(
            htmlFactory: BandsiteHTMLFactory(),
            resourcePaths: Hd.bandfacts.resourcePaths
        )
    }
    private struct BandsiteHTMLFactory: HTMLFactory {
        public typealias Site = Hd
        
        public func makeSectionHTML(for section: Section<Site>,
                                    context: PublishingContext<Site>) throws -> HTML {
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
        
        public func makeItemHTML(for item: Item<Site>,
                                 context: PublishingContext<Site>) throws -> HTML {
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
        
        public  func makeTagListHTML(for page: TagListPage,
                                     context: PublishingContext<Site>) throws -> HTML? {
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
        
        public  func makeTagDetailsHTML(for page: TagDetailsPage,
                                        context: PublishingContext<Site>) throws -> HTML? {
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
        
        public   func makeIndexHTML(for index: Index,
                                    context: PublishingContext<Hd>) throws -> HTML {
            HTML(
                .lang(context.site.language),
                .head(for: index, on: context.site,stylesheetPaths:["/hdstyles.css"]),
                .body(
                    .header(for: context, selectedSection: nil),
                    .wrapper(
                        Hd.bandfacts.indexUpper,
                        
                        .itemList( for: context.someItems(max:5, sortedBy: \.date,
                                                          order: .descending
                            ),
                                   on: context.site
                        ),
                        
                        Hd.bandfacts.indexLower,
                        
                        .footer(for: context.site)
                    )
                )
            )
        }
//        func makePageHTML(for page: Page,
//                          context: PublishingContext<Site>) throws -> HTML {
//            HTML(
//                .lang(context.site.language),
//                .head(for: page, on: context.site),
//                .body(
//                    .header(for: context, selectedSection: nil),
//                    .wrapper(.contentBody(page.body)),
//                    .footer(for: context.site)
//                )
//            )
//        }
        
        
        
        public   func makePageHTML(for page: Page,
                                   context: PublishingContext<Hd>) throws -> HTML {
            
            var result : Node<HTML.BodyContext>
            switch page.path {
                
            case "/about":  result =  Hd.bandfacts!.memberPageFull
                
            case "/test" : result = Hd.bandfacts!.memberPageFull
                
                
                // regular MD pages come thru here
            default:
                
                return    HTML(
                                .lang(context.site.language),
                                .head(for: page, on: context.site),
                                .body(
                                    .header(for: context, selectedSection: nil),
                                    .wrapper(.contentBody(page.body)),
                                    .footer(for: context.site)
                                )
                            )
                
                
                //fatalError("cant make!PageHTML for \(page) context:\(context.site.name)")
            }
            
            
            //page.body = Content.Body(node: result)
            
            return  HTML(
                .lang(context.site.language),
                .head(for: page, on: context.site),
                .body(
                    .header(for: context, selectedSection: nil),
                      .wrapper(.contentBody(Content.Body(node: result))),
                    .footer(for: context.site)
                )
            )
        }
    }
    
    ///this would be best in downtown
    
    
    public static func htmlForTestPage(for page: Page,
                                       context: PublishingContext<Hd>) -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                Node.header(for: context, selectedSection: nil),
                .wrapper(.h2(.text("TEST PAGE"))),
                .footer(for: context.site)
            ))
    }
    
    public static func htmlForIndexPage(for index: Index,context:PublishingContext<Hd>) -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    Hd.bandfacts.indexUpper,
                    .itemList( for: context.someItems(max:5, sortedBy: \.date,
                                                      order: .descending
                        ),
                               on: context.site
                    )),
                
                Hd.bandfacts.indexLower,
                
                .footer(for: context.site)
            )
        )
        
    }
    
    
    public static func htmlForMembersPage(for page: Page,
                                          context: PublishingContext<Site>) -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    Hd.bandfacts.memberPageFull
                ),
                .footer(for: context.site)
            )
        )
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
                        Hd.bandfacts.topNavStuff
                    )
                )// if
            )//wrapper
        )
    }
    // rearranged .p and .taglist
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

