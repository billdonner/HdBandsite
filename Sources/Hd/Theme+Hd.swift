//
//  File.swift
//  
//
//  Created by william donner on 1/13/20.
//
import Foundation
import Publish
import Plot


public extension Theme {
    /// The default "Foundation" theme that Publish ships with, a very
    /// basic theme mostly implemented for demonstration purposes.
    static var hd: Self {
        Theme(
            htmlFactory: HdHTMLFactory(),
            resourcePaths: ["Resources/HdTheme/hdstyles.css"]
        )
    }
}

private struct HdHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
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

    func makeSectionHTML(for section: Section<Site>,
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

    func makeItemHTML(for item: Item<Site>,
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

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(

                ),
                .footer(for: context.site)
            )
        )
    }

    func makeTagListHTML(for page: TagListPage,
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
                            
                            
//                        .forEach(sectionIDs) { section in
//                            .li(.a(
//                                .class(section == selectedSection ? "selected" : ""),
//                                .href(context.sections[section].path),
//                                .text(context.sections[section].title)
//                            ))
//                            }
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
/**
 
 extension Theme where Site == Hd {
     static var hd: Self {
         Theme(htmlFactory: HdHTMLFactory())
     }
     private struct HdHTMLFactory: HTMLFactory {
         func makeIndexHTML(for index: Index, context: PublishingContext<Hd>) throws -> HTML {
             
         }
         
         func makeSectionHTML(for section: Section<Hd>, context: PublishingContext<Hd>) throws -> HTML {
             <#code#>
         }
         
         func makePageHTML(for page: Page, context: PublishingContext<Hd>) throws -> HTML {
             <#code#>
         }
         
         func makeTagListHTML(for page: TagListPage, context: PublishingContext<Hd>) throws -> HTML? {
             return nil
         }
         
         func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Hd>) throws -> HTML? {
            return nil
         }
         
         
         


         func makeItemHTML(for item: Item<Hd>,
                           context: PublishingContext<Hd>) throws -> HTML {
             HTML(
                 .lang(context.site.language),
                 .head(for: item, on: context.site),
                 .body(
                     .class("item-page"),
 //                    .header(for: context, selectedSection: item.sectionID),
 //                    .wrapper(
 //                        .article(
 //                            .div(
 //                                .class("content"),
 //                                .contentBody(item.body)
 //                            ),
 //                            .span("Tagged with: "),
 //                            .tagList(for: item, on: context.site)
 //                        )
 //                    ),
                     .p("FOOBAR"),
                       .contentBody(item.body)
                     //  .footer(for: context.site)
                 ),
                                          .span("Tagged with: "),
                                           .tagList(for: item, on: context.site)
             )
         }
     }
 }
 */
