# The AboutHalfDead.com WebSite Publisher Lives Here
Amen

<p align="center">
<img src="https://billdonner.com/images/hdsite/HdSite1024x1024.png" width="300" max-width="90%" alt="Publish" />
</p>

#### Scan Music and Build A New Site

This is a Swift Package that generates a specfic site for a working band, in this case AboutHalfDead.com

- [gigaudiosite](https://github.com/billdonner/GigSiteAudio) builds markdown assets for any band
- [linkgrubber](https://github.com/billdonner/LinkGrubber) scans remote sites for music files
- [Publish](https://github.com/JohnSundell/Publish) static site generator in Swift

## How It Works

Here's the basic plan:

### After a Recording Session Music Files are Uploaded Via FTP
The Audio Engineer uploads them into http://AboutHalfDead.com/audio/YEAR/MM-DD-YY
Custom images and text can also be placed in these directories to affect the visuals for the playback page of the session. Specifications are at https://github.com/billdonner/GigSiteAudio

###  This Program is Run To Generate A New Website

The Website has all of the new audio bits.  This program only runs under Xcode. The website can be viewed locally under at http://localhost:8000

### The New Static Web Site is Deployed to the AboutHalfDead.com domain via FTP

Once happy with the local version, the entire pile is uploaded back to the main domain. This effectively paves over everthing that was there before, so be very careful.





