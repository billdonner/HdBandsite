//
//  customHTML.swift
//  
//
//  Created by william donner on 1/15/20.
//

import Foundation
import Plot
import Publish


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
                .p(.a(
                    .text("last updated \(now)")
                    ))))
    }
}
