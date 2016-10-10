# NSIT Connect for iOS

### Download from App Store
[![](https://owncloud.org/wp-content/themes/owncloudorgnew/assets/img/clients/buttons/appstore.png)](https://itunes.apple.com/in/app/nsit-connect/id1122111525)


NSIT Connect is the official NSITOnline app that aims to act as a companion app for NSIT students. The app contains several useful modules like staying up-to-date with all the college news, maintaining a schedule according to the timetable, all the information related to interesting places of the college, and more.

But this project is a lot more than an app. This is an initiative that is targetted at all the emerging developers of NSIT and encourages them to take part in this as a collaborative open-source team effort. So if you are an NSITian and you love developing things and wish to see them used by a large number of people, you have come to the right place. 

+ **[App Store Link](https://itunes.apple.com/in/app/nsit-connect/id1122111525)**
+ **[NSITonline](http://www.nsitonline.in)**
+ **[Features](#features)**
  + [NSITOnline News Feed](#1nsitonline-news-feed)
  + [My Feed](#2my-feed)
  + [Video](#3video)
  + [Professors](#4professors)
  + [CodeRadar](#5coderadar)
  + [Hangouts](#6hangouts)
  + [Percentage Calculator](#7percentage)
  + [New Feature](#new-feature)
+ **[APIs Used](#apis-used)**
+ **[Libraries used](#libraries-used)**
+ **[Contribution](#how-to-contribute)**
+ **[Other repositories](#other-repositories)**
  + [Android](https://github.com/Swati4star/NSIT-App-v2)
  + [Windows](https://github.com/sgaggarwal2009/NSIT-Connect-Microsoft-App)
+ **[Project Maintainers](#project-maintainers)**



## Features
###1.NSITOnline News Feed
This is the news feed of the NSIT Online Facebook page. Posts can be refreshed by pulling down the table view and scrolling to the bottom loads the next 20 posts. The user can view the text and image (if any) of the associated post by tapping on the cell. High resolution images can be viewed and saved to the camera roll. The posts are cached for offline storage.

<img src="https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.30.25%20PM.png" height="400">

###2.My Feed
A customised feed which allows the user to select societies to view feeds of. Images can be viewed in full resolution and saved to the camera roll. Supports offline caching like the home feed.

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.30.57%20PM.png" height = 400>

###3.Video
[Junnon Photography Club's YouTube channel](https://www.youtube.com/channel/UCu445B5LTXzkNr5eft8wNHg) is the source of all entertainment going on in the college. No one wants to miss out on them, so this feed gets you the latest uploads and also allows you to view them right there in the app. 

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.02%20PM.png" height = 400>

###4.Professors
Consists of the contact details of professors organised by branch/division. Users can contact professors via phone or email (if available) directly from the app.

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.11%20PM.png" height = 400>

###5.Coderadar
CodeRadar is a Coding Contest Reminder that lets you keep track of all ongoing and upcoming contests on various online judges like Codechef,Topcoder,CodeForces,URIoj,HackerRank,etc..  you can filter the online judges you want to see, set reminders and do many more stuff..Happy Coding :)

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.07%20PM.png" height = 400>

###6.Hangouts
Shows user's places of interest within a selected range. Users can get directions from the Google Maps website (or app, if installed). 

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.26%20PM.png" height = 400>

###7. Percentage Calculator
Allows students to calculate their semester and aggregate percentage. They can also review their progress through the provided chart.

<img src = "">

###New Feature
- Changed the design of the feed page to mimic FB Instant Articles and added album viewing support

<img src = "http://i.giphy.com/c8dbbOPRbPiLu.gif" height = 400>


##APIs Used

###1. Facebook Graph api
```
https://graph.facebook.com/(Insert Page ID )/posts?limit=20&fields=id,full_picture,picture,from,shares,attachments,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=(Insert API Key)
```
JSON data for various Facebook pages can be downloaded by using different page IDs. For example, the page ID of NSIT Online's Facebook page is '109315262061'. 

###2. Youtube Data api
```
https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=(Playlist ID )&key=(API Key)
```
JSON data for a Youtube playlist with a given playlist ID can be downloaded using this API. From the data received, we can extract a video's ID and URL along with other relevant information. This video ID is passed to an instance of Youtube Embedded Player to load and play the video.

###3. Hackerrank api
```
https://www.hackerrank.com/calendar/feed.json
```
This API is used to fetch online judge contest information such as URL, start time, end time, description etc.

###4. Google Places api
```
https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(Range)&types=\(Type)&sensor=true&key=(API Key)
```
This API allows us to fetch JSON data containing places of interest within a given radius (Range) from the user's current location (latitude and longitude).

##Libraries used:

####1. SWRevealViewController
For creating a swipe-style menu (https://github.com/John-Lluch/SWRevealViewController)

####2. SDWebImage
Popular asynchronous image downloading library (https://github.com/rs/SDWebImage)

####3. NYAlertViewController
Add customised alert view controllers (https://github.com/nealyoung/NYAlertViewController)

####4. YTPlayerView
Embed Youtube videos in iOS apps (https://github.com/youtube/youtube-ios-player-helper)

####5. Toast
Display 'toast' messages (https://github.com/scalessec/Toast)

##How to contribute?
You'll need:
- A mac with OSX El Capitan or later. Don't fret if you don't have a mac! You can run OSX on your Windows PC using Virtual Box. If you like tinkering with your computer, dual boot via Hackintosh
- To learn an iOS programming language(Obj-C or Swift)from a popular online course or book like 'The Big Nerd Ranch Guide'. (This project has been written using Swift 2.2)
- Install Xcode
- To build, fork the repository or download the zip to your computer. If you get a cocoapod error (when a certain dependency can't be found), run pod install for the pods mentioned above and you'll be good to go!

##Other Repositories
- Android : https://github.com/Swati4star/NSIT-App-v2
- Windows 10 : https://github.com/sgaggarwal2009/NSIT-Connect-Microsoft-App

#Project Maintainers
This project is actively maintained by [Swapnil Dhanwal](github.com/Swapnil52). For queries, please send an email to swapnildhanwal@hotmail.com

