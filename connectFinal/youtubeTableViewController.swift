//
//  youtubeTableViewController.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 24/03/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import SWRevealViewController
import SDWebImage
import Toast
import NYAlertViewController



//variables to populate the tableView
var resultsPerPage = 5
var ytVideoDescriptions = [String]()
var ytVideoTitles = [String]()
var ytPublishedTimes = [String]()
var ytVideoIds = [String]()
var ytThumbnailURLs = [String]()
var ytThumbnails = [String:UIImage]()

//variables to handle pages
var pageIndex = 1
var currentURL : String!
var previousURL : String!
var nextURL : String!
var nextPageToken : String!
var prevPageToken : String!
var totalNumberOfPages : Int!

//variables to pass to the video player
var passVideoId : String!

class youtubeTableViewController: UITableViewController {
    
    
    @IBOutlet weak var previousOutlet: UIBarButtonItem!
    @IBOutlet weak var nextOutlet: UIBarButtonItem!
    var ytRefresher = UIRefreshControl()
    var spinner = UIActivityIndicatorView()
    
    @IBAction func previous(sender: AnyObject) {
        
        if pageIndex == 1
        {
            previousOutlet.enabled = false
        }
        else
        {
            pageIndex-=1
            print(pageIndex)
            if pageIndex == 1
            {
                previousOutlet.enabled = false
            }
            previousURL = currentURL
            ytPublishedTimes.removeAll()
            ytVideoDescriptions.removeAll()
            ytVideoIds.removeAll()
            ytVideoTitles.removeAll()
            ytThumbnailURLs.removeAll()
            ytThumbnails.removeAll()
            self.tableView.reloadData()
            previousOutlet.enabled = false
            nextOutlet.enabled = false
            
            spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = .Gray
            spinner.layer.cornerRadius = 10
            spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
            self.view.addSubview(spinner)
            spinner.startAnimating()
            //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: nextURL + "&pageToken=\(prevPageToken)")!) { (data, response, error) -> Void in
                
                if error != nil
                {
                        
//                    let alert = UIAlertController(title: "An error occurred", message: "Please try again later", preferredStyle: .Alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: {
//                        
//                        self.spinner.stopAnimating()
//                        self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
//                        
//                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(true, completion: {
                                
                                self.spinner.stopAnimating()
                                self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
                            })
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    })
                    
                }

                
                if error == nil
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        do
                        {
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            //print(jsonData)
                            
                            if let pageInfo = jsonData["pageInfo"] as? [String:AnyObject]
                            {
                                resultsPerPage = pageInfo["resultsPerPage"] as! Int
                            }
                            
                            nextPageToken = jsonData["nextPageToken"] as? String
                            if jsonData["prevPageToken"] != nil
                            {
                                prevPageToken = jsonData["prevPageToken"] as? String
                            }
                            
                            
                            if let items = jsonData["items"] as? [[String:AnyObject]]
                            {
                                
                                for item in items
                                {
                                    
                                    if let snippet = item["snippet"] as? [String:AnyObject]
                                    {
                                        
                                        // *IMPORTANT* adding the videoID
                                        //var id : String!
                                        if let resourceId = snippet["resourceId"] as? [String:AnyObject]
                                        {
                                            if let videoId = resourceId["videoId"] as? String
                                            {
                                                ytVideoIds.append(videoId)
                                                //id = videoId
                                            }
                                        }
                                        
                                        
                                        //adding the video description (if any)
                                        
                                        if snippet["description"] != nil
                                        {
                                            ytVideoDescriptions.append(snippet["description"] as! String)
                                        }
                                        else
                                        {
                                            ytVideoDescriptions.append("")
                                        }
                                        
                                        //adding the video title
                                        
                                        if snippet["title"] != nil
                                        {
                                            ytVideoTitles.append(snippet["title"] as! String)
                                        }
                                        else
                                        {
                                            ytVideoTitles.append("")
                                        }
                                        
                                        //adding the video creation date
                                        
                                        if let time = snippet["publishedAt"] as? String
                                        {
                                            let dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                            let newDate = dateFormatter.dateFromString(time)!
                                            dateFormatter.AMSymbol = "AM"
                                            dateFormatter.PMSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                            let dateString = dateFormatter.stringFromDate(newDate)
                                            ytPublishedTimes.append(dateString)
                                        }
                                        
                                        //adding the video thumbnail url
                                        
                                        if let thumbnails = snippet["thumbnails"] as? [String:AnyObject]
                                        {
                                            if let def = thumbnails["high"] as? [String:AnyObject]
                                            {
                                                if let url = def["url"] as? String
                                                {
                                                    ytThumbnailURLs.append(url)
                                                    if ytThumbnailURLs.count == resultsPerPage
                                                    {
                                                        self.tableView.reloadData()
                                                        currentURL = previousURL
                                                        self.spinner.stopAnimating()
                                                        self.previousOutlet.enabled = true
                                                        self.nextOutlet.enabled = true
                                                        if prevPageToken == nil
                                                        {
                                                            self.previousOutlet.enabled = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        catch
                        {
                            
                        }
                    })
                }
                
            }
            task.resume()

        }
        
    }
    @IBAction func next(sender: AnyObject) {
        
        pageIndex += 1
        
        previousOutlet.enabled = true
        
        print(pageIndex)
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .Gray
        spinner.layer.cornerRadius = 10
        spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        self.view.addSubview(spinner)
        
        if nextPageToken == nil || nextPageToken == ""
        {
            nextOutlet.enabled = false
        }
        
        if nextPageToken != nil && pageIndex != totalNumberOfPages
        {
            nextURL = currentURL
            //print(nextURL)
            ytPublishedTimes.removeAll()
            ytVideoDescriptions.removeAll()
            ytVideoIds.removeAll()
            ytVideoTitles.removeAll()
            ytThumbnailURLs.removeAll()
            ytThumbnails.removeAll()
            tableView.reloadData()
            previousOutlet.enabled = false
            nextOutlet.enabled = false
            spinner.startAnimating()
            //UIApplication.sharedApplication().beginIgnoringInteractionEvents()

            let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: nextURL + "&pageToken=\(nextPageToken)")!) { (data, response, error) -> Void in
                
                if error != nil
                {

                        
//                        let alert = UIAlertController(title: "An error occurred", message: "Please try again later", preferredStyle: .Alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//                        self.presentViewController(alert, animated: true, completion: {
//                            
//                            self.spinner.stopAnimating()
//                            self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
//                        
//                        
//                        
//                        
//                        
//                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(true, completion: {
                                
                                self.spinner.stopAnimating()
                                self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
                                
                            })
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)

                        
                    })
                    
            
                }
                
                if error == nil
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        do
                        {
                            print(nextURL + "&pageToken=\(nextPageToken)")
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            //print(jsonData)
                            
                            nextPageToken = jsonData["nextPageToken"] as? String
                            
                            if let pageInfo = jsonData["pageInfo"] as? [String:AnyObject]
                            {
                                resultsPerPage = pageInfo["resultsPerPage"] as! Int
                                if nextPageToken == nil
                                {
                                    resultsPerPage = totalNumberOfPages%5
                                    print(resultsPerPage)
                                }
                            }

                            
                            
                            
                            if jsonData["prevPageToken"] != nil
                            {
                                prevPageToken = jsonData["prevPageToken"] as? String
                            }
                            
                            
                            if let items = jsonData["items"] as? [[String:AnyObject]]
                            {
                                
                                for item in items
                                {
                                    
                                    if let snippet = item["snippet"] as? [String:AnyObject]
                                    {
                                        
                                        // *IMPORTANT* adding the videoID
                                        //var id : String!
                                        if let resourceId = snippet["resourceId"] as? [String:AnyObject]
                                        {
                                            if let videoId = resourceId["videoId"] as? String
                                            {
                                                ytVideoIds.append(videoId)
                                                //id = videoId
                                            }
                                        }
                                        
                                        
                                        //adding the video description (if any)
                                        
                                        if snippet["description"] != nil
                                        {
                                            ytVideoDescriptions.append(snippet["description"] as! String)
                                        }
                                        else
                                        {
                                            ytVideoDescriptions.append("")
                                        }
                                        
                                        //adding the video title
                                        
                                        if snippet["title"] != nil
                                        {
                                            ytVideoTitles.append(snippet["title"] as! String)
                                        }
                                        else
                                        {
                                            ytVideoTitles.append("")
                                        }
                                        
                                        //adding the video creation date
                                        
                                        if let time = snippet["publishedAt"] as? String
                                        {
                                            let dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                            let newDate = dateFormatter.dateFromString(time)!
                                            dateFormatter.AMSymbol = "AM"
                                            dateFormatter.PMSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                            let dateString = dateFormatter.stringFromDate(newDate)
                                            ytPublishedTimes.append(dateString)
                                        }
                                        
                                        //adding the video thumbnail url
                                        
                                        if let thumbnails = snippet["thumbnails"] as? [String:AnyObject]
                                        {
                                            if let def = thumbnails["high"] as? [String:AnyObject]
                                            {
                                                if let url = def["url"] as? String
                                                {
                                                    ytThumbnailURLs.append(url)
                                                    if ytThumbnailURLs.count == resultsPerPage
                                                    {
                                                        self.tableView.reloadData()
                                                        currentURL = nextURL
                                                        self.spinner.stopAnimating()
                                                        if (nextPageToken != nil)
                                                        {
                                                            self.nextOutlet.enabled = true
                                                        }
                                                        else
                                                        {
                                                            self.nextOutlet.enabled = false
                                                        }
                                                        self.previousOutlet.enabled = true
                                                        if nextPageToken != nil
                                                        {
                                                            print(nextPageToken)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        catch
                        {
                            
                        }
                    })
                }
                
            }
            task.resume()
        }

        
        
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextOutlet.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        self.previousOutlet.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        
        totalNumberOfPages = 0
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.tableView.separatorColor = UIColor.clearColor()
        
        self.navigationController?.toolbarHidden = false
        
        if pageIndex == 1
        {
            previousOutlet.enabled = false
        }
        
        //setting up spinner
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .Gray
        spinner.layer.cornerRadius = 10
        spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        //setting up refresher
        isAnimating = false
        currentColorIndex = 0
        currentLabelIndex = 0
        customView = UIView()
        labelsArray.removeAll()
        ytRefresher.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)
        ytRefresher.attributedTitle = NSAttributedString(string: "")
        loadCustomViewContents()
        self.view.addSubview(ytRefresher)
        
        ytPublishedTimes.removeAll()
        ytVideoDescriptions.removeAll()
        ytVideoIds.removeAll()
        ytVideoTitles.removeAll()
        ytThumbnailURLs.removeAll()
        ytThumbnails.removeAll()
        nextPageToken = ""
        nextURL = ""
        previousURL = ""
        let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=UUu445B5LTXzkNr5eft8wNHg&key=AIzaSyBgktirlOODUO9zWD-808D7zycmP7smp-Y"
        let url = NSURL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=UUu445B5LTXzkNr5eft8wNHg&key=AIzaSyBgktirlOODUO9zWD-808D7zycmP7smp-Y")
        currentURL = urlString
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            if error != nil
            {
                
                dispatch_async(dispatch_get_main_queue(), { 
                    
//                    let alert = UIAlertController(title: "An Error Occurred", message: "Please try again later", preferredStyle: .Alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: {
//                        
//                        self.spinner.stopAnimating()
//                        self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
//                        self.nextOutlet.enabled = false
//                    })
                    
                    let alert = NYAlertViewController()
                    alert.title = "An Error Occurred"
                    alert.message = "Please try again later"
                    alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                    alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                        
                       
                        self.spinner.stopAnimating()
                        self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
                        self.nextOutlet.enabled = false
                        
                        
                    }))
                    
                    
                })
                
            }
            
            if error == nil
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    do
                    {
                        let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        //print(jsonData)
                        
                        if let pageInfo = jsonData["pageInfo"] as? [String:AnyObject]
                        {
                            resultsPerPage = (pageInfo["resultsPerPage"] as? Int)!
                            totalNumberOfPages = (pageInfo["totalResults"] as! Int)
                        }

                        
                        nextPageToken = jsonData["nextPageToken"] as? String
                        
                        if let items = jsonData["items"] as? [[String:AnyObject]]
                        {
                            for item in items
                            {
                                
                                if let snippet = item["snippet"] as? [String:AnyObject]
                                {
                                    
                                    // *IMPORTANT* adding the videoID
                                    //var id : String!
                                    if let resourceId = snippet["resourceId"] as? [String:AnyObject]
                                    {
                                        if let videoId = resourceId["videoId"] as? String
                                        {
                                            ytVideoIds.append(videoId)
                                            //id = videoId
                                        }
                                    }

                                    
                                    //adding the video description (if any)
                                    
                                    if snippet["description"] != nil
                                    {
                                        ytVideoDescriptions.append(snippet["description"] as! String)
                                    }
                                    else
                                    {
                                        ytVideoDescriptions.append("")
                                    }
                                    
                                    //adding the video title
                                    
                                    if snippet["title"] != nil
                                    {
                                        ytVideoTitles.append(snippet["title"] as! String)
                                    }
                                    else
                                    {
                                        ytVideoTitles.append("")
                                    }
                                    
                                    //adding the video creation date
                                    
                                    if let time = snippet["publishedAt"] as? String
                                    {
                                        let dateFormatter = NSDateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                        let newDate = dateFormatter.dateFromString(time)!
                                        dateFormatter.AMSymbol = "AM"
                                        dateFormatter.PMSymbol = "PM"
                                        dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                        let dateString = dateFormatter.stringFromDate(newDate)
                                        ytPublishedTimes.append(dateString)
                                    }
                                    
                                    //adding the video thumbnail url
                                    
                                    if let thumbnails = snippet["thumbnails"] as? [String:AnyObject]
                                    {
                                        if let def = thumbnails["high"] as? [String:AnyObject]
                                        {
                                            if let url = def["url"] as? String
                                            {
                                                ytThumbnailURLs.append(url)
                                                if ytThumbnailURLs.count == resultsPerPage
                                                {
                                                    self.tableView.reloadData()
                                                    self.spinner.stopAnimating()
                                                    if prevPageToken == nil
                                                    {
                                                        self.previousOutlet.enabled = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    catch
                    {
                        
                    }
                })
            }
            
        }
        task.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ytVideoTitles.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("testYoutubeCell", forIndexPath: indexPath) as! youtubeCell
        
        cell.layoutIfNeeded()
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.CGPath
        cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        let titleString = ytVideoTitles[indexPath.row].stringByReplacingOccurrencesOfString("\"", withString: "")
        
        cell.title.text = titleString
        cell.title.numberOfLines = 0
        cell.thumbnail.image = ytThumbnails[ytVideoIds[indexPath.row]]
        cell.desc.text = "No description available"
        if ytVideoDescriptions[indexPath.row] != ""
        {
            cell.desc.text = ytVideoDescriptions[indexPath.row]
        }
        cell.date.text = ytPublishedTimes[indexPath.row]
        cell.thumbnail.setIndicatorStyle(UIActivityIndicatorViewStyle.White)
        cell.thumbnail.setShowActivityIndicatorView(true)
        cell.thumbnail.sd_setImageWithURL(NSURL(string: ytThumbnailURLs[indexPath.row]))
        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        passVideoId = ytVideoIds[indexPath.row]
        performSegueWithIdentifier("playVideoSegue", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false
        {
//            let alert = UIAlertController(title: "Internet Connection Unavailable", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                
//                self.spinner.stopAnimating()
//                
//            }))
//            self.presentViewController(alert, animated: true, completion: nil)
            
            let alert = NYAlertViewController()
            alert.title = "Internet Connection Unavailable"
            alert.message = "Please try again when the connection is re-established"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: { 
                    
                    self.spinner.stopAnimating()
                    
                })
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func refresh()
    {
        
        if Reachability.isConnectedToNetwork() == false
        {
//            let alert = UIAlertController(title: "Internet Connection Unavailable", message: "Please try again when the connection is re-established", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: { 
//                
//                self.ytRefresher.endRefreshing()
//                if self.spinner.isAnimating()
//                {
//                    self.spinner.stopAnimating()
//                }
//                
//            })
            
            let alert = NYAlertViewController()
            alert.title = "Internet Connection Unavailable"
            alert.message = "Please try again when the connection is re-established"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: {
                    
                    self.spinner.stopAnimating()
                    self.ytRefresher.endRefreshing()
                    
                })
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        }
        
        if Reachability.isConnectedToNetwork() == true
        {
        
            if spinner.isAnimating()
            {
                spinner.stopAnimating()
            }
            ytPublishedTimes.removeAll()
            ytVideoDescriptions.removeAll()
            ytVideoIds.removeAll()
            ytVideoTitles.removeAll()
            ytThumbnailURLs.removeAll()
            ytThumbnails.removeAll()
            nextPageToken = ""
            nextURL = ""
            previousURL = ""
            let urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=UUu445B5LTXzkNr5eft8wNHg&key=AIzaSyBgktirlOODUO9zWD-808D7zycmP7smp-Y"
            let url = NSURL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=UUu445B5LTXzkNr5eft8wNHg&key=AIzaSyBgktirlOODUO9zWD-808D7zycmP7smp-Y")
            currentURL = urlString
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
                
                if error != nil
                {
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        
//                        let alert = UIAlertController(title: "An Error Occurred", message: "Please try again later", preferredStyle: .Alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//                        self.presentViewController(alert, animated: true, completion: nil)
//                        self.spinner.stopAnimating()
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(true, completion: { 
                                
                                self.spinner.stopAnimating()
                                
                            })
                            
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    })
                    
                }
                
                if error == nil
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        do
                        {
                            self.spinner.stopAnimating()
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                            //print(jsonData)
                            
                            if let pageInfo = jsonData["pageInfo"] as? [String:AnyObject]
                            {
                                resultsPerPage = (pageInfo["resultsPerPage"] as? Int)!
                                totalNumberOfPages = (pageInfo["totalResults"] as! Int)
                            }
                            
                            
                            nextPageToken = jsonData["nextPageToken"] as? String
                            
                            if let items = jsonData["items"] as? [[String:AnyObject]]
                            {
                                for item in items
                                {
                                    
                                    if let snippet = item["snippet"] as? [String:AnyObject]
                                    {
                                        
                                        // *IMPORTANT* adding the videoID
                                        //var id : String!
                                        if let resourceId = snippet["resourceId"] as? [String:AnyObject]
                                        {
                                            if let videoId = resourceId["videoId"] as? String
                                            {
                                                ytVideoIds.append(videoId)
                                                //id = videoId
                                            }
                                        }
                                        
                                        
                                        //adding the video description (if any)
                                        
                                        if snippet["description"] != nil
                                        {
                                            ytVideoDescriptions.append(snippet["description"] as! String)
                                        }
                                        else
                                        {
                                            ytVideoDescriptions.append("")
                                        }
                                        
                                        //adding the video title
                                        
                                        if snippet["title"] != nil
                                        {
                                            ytVideoTitles.append(snippet["title"] as! String)
                                        }
                                        else
                                        {
                                            ytVideoTitles.append("")
                                        }
                                        
                                        //adding the video creation date
                                        
                                        if let time = snippet["publishedAt"] as? String
                                        {
                                            let dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                            let newDate = dateFormatter.dateFromString(time)!
                                            dateFormatter.AMSymbol = "AM"
                                            dateFormatter.PMSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                            let dateString = dateFormatter.stringFromDate(newDate)
                                            ytPublishedTimes.append(dateString)
                                        }
                                        
                                        //adding the video thumbnail url
                                        
                                        if let thumbnails = snippet["thumbnails"] as? [String:AnyObject]
                                        {
                                            if let def = thumbnails["high"] as? [String:AnyObject]
                                            {
                                                if let url = def["url"] as? String
                                                {
                                                    ytThumbnailURLs.append(url)
                                                    if ytThumbnailURLs.count == resultsPerPage
                                                    {
                                                        self.tableView.reloadData()
                                                        self.ytRefresher.endRefreshing()
                                                        self.spinner.stopAnimating()
                                                        self.previousOutlet.enabled = false
                                                        pageIndex = 1
                                                        self.nextOutlet.enabled = true
                                                    }

                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                        catch
                        {
                            
                        }
                    })
                }
                
            }
            task.resume()
        }

    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if ytRefresher.refreshing
        {
            if !isAnimating
            {
                
                animateRefreshStep1()
            }
        }
    }
    
    func loadCustomViewContents()
    {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents![0] as! UIView
        customView.frame = ytRefresher.bounds
        
        for i in 0 ..< customView.subviews.count
        {
            labelsArray.append(customView.viewWithTag(i+1) as! UILabel)
        }
        
        ytRefresher.backgroundColor = UIColor.clearColor()
        ytRefresher.tintColor = UIColor.clearColor()
        ytRefresher.addSubview(customView)
        
    }
    
    func animateRefreshStep1()
    {
        isAnimating = true
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            labelsArray[currentLabelIndex].transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
            labelsArray[currentLabelIndex].textColor = self.getNextColor()
            
            }, completion: { (finished) -> Void in
                
                UIView.animateWithDuration(0.05, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    labelsArray[currentLabelIndex].transform = CGAffineTransformIdentity
                    labelsArray[currentLabelIndex].textColor = UIColor.blackColor()
                    
                    }, completion: { (finished) -> Void in
                        currentLabelIndex+=1
                        
                        if currentLabelIndex < labelsArray.count {
                            self.animateRefreshStep1()
                        }
                        else {
                            self.animateRefreshStep2()
                        }
                })
        })
    }
    
    
    func animateRefreshStep2()
    {
        UIView.animateWithDuration(0.35, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            labelsArray[0].transform = CGAffineTransformMakeScale(1.5, 1.5)
            labelsArray[1].transform = CGAffineTransformMakeScale(1.5, 1.5)
            labelsArray[2].transform = CGAffineTransformMakeScale(1.5, 1.5)
            labelsArray[3].transform = CGAffineTransformMakeScale(1.5, 1.5)
            labelsArray[4].transform = CGAffineTransformMakeScale(1.5, 1.5)
            labelsArray[5].transform = CGAffineTransformMakeScale(1.5, 1.5)
            labelsArray[6].transform = CGAffineTransformMakeScale(1.5, 1.5)
            
            }, completion: { (finished) -> Void in
                UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    labelsArray[0].transform = CGAffineTransformIdentity
                    labelsArray[1].transform = CGAffineTransformIdentity
                    labelsArray[2].transform = CGAffineTransformIdentity
                    labelsArray[3].transform = CGAffineTransformIdentity
                    labelsArray[4].transform = CGAffineTransformIdentity
                    labelsArray[5].transform = CGAffineTransformIdentity
                    labelsArray[6].transform = CGAffineTransformIdentity
                    
                    }, completion: { (finished) -> Void in
                        if self.ytRefresher.refreshing {
                            currentLabelIndex = 0
                            self.animateRefreshStep1()
                        }
                        else {
                            isAnimating = false
                            currentLabelIndex = 0
                            for i in 0 ..< labelsArray.count {
                                labelsArray[i].textColor = UIColor.blackColor()
                                labelsArray[i].transform = CGAffineTransformIdentity
                            }
                        }
                })
        })
    }
    
    
    
    func getNextColor() -> UIColor
    {
        var colorsArray: Array<UIColor> = [UIColor.magentaColor(), UIColor.brownColor(), UIColor.yellowColor(), UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.orangeColor()]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }
    
    override func viewWillLayoutSubviews() {
        
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        
    }

    
    
}
