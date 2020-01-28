import Foundation
import Publish
import Plot
import BandSite


//
struct Swatches {
    
    let topNavStuff = Node.ul (
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
}// end of custom


let swatches = Swatches()
// starts here


let bandfacts = BandSiteFacts(
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
    indexUpper: swatches.indexUpper,
    indexLower:  swatches.indexLower,
    memberPageFull: swatches.memberPageFull,
    topNavStuff:     swatches.topNavStuff,
    allFavorites: [swatches.billsFavorite,swatches.briansFavorite],
    imagePath:  Path("images/ABHDLogo.png") ,
    favicon:  Favicon(path: "images/favicon.png")
)
    
    // places to test, or simply to use
    func command_rewriter(c:String)->String {
        let rooturl:String
        switch c {
        case "s": rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
        case "m": rooturl =  "https://billdonner.com/halfdead/2019/"
        case "l": rooturl =  "https://billdonner.com/halfdead/"
        default:  rooturl =  "https://billdonner.com/halfdead/2019/01-07-19/"
        }
        return rooturl
    }

bandsite_command_main(bandfacts:bandfacts,rewriter:command_rewriter)

let stepcount = Hd.publisher()
print("[crawler] Publish finished; steps:",stepcount)
