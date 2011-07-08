Introduction
============

*g3Mobile* is an iPhone app that brings all your pictures from [gallery3](http://gallery.menalto.com) to your iPhone.  

*g3Mobile* focuses on a smooth browsing experience and comes with some basic features that include  
*image uploading* and *adding/modifying/deleting/commenting* of albums & items.

Functionality:
--------------
- Basic Login/logout
- Tableview & Thumbview to browse the gallery
- Create albums
- Modify albums
- Reordering of album / images per drag&drop
- Delete functionality for albums and photos
- Image upload from library & camera (w/ optional caption)
- Full offline support
- Full caching to boost performance
- Async. load of album & images
- Simple slideshow (basic)
- Add/deletion of Comments (basic)

For testers: How do I get it?
-----------------------------
1. Do you meet the prerequisites?
   - You must have at least iOS version (**4.3**)
   - You must be on the latest [gallery3](http://gallery.menalto.com) version (**3.0.2**)
   - You must have the *REST API Module* enabled
2. Contact the author/developer aka *me* :-)
   - Send me an email address that you are checking on your iPhone (PM or email me)
   - You will receive an email from [TestFlight](http://testflightapp.com) that allows you to register your device
   - Once done, You will receive email notifications for each new build.  
     You can then install/upgrade *over-the-air* (directly from your iPhone).
3. Use this [Gallery 3.x forum](http://gallery.menalto.com/node/99385) to provide feedback

For developers: How can I get it to build & run?
------------------------------------------------
###Setup Gallery3
1. Install Gallery3:  
   - See [Gallery3](http://gallery.menalto.com/gallery_3.0.2_released)
2. Enable the *REST API Module*:
   - Go to *Admin->Modules* and check-on *REST API Module* and hit *Update*
3. Create/modifiy a user for the mobile-client:  
   - Go to *Admin->Users/Groups* and create a user (and a group)
   - Go back and grant this user-group rights
   
###Setup the development environment
1. Install latest Xcode 4 + SDK:  
   - Download from [Apple](http://developer.apple.com/devcenter/ios/index.action)
2. Install Git:
   - See e.g. [MacPorts](http://www.macports.org)

###Get the code
1. Get the latest *three20* library:  
   - `git clone git://github.com/facebook/three20.git;`
2. Checkout tag 1.0.5:  
   - `cd three20; git checkout 1.0.5; cd ..;`
3. Get the latest g3Mobile code:  
   - `git clone git://github.com/dave8401/g3Mobile.git;`
   - `cd g3Mobile; git submodule init; git submodule update;`
    
**NOTE**: The *three20*- and the *g3Mobile*-folder MUST be in the same parent directory!

###Run it
1. Fire up *g3Mobile.xcodeproj* and hit the *Build and Debug*-button
2. Enjoy and contribute with new ideas, code, testing, ...