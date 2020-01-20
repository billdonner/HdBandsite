
# The AboutHalfDead.com WebSite Content Lives Here

 
<p align="center">
<img src="https://billdonner.com/images/grabnhand.png" width="300" max-width="90%" alt="Publish" />
</p>

## How It Works

Here's the basic plan:

### After a Recording Session, The Music Files are Uploaded Via FTP
The Audio Engineer uploads them into http://AboutHalfDead.com/audio/YEAR/MM-DD-YY
Custom images and text can also be placed in these directories to affect the visuals for the playback page of the session.

### When Activated, The LinkGrubber Crawls Looking for Music and Other Assets
All the resulting metadata is used to generated a set of Markdown files, one per Recording Session.

### The Publish/Plot Packages by John Sundell Are Used to Generate A Static WebSite
The Markdown files are Published using these Swift Packages. The result is a static website that can be deployed anywhere, or on localhost:8000

### The New Static Web Site is Deployed to the AboutHalfDead.com domain via FTP
Once happy with the local version, the entire pile is uploaded back to the main domain.
This effectively paves over everthing that was there before, so be very careful.

## Lots to Do

The Publish system seems to only run in an osx environment.

I tried to build a swiftui frontend but quickly realized that ShellOut wont work under non - osx platforms.

The Website that Publish builds is a swift Package and cant add targets to that so I built a plain mac app and try to hoist all this code into that but it still doesnt really work

So I am resolved to use this as is, right from here.



