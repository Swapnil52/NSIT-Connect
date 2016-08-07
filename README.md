#NSIT Connect For iOS
-------------

The NSIT Connect app has been specially made for the students of Netaji Subhas Institute of Technology(NSIT) and also for the aspirants who want to join the college this year. This app has been developed to improve the mobile experience of the students and to keep them updated about the latest happenings of the college.

#Features
--------

1. Home
-------
This is the news feed of the NSIT Online Facebook page. Posts can be refreshed by pulling down the table view and scrolling to the bottom loads the next 20 posts. The user can view the text and image (if any) of the associated post by tapping on the cell. High resolution images can be viewed and saved to the camera roll. The posts are cached for offline storage.

<img src="https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.30.25%20PM.png" height="400">

2. My Feed
---------
A customised feed which allows the user to select societies to view feeds of. Images can be viewed in full resolution and saved to the camera roll. Supports offline caching like the home feed.

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.30.57%20PM.png" height = 400>

3. Videos
--------
Users can watch videos from 'Junoon-The Photography Society of NSIT's Youtube channel.

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.02%20PM.png" height = 400>

4. Professors
------------
Consists of the contact details of professors organised by branch/division. Users can contact professors via phone or email (if available) directly from the app.

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.11%20PM.png" height = 400>

5. Code Radar
----------
A time table of contests held on popular online programming judges including Topcoder, Codechef, Codeforces, Hackerrank and more. Users can view both, upcoming and running contests, view their descriptions and access the contest page.

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.07%20PM.png" height = 400>

6. Hangouts
--------
Shows users places of interest within a selected range. Users can get directions from the Google Maps website (or app, if installed). 

<img src = "https://github.com/Swapnil52/NSIT-Connect/blob/master/connectFinal/Screens/Simulator%20Screen%20Shot%2007-Aug-2016%2C%2010.31.26%20PM.png" height = 400>

#APIs Used
----------

1. Facebook Graph API
---------------------
```
https://graph.facebook.com/(Insert Page ID )/posts?limit=20&fields=id,full_picture,picture,from,shares,attachments,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=(Insert API Key)
```
JSON data for various Facebook pages can be downloaded by using different page IDs. For example, the page ID of NSIT Online's Facebook page is '109315262061'. 

2. Youtube Data API
------------------
```
https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=(Playlist ID )&key=(API Key)
```
JSON data for a Youtube playlist with a given playlist ID can be downloaded using this API. From the data received, we can extract a video's ID and URL along with other relevant information. This video ID is passed to an instance of Youtube Embedded Player to load and play the video.

3. Hackerrank API
----------------
```
https://www.hackerrank.com/calendar/feed.json
```
This API is used to fetch online judge contest information such as URL, start time, end time, description etc.

4. Google Places API
-------------------
```
https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(Range)&types=\(Type)&sensor=true&key=(API Key)
```
This API allows us to fetch JSON data containing places of interest within a given radius (Range) from the user's current location (latitude and longitude).

#Libraries used:
----------------
1. *SWRevealViewController*:
For creating a swipe-style menu (https://github.com/John-Lluch/SWRevealViewController)

2. *SDWebImage*:
Popular asynchronous image downloading library (https://github.com/rs/SDWebImage)

3. *NYAlertViewController*:
Add customised alert view controllers (https://github.com/nealyoung/NYAlertViewController)

4. *YTPlayerView*:
Embed Youtube videos in iOS apps (https://github.com/youtube/youtube-ios-player-helper)

5. *Toast*:
Display 'toast' messages (https://github.com/scalessec/Toast)

#Android and Windows 10 repos
-----------------------------
- *Android* : https://github.com/Swati4star/NSIT-App-v2
- *Windows 10* : https://github.com/sgaggarwal2009/NSIT-Connect-Microsoft-App

#Project Maintainers
--------------------
This project is actively maintained by [Swapnil Dhanwal](github.com/Swapnil52). For queries, please send an email to swapnildhanwal@hotmail.com

