//
//  Website.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Publish
import Plot 
import LinkGrubber



// MARK: - Add Publishing Steps to Make the Specific Custom Pages We Need
extension PublishingStep where Site == Hd {
    static var newpages:[Page]=[]

    static func allsteps () throws -> ([PublishingStep<Site>]) {
        return ([PublishingStep<Site>.addPages(in: newpages),
            addSectionTitlesStep()])
    }
   
    private static func makePage ( title:String,description:String,path:String,node:Node<HTML.BodyContext> )  {
        let y = Content.Body(node:node )
        let z = Content(title:title,description:description,body:y)
        newpages.append(Page(path:Path(path),  content: z ))
    }
    
    private static func makeMembersPageStep ( )  {
         makePage(title:"Member Page",
                     description:"This is the members page",
                     path:"/about",node:
            Node.div(
            .h2("Who Are We?"),
            .img(.src("/images/roseslogo.png")),
            .span("We play in Thornwood"),
            .ul(
                .li(.dl(
                    .dt("Anthony"),
                    .dd("Rhythm Guitar and ",.strong( "Vocals"))),
                    .img(.src("/images/hd-anthony.jpg"))),
                
                .li(.dl(
                    .dt("Bill"),
                    .dd("Keyboards")),
                    .img(.src("/images/hd-bill.jpg"))),
                
                .li(.dl(
                    .dt("Brian"),
                    .dd("Drums ", .s("and Vocals"))),
                    .img(.src("/images/hd-brian.jpg"))),
                
                .li(.dl(
                    .dt("Mark"),
                    .dd("Lead Guitar and ", .ins("Vocals"))),
                    .img(.src("/images/hd-mark.jpg"))),
                
                .li(.dl(
                    .dt("Marty"),
                    .dd("Bass")),
                    .img(.src("/images/hd-marty.jpg")))),
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
            )))
    }
    private  static func makeFavoritePageStep ()    {
      makePage(title: "Everyone's Favorites",
                  description:"This is Everyone's Favorites page",
                  path:"/favorites",
                  node:Node.div(
        .h2("Band's Favorite Cuts"),
        .ul(
            .li(.a(.class("site-name"), .href("/favorites/bill"), .text("Bill's Favorites 2019"))), 
            .li(.a(.class("site-name"), .href("/favorites/brian"), .text("Brian's Favorites 2019")))
        ),
        .img(.src("/images/roseslogo.png"))))
    }
    private  static func makeBillsPageStep ( )  {
          makePage(title: "Bill's Page",
                     description:"This is Bill's Favorites page",
                     path:"/favorites/bill",
                     node:Node.div(
            .h2("Bill's Favorites 2019"),
            .img(.src("/images/roseslogo.png")),
            .span("We play in Thornwood"),
            .ul(
                .li(.dl(
                    .dt("Light My Fire"),
                    .dd("Nov 19" )),
                    .img(.src("/images/hd-anthony.jpg")),
                    .audio(.controls(true),
                           .source(
                            .src("https://billdonner.com/halfdead/2019/11-19-19/06%20-%20Light%20My%20Fire.MP3"),
                            .type(.wav)))),
                
                .li(.dl(
                    .dt("Riders On The Storm"),
                    .dd("Keyboards")),
                    .img(.src("/images/hd-bill.jpg"))),
                
                .li(.dl(
                    .dt("In Memory Of Elizabeth Reed"),
                    .dd("Drums ", .s("and Vocals"))),
                    .img(.src("/images/hd-brian.jpg"))),
                
                .li(.dl(
                    .dt("China > Rider"),
                    .dd("Lead Guitar and ", .ins("Vocals"))),
                    .img(.src("/images/hd-mark.jpg"))),
                
                .li(.dl(
                    .dt("Friend Of The Devil"),
                    .dd("Bass")),
                    .img(.src("/images/hd-marty.jpg"))))))
    }
    private  static func makeBriansPageStep ( )    {
             makePage(title: "Brian's Page",
                          description:"This is Brian's Favorites page",
                          path:"/favorites/brian",
                          node: Node.div(
            .h2("Brian's Favorites 2019"),
            .img(.src("/images/roseslogo.png")),
            .span("No cookies here"),
            .ul(
                .li(.dl(
                    .dt("Light My Fire"),
                    .dd("Nov 19" )),
                    .img(.src("/images/hd-anthony.jpg")),
                    .audio(.controls(true),
                           .source(
                            .src("https://billdonner.com/halfdead/2019/11-19-19/06%20-%20Light%20My%20Fire.MP3"),
                            .type(.wav)))),
                .li(.dl(
                    .dt("Riders On The Storm"),
                    .dd("Keyboards")),
                    .img(.src("/images/hd-bill.jpg"))),
                
                .li(.dl(
                    .dt("In Memory Of Elizabeth Reed"),
                    .dd("Drums ", .s("and Vocals"))),
                    .img(.src("/images/hd-brian.jpg"))),
                
                .li(.dl(
                    .dt("China > Rider"),
                    .dd("Lead Guitar and ", .ins("Vocals"))),
                    .img(.src("/images/hd-mark.jpg"))),
                
                .li(.dl(
                    .dt("Friend Of The Devil"),
                    .dd("Bass")),
                    .img(.src("/images/hd-marty.jpg"))))))
    }
    
    private  static func addSectionTitlesStep() -> Self {
        .step(named: "Default section titles") { context in
            context.mutateAllSections { section in
                guard section.title.isEmpty else { return }
                switch section.id {
                case .audiosessions:
                    section.title = "All The Audio"
                case .favorites:
                    section.title = "Half Favorites"
                case .about:
                    section.title = "Half About"
                case .blog:
                    section.title = "Half Blog"
                }
            }
        }
    }
}
