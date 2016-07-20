//
//  customFeedTable.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 17/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import QuartzCore

//variables
var fbPages = [String]()
var fbPagesObjectIds = [String]()
var fbPagesURLS = [String]()
var counter = 0
var currentSelectedFeeds = [String:Bool]()
var fbCustomFeedToHome : Bool!

//spinner
var feedPageSpinner = UIActivityIndicatorView()

//variables to prevent repeated reloading of the page, since we don't have a spinner as of yet:P
var didGoToFeedPage : Bool!
var didGoToSettings = false
//variables for populating the table
var fbFeedMessages = [String]()
var fbFeedSociety = [String]()
var fbFeedIds = [String]()
var fbFeedThumbnailURLs = [String:String]()
var fbFeedPictureURLs = [String:String]()
var fbFeedImages = [String:UIImage]()
var fbFeedDates = [String]()
var fbFeedLikes = [NSInteger]()
var fbFeedPictureIds = [String:String]()
var fbPassHighResImageURLs = [String:String]()
var newSelectedFeeds = [String:Bool]()
var imageSet = NSMutableSet()
var fbFeedRefresher = UIRefreshControl()
var refreshOnce = 0
//Initialising the activity indicator (spinner)


class customFeedTable: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbFeedRefresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        fbFeedRefresher.addTarget(self, action: #selector(customFeedTable.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(fbFeedRefresher)
        print("view loaded!")
        didGoToFeedPage = false
        fbCustomFeedToHome = false
        didGoToSettings = false
        feedPageSpinner.activityIndicatorViewStyle = .Gray
        feedPageSpinner = UIActivityIndicatorView(frame: CGRectMake(0, 0, 100, 100))
        feedPageSpinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        
        feedPageSpinner.hidesWhenStopped = true
        feedPageSpinner.layer.cornerRadius = 10
        feedPageSpinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        feedPageSpinner.startAnimating()
        self.view.addSubview(feedPageSpinner)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("empty") == nil
        {
            empty = 0
        }
        
        else
        {
            empty = NSUserDefaults.standardUserDefaults().objectForKey("empty") as! Int
        }
        
        if NSUserDefaults.standardUserDefaults().objectForKey("selectedFeeds") == nil
        {
            selectedFeeds = ["184835371535420":false, "252117054812001":false, "109582689081817":false, "158168947539641":false, "604809706256620":false, "376394819102290":false, "278952135548721":false, "126976547314225":false, "185960271431856":false, "135639763273290":false, "499766883378107":false, "1457237581165961":false]
        }
        else
        {
            selectedFeeds = NSUserDefaults.standardUserDefaults().objectForKey("selectedFeeds") as! [String:Bool]
            
            if NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil 
            {
                print("fbFeedIds was nil")
                fbPagesObjectIds.removeAll(keepCapacity: true)
                
                for (item, boolean) in selectedFeeds
                {
                    if boolean == true
                    {
                        fbPagesObjectIds.append(item)
                    }
                }
                if (didGoToFeedPage == false) && fbCustomFeedToHome == false
                {
                    
                    fbPagesObjectIds.removeAll()
                    fbFeedIds.removeAll()
                    fbFeedImages.removeAll()
                    fbFeedMessages.removeAll()
                    fbFeedPictureURLs.removeAll()
                    fbFeedSociety.removeAll()
                    fbFeedThumbnailURLs.removeAll()
                    fbPassHighResImageURLs.removeAll()
                    tableView.reloadData()
                    feedPageSpinner.startAnimating()
                    
                    
                    for (item, boolean) in selectedFeeds
                    {
                        if boolean == true
                        {
                            fbPagesObjectIds.append(item)
                        }
                    }
                }
                fbPagesURLS.removeAll()
                for id in fbPagesObjectIds
                {
                    
                    let url = "https://graph.facebook.com/\(id)/posts?limit=20&fields=id,picture,from,attachments,shares,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD"
                    
                    fbPagesURLS.append(url)
                    
                    
                }
                
                counter = 0
                if empty != 0 && didGoToFeedPage == false && fbCustomFeedToHome == false
                {
                    fbFeedMessages.removeAll()
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        
                        self.loader(fbPagesURLS)
                        
                    }
                }
                
            }
            else
            {
                
                feedPageSpinner.stopAnimating()
                fbFeedMessages = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedMessages") as! [String]
                fbFeedIds = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") as! [String]
                fbFeedPictureURLs = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedPictureURLs") as! [String:String]
                fbFeedDates = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedDates") as! [String]
                fbFeedLikes = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedLikes") as! [NSInteger]
                fbFeedSociety = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedSociety") as! [String]
                fbFeedThumbnailURLs = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedThumbnailURLs") as! [String:String]
                fbPassHighResImageURLs = NSUserDefaults.standardUserDefaults().objectForKey("fbPassHighResImageURLs") as! [String:String]
                self.tableView.reloadData()
                
            }
        }
        
        
        
        //print(selectedFeeds)
        //print(empty)
        
        
        
        //print(fbPagesObjectIds)
        
        
        let settings = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(customFeedTable.action))
        self.navigationItem.rightBarButtonItem = settings
        
        
        
        let alert = UIAlertController(title: "Oops!", message: "Select societies to view feeds of?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            
            self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
            
        }))
        
        if NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil && Reachability.isConnectedToNetwork() == false
        {
            print("gobar")
            let alert = UIAlertController(title: "Can't load posts", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                
                self.navigationController?.popViewControllerAnimated(true)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        if empty == 0
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return fbFeedMessages.count
    }
    
    func action()
    {
        
        currentSelectedFeeds = selectedFeeds
        self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
        
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if identifier == "feedSettingsSegue" && empty > 0
        {
            didGoToFeedPage = false
            didGoToSettings = true
            
            return true;
        }
        return false
        
    }
    
    
    //MARK
    func refresh()
    {
        if Reachability.isConnectedToNetwork() == true 
        {
            fbPagesObjectIds.removeAll(keepCapacity: true)
            for (item, boolean) in selectedFeeds
            {
                if boolean == true
                {
                    fbPagesObjectIds.append(item)
                }
            }
            
            fbPagesObjectIds.removeAll()
            fbFeedIds.removeAll()
            fbFeedImages.removeAll()
            fbFeedMessages.removeAll()
            fbFeedPictureURLs.removeAll()
            fbFeedSociety.removeAll()
            fbFeedThumbnailURLs.removeAll()
            fbPassHighResImageURLs.removeAll()
            tableView.reloadData()
            feedPageSpinner.startAnimating()
            
            
            for (item, boolean) in selectedFeeds
            {
                if boolean == true
                {
                    fbPagesObjectIds.append(item)
                }
            }

            fbPagesURLS.removeAll()
            for id in fbPagesObjectIds
            {
                
                let url = "https://graph.facebook.com/\(id)/posts?limit=20&fields=id,picture,from,attachments,shares,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD"
                
                fbPagesURLS.append(url)
                
                
            }
            
            counter = 0
            if empty != 0 && didGoToFeedPage == false && fbCustomFeedToHome == false
            {
                fbFeedMessages.removeAll()
                
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    
                    self.loader(fbPagesURLS)
                    
                }
            }
        }
        else
        {
            print(refreshOnce)
            refreshOnce = 0
            
            let alert = UIAlertController(title: "Refresh failed", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            fbFeedRefresher.endRefreshing()
        }

        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        print(didGoToSettings)
        print(didGoToFeedPage)
        refreshOnce = 0
        if didGoToSettings == true && Reachability.isConnectedToNetwork() == false
        {
            selectedFeeds = currentSelectedFeeds
            NSUserDefaults.standardUserDefaults().setObject(selectedFeeds, forKey: "selectedFeeds")
        }
        
        
        var x = false
        if currentSelectedFeeds == selectedFeeds
        {
            x = true
        }
        
        if didGoToSettings == true && Reachability.isConnectedToNetwork() == true && !x
        {
            
            if empty != 0
            {
                selectedFeeds = NSUserDefaults.standardUserDefaults().objectForKey("selectedFeeds") as! [String:Bool]
                
                    
                    fbPagesObjectIds.removeAll(keepCapacity: true)
                    
                    for (item, boolean) in selectedFeeds
                    {
                        if boolean == true
                        {
                            fbPagesObjectIds.append(item)
                        }
                    }
                    if (didGoToFeedPage == false)
                    {
                        
                        fbPagesObjectIds.removeAll()
                        fbFeedIds.removeAll()
                        fbFeedImages.removeAll()
                        fbFeedMessages.removeAll()
                        fbFeedPictureURLs.removeAll()
                        fbFeedSociety.removeAll()
                        fbFeedThumbnailURLs.removeAll()
                        fbPassHighResImageURLs.removeAll()
                        tableView.reloadData()
                        feedPageSpinner.startAnimating()
                        
                        
                        for (item, boolean) in selectedFeeds
                        {
                            if boolean == true
                            {
                                fbPagesObjectIds.append(item)
                            }
                        }
                    }
                    print(fbPagesObjectIds)
                    fbPagesURLS.removeAll()
                    for id in fbPagesObjectIds
                    {
                        
                        let url = "https://graph.facebook.com/\(id)/posts?limit=20&fields=id,picture,from,attachments,shares,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD"
                        
                        fbPagesURLS.append(url)
                        
                        
                    }
                    
                    counter = 0
                    if empty != 0
                    {
                        
                        print("potty!")
                        
                        //setting up the spinner
                        
                        
                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
                            
                            self.loader(fbPagesURLS)
                            
                        }
                    }
                    else
                    {
                        
                        let alert = UIAlertController(title: "Oops!", message: "Select societies to view feeds of?", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            
                            self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
                            
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                
                didGoToSettings = false

            }
            
            else
            {
                
                let alert = UIAlertController(title: "Oops!", message: "Select societies to view feeds of?", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    
                    self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
                    
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if fbFeedThumbnailURLs[fbFeedIds[indexPath.row]] == nil
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("noImageCustomFeedCell", forIndexPath: indexPath) as! noImageCustomFeedCell
            cell.message.text = fbFeedMessages[indexPath.row]
            cell.line.backgroundColor = UIColor(red: 0x01/255, green: 0xb2/255, blue: 0x9b/255, alpha: 1)
            cell.societyName.text = fbFeedSociety[indexPath.row]
            cell.date.text = fbFeedDates[indexPath.row]
            cell.likes.text = String(fbFeedLikes[indexPath.row])
            cell.thumb.image = UIImage(named: "thumb.png")
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("customFeedCell", forIndexPath: indexPath) as! customFeedCell
        
        let cellSpinner = UIActivityIndicatorView()
        cellSpinner.frame = cell.thumbnail.frame
        cellSpinner.center = cell.thumbnail.center
        cellSpinner.hidesWhenStopped = true
        
        
        cell.message.text = fbFeedMessages[indexPath.row]
        cell.thumbnail.image = societyImages["NSITonline"]
        cell.thumbnail.layer.masksToBounds = true
        cell.line.backgroundColor = UIColor(red: 0x01/255, green: 0xb2/255, blue: 0x9b/255, alpha: 1)
        if fbFeedThumbnailURLs[fbFeedIds[indexPath.row]] != nil //!imageSet.containsObject(indexPath)
        {
            
            cell.thumbnail.setShowActivityIndicatorView(true)
            cell.thumbnail.setIndicatorStyle(UIActivityIndicatorViewStyle.White)
            cell.thumbnail.sd_setImageWithURL(NSURL(string: fbFeedThumbnailURLs[fbFeedIds[indexPath.row]]!), completed: { (image, error, cache, url) in
                
                
            })
            
            
        }
        
        if fbFeedThumbnailURLs[fbFeedIds[indexPath.row]] == nil
        {
            
            if cell.message.text == fbFeedMessages[indexPath.row]
            {
                print("potty")
                //cell.messageLeft.constant -= 190
                //imageSet.addObject(indexPath)
            }
            
        }
        
        //setting up shadow
        cell.thumbnail.layer.shadowColor = UIColor.blackColor().CGColor
        cell.thumbnail.layer.shadowOffset = CGSizeMake(0, 5)
        cell.thumbnail.layer.shadowOpacity = 1.0
        cell.thumbnail.layer.masksToBounds = false
        
        cell.societyName.text = fbFeedSociety[indexPath.row]
        cell.date.text = fbFeedDates[indexPath.row]
        cell.likes.text = String(fbFeedLikes[indexPath.row])
        cell.likesThumb.image = UIImage(named: "thumb.png")
        return cell
    }
    
    func loader(array : [String])
    {
        
        if counter < array.count
        {
            
            let url = NSURL(string: array[counter])
            //print(url)
            //print("---")
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
                
                if error != nil
                {
                    print(error)
                    feedPageSpinner.stopAnimating()
                    if fbFeedRefresher.refreshing == true
                    {
                        fbFeedRefresher.endRefreshing()
                        refreshOnce = 0
                    }
                    let alert = UIAlertController(title: "An error occured", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.tableView.reloadData()
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        do
                        {
                            //I know, I know. JSON parsing in swift sucks:P
                            
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            
                            if let jsonData = jsonData as? NSDictionary
                            {
                                if let items = jsonData["data"] as? [[String:AnyObject]]
                                {
                                    
                                    for item in items
                                    {
                                        
                                        let id = item["id"] as? String
                                        
                                        //Accessing the attachments array
                                        if let attachments = item["attachments"] as? [String:AnyObject]
                                        {
                                            //print(attachments)
                                            if let attachmentData = attachments["data"] as? [[String:AnyObject]]
                                            {
                                                for x in attachmentData
                                                {
                                                    if let subattachments = x["subattachments"] as? [String:AnyObject]
                                                    {
                                                        if let subData = subattachments["data"] as? [[String:AnyObject]]
                                                        {
                                                            for y in subData
                                                            {
                                                                if let media = y["media"] as? [String:AnyObject]
                                                                {
                                                                    if let image = media["image"] as? [String:AnyObject]
                                                                    {
                                                                        if let src = image["src"] as? String
                                                                        {
                                                                            fbPassHighResImageURLs[id!] = src
                                                                            break;
                                                                        }
                                                                        else
                                                                        {
                                                                            //print("potty")
                                                                        }
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        break;
                                                    }
                                                    else
                                                    {
                                                        break;
                                                    }
                                                    
                                                }
                                                
                                                for x in attachmentData
                                                {
                                                    
                                                    if let media = x["media"] as? [String:AnyObject]
                                                    {
                                                        if let image = media["image"] as? [String:AnyObject]
                                                        {
                                                            if let src = image["src"] as? String
                                                            {
                                                                fbPassHighResImageURLs[id!] = src
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                        }
                                        
                                        
                                        
                                        //Adding the message to be displayed
                                        if item["message"] != nil
                                        {
                                            fbFeedMessages.append(item["message"] as! String)
                                        }
                                        if item["message"] == nil
                                        {
                                            fbFeedMessages.append("")
                                        }
                                        
                                        fbFeedIds.append(item["id"] as! String)
                                        
                                        if let from  = item["from"] as? [String:AnyObject]
                                        {
                                            fbFeedSociety.append(from["name"] as! String)
                                        }
                                        
                                        //Adding the URL for the thumbnail
                                        if item["picture"] != nil
                                        {
                                            fbFeedThumbnailURLs[item["id"] as! String] = item["picture"] as? String
                                            
                                        }
                                        
                                        //adding the high res picture id
                                        let pictureId = item["object_id"] as? String
                                        if pictureId == nil
                                        {
                                            fbFeedPictureIds[item["id"] as! String] = nil
                                        }
                                        else
                                        {
                                            fbFeedPictureIds[item["id"] as! String] = pictureId
                                        }
                                        
                                        //Adding the post likes
                                        let likes = item["likes"]
                                        let summary = likes!["summary"]
                                        let totalCount = summary!!["total_count"] as! NSInteger
                                        fbFeedLikes.append(totalCount)
                                        
                                        //Adding the creation time
                                        if item["created_time"] != nil
                                        {
                                            let fbDate = item["created_time"] as! String
                                            let dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
                                            let newDate = dateFormatter.dateFromString(fbDate)!
                                            dateFormatter.AMSymbol = "AM"
                                            dateFormatter.PMSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, HH:mm a"
                                            let dateString = dateFormatter.stringFromDate(newDate)
                                            fbFeedDates.append(dateString)
                                        }
                                        
                                        if item["picture"]  == nil
                                        {
                                            fbFeedThumbnailURLs[item["id"] as! String] = nil
                                            fbFeedImages[item["id"] as! String] = nil
                                        }
                                        
                                        if fbFeedIds.count%20 == 0
                                        {
                                            self.tableView.reloadData()
                                            NSUserDefaults.standardUserDefaults().setObject(fbFeedIds, forKey: "fbFeedIds")
                                            NSUserDefaults.standardUserDefaults().setObject(fbPagesObjectIds, forKey: "fbPagesObjectIds")
                                            NSUserDefaults.standardUserDefaults().setObject(fbFeedMessages, forKey: "fbFeedMessages")
                                            NSUserDefaults.standardUserDefaults().setObject(fbFeedPictureURLs, forKey: "fbFeedPictureURLs")
                                            NSUserDefaults.standardUserDefaults().setObject(fbFeedSociety, forKey: "fbFeedSociety")
                                            NSUserDefaults.standardUserDefaults().setObject(fbFeedThumbnailURLs, forKey: "fbFeedThumbnailURLs")
                                            NSUserDefaults.standardUserDefaults().setObject(fbPassHighResImageURLs, forKey: "fbPassHighResImageURLs")
                                            NSUserDefaults.standardUserDefaults().setObject(fbFeedDates, forKey: "fbFeedDates")
                                            NSUserDefaults.standardUserDefaults().setObject(fbFeedLikes, forKey: "fbFeedLikes")
                                            feedPageSpinner.stopAnimating()
                                            fbFeedRefresher.endRefreshing()
                                            refreshOnce = 0
                                        }
                                        
                                                                          
                                    }
                                    
                                }
                            }
                            self.loader(array)
                            
                        }
                        catch
                        {
                            
                        }
                        
                        
                    })
                    
                    
                }
                
            }
            task.resume()
            
            counter += 1;
        }
            
        else
        {
            return
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        passMessage = fbFeedMessages[indexPath.row]
        passLikes = fbFeedLikes[indexPath.row]
        passObjectId = fbFeedIds[indexPath.row]
        passImageURL = fbFeedThumbnailURLs[passObjectId]
        passPictureId = fbFeedPictureIds[passObjectId]
        passImage = fbFeedImages[fbFeedIds[indexPath.row]]
        currentSelectedFeeds = selectedFeeds
        passHighResImageURL = fbPassHighResImageURLs[passObjectId]
        didGoToFeedPage = true
        if (passMessage == nil || passMessage == "")
        {
            if Reachability.isConnectedToNetwork() == true
            {
            self.performSegueWithIdentifier("customFeedToImage", sender: self)
            }
            else
            {
                let alert = UIAlertController(title: "Unable to download full resolution image", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            return
        }
        self.performSegueWithIdentifier("customFeedPage", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false && NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil
        {
            let alert = UIAlertController(title: "Internet Connection Unavailable", message: "Please enable internet access!", preferredStyle: .Alert)
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
