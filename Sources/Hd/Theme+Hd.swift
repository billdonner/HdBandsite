//
//  Theme+Hd.swift
//  
//
//  Created by william donner on 1/13/20.
//
import Foundation
import Publish
import Plot

func publishBandSite() {
    do {
        let steps = try PublishingStep<Hd>.allsteps()
        try Hd().publish(withTheme: .hd, additionalSteps:steps)
    }
    catch {
        print("[crawler] could not publish \(error)")
    }
}
extension Theme where Site == Hd {
    // a custom theme for bands
    static var hd: Self {
        Theme(
            htmlFactory: BandsiteHTMLFactory(),
            resourcePaths: bandfacts.resourcePaths
        )
    }
    private struct BandsiteHTMLFactory: HTMLFactory {
       
        
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
        
            func makeIndexHTML(for index: Index,
                                    context: PublishingContext<Site>) throws -> HTML {
            
            let indexUpper = Node.div(
                 .h1(.text("About Half Dead Home")),
                 .p(
                     .class("description"),
                     .text("New Home for  About Half Dead")
                 ),
                 .h2("Recent Posts")
             )
            
               let indexLower = Node.div(
                   .h4("Data Assets"),
                   .ul(
                       .li(    .class("reftag"),
                               .a(.href("/BigData/bigdata.csv"),
                                  .text("CSV for data anaylsis")) ),
                       .li(    .class("reftag"),
                               .a(.href("/BigData/bigdata.json"),
                                  .text("JSON for apps")) ),
                       .li(    .class("reftag"),
                               .a(.href("/sitemap.xml"),
                                   .text("Sitemap")) ),
                       .li(    .class("reftag"),
                               .a(.text("RSS feed"),
                                  .href("/feed.rss")))
                   )
               )
            
            
           return HTML(
                .lang(context.site.language),
                .head(for: index, on: context.site,stylesheetPaths:["/hdstyles.css"]),
                .body(
                    .header(for: context, selectedSection: nil),
                    .wrapper(
                        indexUpper,
                        
                        .itemList( for: context.someItems(max:5, sortedBy: \.date,
                                                          order: .descending
                            ),
                                   on: context.site
                        ),
                        
                      indexLower,
                        
                        .footer(for: context.site)
                    )
                )
            )
        }

        
        
            func makePageHTML(for page: Page,
                                   context: PublishingContext<Site>) throws -> HTML {
          
                return    HTML(
                                .lang(context.site.language),
                                .head(for: page, on: context.site,
                                stylesheetPaths: ["/hdstyles.css"]),
                                .body(
                                    .header(for: context, selectedSection: nil),
                                    .wrapper(.contentBody(page.body)),
                                    .footer(for: context.site)
                                )
                            )
            }
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
                    .nav( .ul (
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
        ////let sourceurl = site.item.metadata
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


