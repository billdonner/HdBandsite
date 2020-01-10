
# The AboutHalfDead.com WebSite Content Lives Here

## How It Works

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

- css
- make it pretty
