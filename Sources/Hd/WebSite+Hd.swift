//
//  Website.swift
//  
//
//  Created by william donner on 1/10/20.
//

import Foundation
import Publish
import Plot
import GigSiteAudio
import LinkGrubber


// Standard BandSite Stuff


//public typealias CrawlingSignature =  ([RootStart] , @escaping (Int)->()) -> ()

// This type acts as the configuration for your website.
// On top of John Sundell's configuration, we have everything else that's needed for LinkGrubber, etc


// open class
public struct Hd: Website {
     //public static var bandfacts: BandSiteFacts!
    // public static var xlgFuncs: LgFuncs!
    

    public enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case about
        case favorites
        case audiosessions
        case blog
    }
    
   public  struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
        // var flotsam : TimeInterval = 0
        //var venue: String?
        //var date: String?
        var sourceurl: String?
    }
    
    // Update these properties to configure your website:
   public var url =  URL(string:bandfacts.url)!
   public var name =  bandfacts.name// + "\(Date())".dropLast(14)
   public var description =  bandfacts.description
   public var language =  bandfacts.language
   public var imagePath =   bandfacts.imagePath
   public var favicon =  bandfacts.favicon
  
}


extension PublishingStep where Site == Hd {
    static func allsteps () throws -> ([PublishingStep<Hd>]) {
        return ([
                 try makeFavoritePageStep(),
                     try makeMembersPageStep(),
                     try makeBillsPageStep(),
                     try makeBriansPageStep(),
                     addSectionTitlesStep()])
        }

        static func makePageStep (node:Node<HTML.BodyContext>, title:String,description:String,path:String ) throws -> Self {
            let y = Content.Body(node:node )
            let z = Content(title:title,description:description,body:y)
            return PublishingStep<Hd>.addPage(Page(path:Path(path),  content: z ))
        }
        
        static func makeMembersPageStep ( ) throws -> Self {
            let memberPageFull = Node.div(
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
                )
            )
          return  try makePageStep(node:memberPageFull ,title:"Member Page",description:"This is the members page", path:"/about")
            
        }
        static func makeFavoritePageStep () throws -> Self {
        let xyz = Node.div(
            .h2("Band's Favorite Cuts"),
            .ul(
                .li(.a(.class("site-name"), .href("/favorites/bill"), .text("Bill's Favorites 2019"))),
                
                .li(.a(.class("site-name"), .href("/favorites/brian"), .text("Brian's Favorites 2019")))
                
                ),
            .img(.src("/images/roseslogo.png")))
        
         return try makePageStep(node:xyz ,title: "Everyone's Favorites",description:"This is Everyone's Favorites page", path:"/favorites")
       
        
    }
    static func makeBillsPageStep ( ) throws -> Self {
        let billsFavorite = Node.div(
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
                    .img(.src("/images/hd-marty.jpg")))))
        
      return try makePageStep(node:billsFavorite ,title: "Bill's Page",description:"This is Bill's Favorites page", path:"/favorites/bill")
       
    }
    static func makeBriansPageStep ( ) throws -> Self { 
        let briansFavorite = Node.div(
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
                    .img(.src("/images/hd-marty.jpg")))))
    return  try makePageStep(node:briansFavorite ,title: "Brian's Page",description:"This is Brian's Favorites page", path:"/favorites/brian")
 
      }

    static func addSectionTitlesStep() -> Self {
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
