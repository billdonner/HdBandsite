import Foundation
import Publish
import Plot
import GigSiteAudio
import LinkGrubber
// standard BandSite Parameters

 let bandfacts = AudioSiteSpec(
    venueShort: "thorn",
    venueLong: "Highline Studios, Thornwood, NY",
    crawlTags: ["china" ,"elizabeth" ,"whipping" ,"one more" ,"riders" ,"light"],
    pathToContentDir: "/Users/williamdonner/hd/Content",
    pathToOutputDir: "/Users/williamdonner/hd/Resources/BigData",
    pathToResourcesDir: "/Users/williamdonner/hd",
    matchingURLPrefix:  "https://billdonner.com/halfdead" ,
    specialFolderPaths: ["/audiosessions","/favorites"],
    language: Language.english,
    url: "http://abouthalfdead.com",
    name: "About Half Dead ",
    shortname: "ABHD",
    description:"A Jamband Featuring Doors, Dead, ABB Long Form Performances",
    titleForAudioSessions:"All The Audio",
    titleForFavoritesSection:"Band Favorites",
    titleForBlog:"ABHD Blog",
    titleForMembersPage:"ABHD Members ",
    resourcePaths:   ["Resources/HdTheme/hdstyles.css"],
    imagePath:  Path("images/ABHDLogo.png") ,
    favicon:  Favicon(path: "images/favicon.png")
)

// places to test, or simply to use
func standard_testing_roots(c:String)->String {
    let rooturl:String
switch c {
case "s": rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
case "m": rooturl =  "https://billdonner.com/2019/"
case "l": rooturl =  "https://billdonner.com/halfdead/"
default:  rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
}
    return rooturl
}




extension SOB {
   static func htmlForTestPage(for page: Page,
                              context: PublishingContext<Hd>) -> HTML {
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

   static  func htmlForIndexPage(for index: Index,context:PublishingContext<Hd>) -> HTML {
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

  static  func htmlForMembersPage(for page: Page,
                                 context: PublishingContext<Hd>) -> HTML {
    HTML(
        .lang(context.site.language),
        .head(for: page, on: context.site,stylesheetPaths:["/hdstyles.css"]),
        .body(
            .header(for: context, selectedSection: nil),
            .wrapper(
                .h2("Who Are We?"),
                .div(
                    .img(.src("/images/roseslogo.png"))),
                .span("We play in \(bandfacts.venueLong)") ,
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
                        .img(.src("/images/hd-marty.jpg")))
                    
                ),// ends ul
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


// custom pages for BandSite

extension PublishingStep where Site == Hd {
    
    static var allpagefuncs:[()throws->() ] = []//[addBillsFavorites,addBriansFavorites]
    
    static func addBillsFavorites() throws {
        let props = CustomPageProps(isInternalPage: true, urlstr: "grubber://mumble012/custom/bill/bills-best-2019/",
                                              title: "Bill's Best 2019",
                                              tags: ["favorites"])
        let links = [
            Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"favorite of all time"),
            Fav(name: "riders",url: "https://billdonner.com/foobly/riders.mp3",comment:"best of the year")
        ]
        try BandSitePrePublish.addFavoritePage(links: links, props: props)
        allpagefuncs.append(addBillsFavorites)
        print("[crawler] adding Bills Favorites")
    }
    
    static func addBriansFavorites() throws {
        let props = CustomPageProps(isInternalPage: true,urlstr: "grubber://mumble012/custom/brian/brians-favorites-2018/",
                                              title: "Brians's Best 2019",
                                              tags: ["favorites"])
        
        let links = [
            Fav(name: "light my fire",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"not exactly my taste"),
            Fav(name: "riders",url: "https://billdonner.com/foobly/lightmyfire.mp3",comment:"I like the drumming")
        ]
           try BandSitePrePublish.addFavoritePage(links: links, props: props)
        allpagefuncs.append(addBriansFavorites)
        print("[crawler] adding Brians Favorites")
    }
}


// starts here
command_main(crawler:Hd.audioCrawler)


/////
