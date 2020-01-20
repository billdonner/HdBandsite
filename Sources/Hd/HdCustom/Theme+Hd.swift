//
//  Theme+Hd.swift
//  
//
//  Created by william donner on 1/13/20.
//
import Foundation
import Publish
import Plot







extension Theme where Site == Hd {
    // a custom theme for bands
    static var hd: Self {
        Theme(
            htmlFactory: HdHTMLFactory(),
            resourcePaths: ["Resources/HdTheme/hdstyles.css"]
        )
    }
}
extension Hd {
//     static let default_venue_acronym : String = "thorn"
//     static let default_venue_description: String = "Highline Studios, Thornwood, NY"
//     static let crawlerKeyTags:[String] = ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light"]
//     static let pathToContentDir =  "/Users/williamdonner/hd/Content"
//     static let pathToResourcesDir = "/Users/williamdonner/hd"
//     static let matchingURLPrefix =  URL(string:"https://billdonner.com/halfdead")!
    

    
    static func crawler (_ c:String,finally:@escaping (Int)->()) {
        var configurl :URL?
        switch c {
        case "m": configurl = URL(string: "https://billdonner.com/linkgrubber/manifezz-medium.json")
        case "l": configurl = URL(string: "https://billdonner.com/linkgrubber/manifezz-full.json")
        default: configurl = URL(string: "https://billdonner.com/linkgrubber/manifezz-small.json")
        }
        guard let gurl = configurl else { finally(404); return }
        print("[crawler] executing \(gurl)")
        let _ = Crawler(configurl: gurl,
                        verbosity:  .none,
                        bandSiteParams: Hd.bandfacts,
                        specialFolderPaths: ["/favorites","/audiosessions"]) { status in // just runs
                           finally(status)
        }
    }
}



//MARK: - the  Publish addPage call comes here where we can generate custom HTML using plot for these spcial pages

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
}