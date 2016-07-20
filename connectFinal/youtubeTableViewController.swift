//
//  youtubeTableViewController.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 24/03/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit


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
            var spinner = UIActivityIndicatorView()
            spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            //spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
            spinner.center = self.view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = .Gray
            spinner.layer.cornerRadius = 10
            spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
            self.view.addSubview(spinner)
            spinner.startAnimating()
            //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: nextURL + "&pageToken=\(prevPageToken)")!) { (data, response, error) -> Void in
                
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
                                        var id : String!
                                        if let resourceId = snippet["resourceId"] as? [String:AnyObject]
                                        {
                                            if let videoId = resourceId["videoId"] as? String
                                            {
                                                ytVideoIds.append(videoId)
                                                id = videoId
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
                                                    let thumbURL = NSURL(string: url)!
                                                    let newTask = NSURLSession.sharedSession().dataTaskWithURL(thumbURL, completionHandler: { (data, response, error) -> Void in
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                            
                                                            if error == nil
                                                            {
                                                                ytThumbnails[id] = UIImage(data: data!)
                                                                if ytThumbnails.count == resultsPerPage
                                                                {
                                                                    self.tableView.reloadData()
                                                                    currentURL = previousURL
                                                                    spinner.stopAnimating()
                                                                    self.previousOutlet.enabled = true
                                                                    self.nextOutlet.enabled = true
                                                                    if prevPageToken == nil
                                                                    {
                                                                        self.previousOutlet.enabled = false
                                                                    }
                                                                    //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                                                }
                                                            }
                                                            
                                                        })
                                                        
                                                        
                                                    })
                                                    newTask.resume()
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                }
                            }
//                            print(ytVideoIds)
//                            print(ytVideoDescriptions)
//                            print(ytVideoTitles)
//                            print(ytPublishedTimes)
//                            print(ytThumbnailURLs)
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
//        print(resultsPerPage)
        
        var spinner = UIActivityIndicatorView()
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
                                        var id : String!
                                        if let resourceId = snippet["resourceId"] as? [String:AnyObject]
                                        {
                                            if let videoId = resourceId["videoId"] as? String
                                            {
                                                ytVideoIds.append(videoId)
                                                id = videoId
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
                                                    let thumbURL = NSURL(string: url)!
                                                    let newTask = NSURLSession.sharedSession().dataTaskWithURL(thumbURL, completionHandler: { (data, response, error) -> Void in
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                            
                                                            if error == nil
                                                            {
                                                                ytThumbnails[id] = UIImage(data: data!)
                                                                if ytThumbnails.count == resultsPerPage
                                                                {
                                                                    self.tableView.reloadData()
                                                                    currentURL = nextURL
                                                                    spinner.stopAnimating()
                                                                    if (nextPageToken != nil)
                                                                    {
                                                                    self.nextOutlet.enabled = true
                                                                    }
                                                                    else
                                                                    {
                                                                        self.nextOutlet.enabled = false
                                                                    }
                                                                    self.previousOutlet.enabled = true
                                                                    //UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                                                    if nextPageToken != nil
                                                                    {
                                                                        print(nextPageToken)
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            
                                                        })
                                                        
                                                        
                                                    })
                                                    newTask.resume()
                                                    //self.tableView.reloadData()
                                                }
                                            }
                                        }
                                        
                                        if ytVideoTitles.count == resultsPerPage
                                        {
                                            //self.tableView.reloadData()
                                        }
                                    }
                                    
                                }
                            }
    //                        print(ytVideoIds)
    //                        print(ytVideoDescriptions)
    //                        print(ytVideoTitles)
    //                        print(ytPublishedTimes)
    //                        print(ytThumbnailURLs)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(2, forBarMetrics: .CompactPrompt)
        
        self.navigationController?.toolbarHidden = false
        
        if pageIndex == 1
        {
            previousOutlet.enabled = false
        }
        
        //setting up spinner
        var spinner = UIActivityIndicatorView()
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .Gray
        spinner.layer.cornerRadius = 10
        spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
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
                                    var id : String!
                                    if let resourceId = snippet["resourceId"] as? [String:AnyObject]
                                    {
                                        if let videoId = resourceId["videoId"] as? String
                                        {
                                            ytVideoIds.append(videoId)
                                            id = videoId
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
                                                let thumbURL = NSURL(string: url)!
                                                let newTask = NSURLSession.sharedSession().dataTaskWithURL(thumbURL, completionHandler: { (data, response, error) -> Void in
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                                        
                                                        if error == nil
                                                        {
                                                            ytThumbnails[id] = UIImage(data: data!)
                                                            if ytThumbnails.count == resultsPerPage
                                                            {
                                                                self.tableView.reloadData()
                                                                spinner.stopAnimating()
                                                                if prevPageToken == nil
                                                                {
                                                                    self.previousOutlet.enabled = false
                                                                }
                                                                
                                                                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                                                            }
                                                        }
                                                        
                                                    })
                                                    
                                                    
                                                })
                                                newTask.resume()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("youtubeCell", forIndexPath: indexPath) as! youtubeCell
        
        cell.title.text = ytVideoTitles[indexPath.row]
        cell.title.numberOfLines = 0
        cell.title.sizeToFit()
        cell.thumbnail.image = ytThumbnails[ytVideoIds[indexPath.row]]
        cell.desc.text = "No description available"
        if ytVideoDescriptions[indexPath.row] != ""
        {
            cell.desc.text = ytVideoDescriptions[indexPath.row]
        }
        cell.date.text = ytPublishedTimes[indexPath.row]
        cell.thumbnail.image = ytThumbnails[ytVideoIds[indexPath.row]]
        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        passVideoId = ytVideoIds[indexPath.row]
        performSegueWithIdentifier("playVideoSegue", sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false
        {
            let alert = UIAlertController(title: "Internet Connection Unavailable", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.navigationController?.popViewControllerAnimated(true)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
