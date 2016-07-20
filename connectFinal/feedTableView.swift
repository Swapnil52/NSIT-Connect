//
//  feedTableView.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 12/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import QuartzCore


//Variables to populate the tableView
var highResImagesURLs = [String:String]()
var messages = [String]()
var objectIds = [String]()
var pictureIds = [String : String]()
var likes = [NSInteger]()
var dates = [String]()
var societyImages : [String : UIImage] = ["NSITonline":UIImage(named: "nsitonline.jpeg")!]
var pictureURLs = [String : String]()
var images = [String : UIImage]()
var animateCells = [Int]()
var preventAnimation = Set<NSIndexPath>()
//var attachments = [[String : AnyObject]]()


var passMessage : String!
var passImageURL : String!
var passImage : UIImage!
var passLikes : NSInteger!
var passObjectId : String!
var passPictureId : String!
var passHighResImageURL : String!
var loaded : Bool = false
var refreshed = false
var didScrollOnce = false
var numberOfLoads = 1;
var next20 : String = ""
var y = 0
var refresher = UIRefreshControl()

class feedTableView: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("potty")
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(feedTableView.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(refresher)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("objectIds") == nil
        {
            if Reachability.isConnectedToNetwork() == false
            {
                let alert = UIAlertController(title: "Internet Connection Unavailable", message: "Please enable internet access!", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
    
                    self.navigationController?.popViewControllerAnimated(true)
    
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                var spinner = UIActivityIndicatorView()
                spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                spinner.center = CGPointMake(self.view.center.x, self.view.center.y-100)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = .Gray
                spinner.layer.cornerRadius = 10
                spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
                self.view.addSubview(spinner)
                spinner.startAnimating()
                //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                
                let url = NSURL(string: "https://graph.facebook.com/109315262061/posts?limit=20&fields=id,full_picture,picture,from,shares,attachments,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD")
                
                let session = NSURLSession.sharedSession()
                
                let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
                    
                    if error != nil
                    {
                        print(error)
                    }
                        
                    else
                    {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if let data = data
                            {
                                do
                                {
                                    
                                    messages.removeAll()
                                    objectIds.removeAll()
                                    likes.removeAll()
                                    //society.removeAll()
                                    pictureURLs.removeAll()
                                    dates.removeAll()
                                    highResImagesURLs.removeAll()
                                    
                                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                                    if let jsonData = jsonData as? NSDictionary
                                    {
                                        
                                        
                                        if let paging = jsonData["paging"] as? [String : String]
                                        {
                                            next20 = paging["next"]! as String
                                            
                                        }
                                        
                                        if let items = jsonData["data"] as? [[String : AnyObject]]
                                        {
                                            for item in items
                                            {
                                                
                                                
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
                                                                                    highResImagesURLs[item["id"] as! String] = src
                                                                                    break;
                                                                                }
                                                                                else
                                                                                {
                                                                                    print("potty")
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
                                                                        highResImagesURLs[item["id"] as! String] = src
                                                                    }
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                }
                                                
                                                
                                                if item["message"] != nil
                                                {
                                                    messages.append(item["message"] as! String)
                                                }
                                                objectIds.append(item["id"] as! String)
                                                pictureURLs[item["id"] as! String] = item["picture"] as? String
                                                
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
                                                    dates.append(dateString)
                                                }
                                                
                                                
                                                let pictureId = item["object_id"] as? String
                                                if pictureId != nil
                                                {
                                                    pictureIds[item["id"] as! String] = pictureId
                                                    
                                                }
                                                
                                                let like = item["likes"]
                                                let summary = like!["summary"]
                                                let count = summary!!["total_count"]
                                                likes.append(count as! NSInteger)
                                                
                                                
                                                let id = item["id"] as? String
                                                let pictureURL = item["picture"] as? String
                                                if pictureURL == nil
                                                {
                                                    images[id!] = nil
                                                }
                                                
                                                if objectIds.count == 20
                                                {
                                                    spinner.stopAnimating()
                                                    NSUserDefaults.standardUserDefaults().setObject(objectIds, forKey: "objectIds")
                                                    NSUserDefaults.standardUserDefaults().setObject(messages, forKey: "messages")
                                                    NSUserDefaults.standardUserDefaults().setObject(highResImagesURLs, forKey: "highResImageURLs")
                                                    NSUserDefaults.standardUserDefaults().setObject(pictureURLs, forKey: "pictureURLs")
                                                    NSUserDefaults.standardUserDefaults().setObject(likes, forKey: "likes")
                                                    NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "dates")
                                                    self.tableView.reloadData()
                                                    refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
                                                    refresher.addTarget(self, action: #selector(feedTableView.refresh), forControlEvents: UIControlEvents.ValueChanged)
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                }
                                    
                                catch
                                {
                                    
                                }
                                
                                
                            }
                        })
                        
                        
                        
                    }
                    
                    
                }
                
                task.resume()
            }
        }
        else
        {
            messages = NSUserDefaults.standardUserDefaults().objectForKey("messages") as! [String]
            highResImagesURLs = NSUserDefaults.standardUserDefaults().objectForKey("highResImageURLs") as! [String:String]
            likes = NSUserDefaults.standardUserDefaults().objectForKey("likes") as! [NSInteger]
            dates = NSUserDefaults.standardUserDefaults().objectForKey("dates") as! [String]
            pictureURLs = NSUserDefaults.standardUserDefaults().objectForKey("pictureURLs") as! [String:String]
            objectIds = NSUserDefaults.standardUserDefaults().objectForKey("objectIds") as! [String]
            if NSUserDefaults.standardUserDefaults().objectForKey("numberOfLoads") != nil
            {
                numberOfLoads = NSUserDefaults.standardUserDefaults().objectForKey("numberOfLoads") as! Int
            }
            if NSUserDefaults.standardUserDefaults().objectForKey("next20") != nil
            {
                next20 = NSUserDefaults.standardUserDefaults().objectForKey("next20") as! String
            }
            self.tableView.reloadData()
        }
        
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
        return messages.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Cell if image is nil
        if pictureURLs[objectIds[indexPath.row]] == nil
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("noImageFeedCell", forIndexPath: indexPath) as! noImageFeedCell
            
            
            cell.message.text = messages[indexPath.row]
            cell.thumb.image = UIImage(named: "thumb.png")
            cell.likes.text = String(likes[indexPath.row])
            cell.date.text = String(dates[indexPath.row])
            return cell
        }
        
        
        //Cell if image is not nil
        let cell = tableView.dequeueReusableCellWithIdentifier("feedCell", forIndexPath: indexPath) as! feedCell
        
        //        cell.backgroundColor = UIColor.clearColor()
        //        cell.contentView.backgroundColor = UIColor.clearColor()
        //
        //        cell.cellPaddingView.layer.shadowOpacity = 1
        //        cell.cellPaddingView.layer.shadowOffset = CGSizeMake(0, 5)
        //        cell.cellPaddingView.layer.shadowColor = UIColor.blackColor().CGColor
        
        cell.message.text = messages[indexPath.row]
        cell.thumb.image = UIImage(named: "thumb.png")
        cell.likes.text = String(likes[indexPath.row])
        cell.date.text = String(dates[indexPath.row])
        cell.societyImage.image = societyImages["NSITonline"]
        //cell.societyImage.layer.borderWidth = 1.0
        //cell.societyImage.layer.cornerRadius = 5.0
        //cell.societyImage.layer.masksToBounds = true
        //cell.societyImage.layer.borderColor = UIColor.whiteColor().CGColor
        cell.line.backgroundColor = UIColor(red: 0x01/255, green: 0xb2/255, blue: 0x9b/255, alpha: 1)
        
        let cellSpinner = UIActivityIndicatorView()
        cellSpinner.frame = cell.societyImage.frame
        cellSpinner.center = cell.societyImage.center
        cellSpinner.hidesWhenStopped = true
    
        if pictureURLs[objectIds[indexPath.row]] != nil
        {

            cell.societyImage.setIndicatorStyle(UIActivityIndicatorViewStyle.White)
            cell.societyImage.setShowActivityIndicatorView(true)
            cell.societyImage.sd_setImageWithURL(NSURL(string: pictureURLs[objectIds[indexPath.row]]!),completed: { (image, error, cache, url) in
                
                
                
            })

            
        }
        
        cell.societyImage.layer.shadowColor = UIColor.blackColor().CGColor
        cell.societyImage.layer.shadowOffset = CGSizeMake(0, 5)
        cell.societyImage.layer.shadowOpacity = 1.0
        cell.societyImage.layer.masksToBounds = false
        
        return cell
    }
    

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        passMessage = messages[indexPath.row]
        passLikes = likes[indexPath.row]
        passObjectId = objectIds[indexPath.row]
        passImageURL = pictureURLs[passObjectId]
        passPictureId = pictureIds[passObjectId]
        passImage = images[objectIds[indexPath.row]]
        passHighResImageURL = highResImagesURLs[passObjectId]
        if passMessage == nil || passMessage == ""
        {
            self.performSegueWithIdentifier("homeToImageSegue", sender: self)
            return;
        }
        self.performSegueWithIdentifier("feedPage", sender: self)
        
    }
    
    
    
    //    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    //
    //
    //        //cell.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
    //
    ////        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
    ////
    ////            cell.layer.transform = CATransform3DMakeScale(1.0,1.0,1)
    ////
    ////            }) { (success) -> Void in
    ////
    ////
    ////                UIView.animateWithDuration(0.1, animations: {
    ////                    cell.layer.transform = CATransform3DMakeScale(1,1,1)
    ////                    animateCells[indexPath] = true
    ////                })
    ////
    ////
    ////        }
    //
    //        if !preventAnimation.contains(indexPath) {
    //            preventAnimation.insert(indexPath)
    //            TipInCellAnimator.animate(cell)
    //        }
    //    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        let currentOffset : CGFloat = scrollView.contentOffset.y;
        let maximumOffset : CGFloat =  scrollView.contentSize.height - scrollView.frame.size.height;
        
        if maximumOffset - currentOffset <= 10
        {
            print(didScrollOnce)
            print(objectIds.count)
            print(numberOfLoads)
        }
        
        if (maximumOffset - currentOffset <= scrollView.frame.height && !didScrollOnce && objectIds.count == 20 * numberOfLoads && Reachability.isConnectedToNetwork() == true) {
            print("activate refresher!")
            didScrollOnce = true;
            print(next20)
            
            var navigationBarActivityIndicator = UIActivityIndicatorView()
            navigationBarActivityIndicator = UIActivityIndicatorView.init(frame: CGRectMake(0, 0, 20, 20))
            navigationBarActivityIndicator.hidesWhenStopped = true
            let barItem = UIBarButtonItem.init(customView: navigationBarActivityIndicator)
            self.navigationItem.setRightBarButtonItem(barItem, animated: true)
            navigationBarActivityIndicator.startAnimating()
            
            let loadMorePostsURL = NSURL(string: next20)
            let task = NSURLSession.sharedSession().dataTaskWithURL(loadMorePostsURL!, completionHandler: { (data, response, error) -> Void in
                
                if error != nil
                {
                    print(error)
                }
                    
                else if error == nil
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        if let data = data
                        {
                            do
                            {
                                
                                let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                                if let jsonData = jsonData as? NSDictionary
                                {
                                    
                                    
                                    
                                    if let paging = jsonData["paging"] as? [String : String]
                                    {
                                        next20 = paging["next"]! as String
                                    }
                                    
                                    if let items = jsonData["data"] as? [[String : AnyObject]]
                                    {
                                        for item in items
                                        {
                                            
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
                                                                                highResImagesURLs[item["id"] as! String] = src
                                                                                break;
                                                                            }
                                                                            else
                                                                            {
                                                                                print("potty")
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
                                                                    
                                                                    highResImagesURLs[item["id"] as! String] = src
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                            
                                            if item["message"] == nil
                                            {
                                                messages.append("")
                                            }
                                            if item["message"] != nil
                                            {
                                                messages.append(item["message"] as! String)
                                            }
                                            
                                            if item["created_time"] != nil
                                            {
                                                
                                                let fbDate = item["created_time"] as! String
                                                let dateFormatter = NSDateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
                                                let newDate = dateFormatter.dateFromString(fbDate)!
                                                dateFormatter.dateFormat = "dd-MM-yyyy,HH:mm"
                                                let dateString = dateFormatter.stringFromDate(newDate)
                                                dates.append(dateString)
                                            }
                                            
                                            
                                            objectIds.append(item["id"] as! String)
                                            pictureURLs[item["id"] as! String] = item["picture"] as? String
                                            
                                            
                                            
                                            let pictureId = item["object_id"] as? String
                                            if pictureId != nil
                                            {
                                                pictureIds[item["id"] as! String] = pictureId
                                                
                                            }
                                            
                                            let like = item["likes"]
                                            let summary = like!["summary"]
                                            let count = summary!!["total_count"]
                                            likes.append(count as! NSInteger)
                                            
                                            //society.append(name as! String)
                                            
                                            let id = item["id"] as? String
                                            let pictureURL = item["picture"] as? String
                                            if pictureURL == nil
                                            {
                                                images[id!] = nil
                                            }
                                            
                                            if objectIds.count%20 == 0
                                            {
                                                self.tableView.reloadData()
                                                navigationBarActivityIndicator.stopAnimating()
                                                self.navigationItem.rightBarButtonItem = nil
                                                didScrollOnce = false
                                                numberOfLoads += 1
                                                NSUserDefaults.standardUserDefaults().setObject(objectIds, forKey: "objectIds")
                                                NSUserDefaults.standardUserDefaults().setObject(messages, forKey: "messages")
                                                NSUserDefaults.standardUserDefaults().setObject(highResImagesURLs, forKey: "highResImageURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(pictureURLs, forKey: "pictureURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(likes, forKey: "likes")
                                                NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "dates")
                                                NSUserDefaults.standardUserDefaults().setObject(numberOfLoads, forKey: "numberOfLoads")
                                                NSUserDefaults.standardUserDefaults().setObject(next20, forKey: "next20")
                                            }
                                            
                                            
                                        }
                                    }
                                }
                                
                            }
                                
                            catch
                            {
                                
                            }
                            
                            
                        }
                        
                        
                    })
                }
                
            })
            
            task.resume()
            
        }
    }
    
    func refresh()
    {
        if Reachability.isConnectedToNetwork() == false
        {
            let alert = UIAlertController(title: "No internet connection available", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: { 
                
                refresher.endRefreshing()
                NSUserDefaults.standardUserDefaults().setObject(numberOfLoads, forKey: "numberOfLoads")
                
            })
        }
        else
        {
            let url = NSURL(string: "https://graph.facebook.com/109315262061/posts?limit=20&fields=id,full_picture,picture,from,shares,attachments,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD")
            
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
                
                if error != nil
                {
                    print(error)
                    refresher.endRefreshing()
                    let alert = UIAlertController(title: "An error occured", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                    
                else
                {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let data = data
                        {
                            do
                            {
                                
                                messages.removeAll()
                                objectIds.removeAll()
                                likes.removeAll()
                                //society.removeAll()
                                pictureURLs.removeAll()
                                dates.removeAll()
                                highResImagesURLs.removeAll()
                                
                                let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                                if let jsonData = jsonData as? NSDictionary
                                {
                                    
                                    
                                    if let paging = jsonData["paging"] as? [String : String]
                                    {
                                        next20 = paging["next"]! as String
                                        
                                    }
                                    
                                    if let items = jsonData["data"] as? [[String : AnyObject]]
                                    {
                                        for item in items
                                        {
                                            
                                            
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
                                                                                highResImagesURLs[item["id"] as! String] = src
                                                                                break;
                                                                            }
                                                                            else
                                                                            {
                                                                                print("potty")
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
                                                                    highResImagesURLs[item["id"] as! String] = src
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                            
                                            if item["message"] != nil
                                            {
                                                messages.append(item["message"] as! String)
                                            }
                                            objectIds.append(item["id"] as! String)
                                            pictureURLs[item["id"] as! String] = item["picture"] as? String
                                            
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
                                                dates.append(dateString)
                                            }
                                            
                                            
                                            let pictureId = item["object_id"] as? String
                                            if pictureId != nil
                                            {
                                                pictureIds[item["id"] as! String] = pictureId
                                                
                                            }
                                            
                                            let like = item["likes"]
                                            let summary = like!["summary"]
                                            let count = summary!!["total_count"]
                                            likes.append(count as! NSInteger)
                                            
                                            
                                            let id = item["id"] as? String
                                            let pictureURL = item["picture"] as? String
                                            if pictureURL == nil
                                            {
                                                images[id!] = nil
                                            }
                                            
                                            if objectIds.count == 20
                                            {
                                                numberOfLoads = 1
                                                NSUserDefaults.standardUserDefaults().setObject(objectIds, forKey: "objectIds")
                                                NSUserDefaults.standardUserDefaults().setObject(messages, forKey: "messages")
                                                NSUserDefaults.standardUserDefaults().setObject(highResImagesURLs, forKey: "highResImageURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(pictureURLs, forKey: "pictureURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(likes, forKey: "likes")
                                                NSUserDefaults.standardUserDefaults().setObject(dates, forKey: "dates")
                                                NSUserDefaults.standardUserDefaults().setObject(numberOfLoads, forKey: "numberOfLoads")
                                                NSUserDefaults.standardUserDefaults().setObject(next20, forKey: "next20")
                                                refresher.endRefreshing()
                                                self.tableView.reloadData()
                                            }
                                            
                                        }
                                    }
                                }
                                
                                
                                //                            for var i = 0; i < messages.count; i++
                                //                            {
                                //                                print(dates[i])
                                //                            }
                                
                                //                            for var i = 0; i < objectIds.count; i++
                                //                            {
                                //                                print(objectIds[i])
                                //                                print("\n")
                                //                            }
                                
                                //print(pictureIds.count)
                                //self.tableView.reloadData()
                                //self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
                                
                                
                                
                            }
                                
                            catch
                            {
                                
                            }
                            
                            
                        }
                    })
                    
                    
                    
                }
                
                
            }
            
            task.resume()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if refresher.refreshing
        {
            refresher.endRefreshing()
        }
        
    }
//    override func viewWillAppear(animated: Bool) {
//        
//        if Reachability.isConnectedToNetwork() == false
//        {
//            let alert = UIAlertController(title: "Internet Connection Unavailable", message: "Please enable internet access!", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                
//                self.navigationController?.popViewControllerAnimated(true)
//                
//            }))
//            self.presentViewController(alert, animated: true, completion: nil)
//            loaded = false
//            messages.removeAll()
//            objectIds.removeAll()
//            likes.removeAll()
//            //society.removeAll()
//            pictureURLs.removeAll()
//            dates.removeAll()
//        }
//        else
//        {
//            if loaded == false
//            {
//                var spinner = UIActivityIndicatorView()
//                spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//                spinner.center = self.view.center
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = .Gray
//                spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
//                view.addSubview(spinner)
//                spinner.layer.cornerRadius = 10
//                spinner.startAnimating()
//                //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//                
//                
//                let url = NSURL(string: "https://graph.facebook.com/109315262061/posts?limit=20&fields=id,full_picture, picture, from,shares,attachments,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD")
//                
//                let session = NSURLSession.sharedSession()
//                
//                let task = session.dataTaskWithURL(url!) { (data, response, error) -> Void in
//                    
//                    if error != nil
//                    {
//                        print(error)
//                    }
//                        
//                    else
//                    {
//                        
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            if let data = data
//                            {
//                                do
//                                {
//                                    
//                                    messages.removeAll()
//                                    objectIds.removeAll()
//                                    likes.removeAll()
//                                    //society.removeAll()
//                                    pictureURLs.removeAll()
//                                    dates.removeAll()
//                                    highResImagesURLs.removeAll()
//                                    
//                                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
//                                    if let jsonData = jsonData as? NSDictionary
//                                    {
//                                        
//                                        
//                                        if let paging = jsonData["paging"] as? [String : String]
//                                        {
//                                            next20 = paging["next"]! as String
//                                            
//                                        }
//                                        
//                                        if let items = jsonData["data"] as? [[String : AnyObject]]
//                                        {
//                                            for item in items
//                                            {
//                                                
//                                                
//                                                if let attachments = item["attachments"] as? [String:AnyObject]
//                                                {
//                                                    //print(attachments)
//                                                    if let attachmentData = attachments["data"] as? [[String:AnyObject]]
//                                                    {
//                                                        for x in attachmentData
//                                                        {
//                                                            if let subattachments = x["subattachments"] as? [String:AnyObject]
//                                                            {
//                                                                if let subData = subattachments["data"] as? [[String:AnyObject]]
//                                                                {
//                                                                    for y in subData
//                                                                    {
//                                                                        if let media = y["media"] as? [String:AnyObject]
//                                                                        {
//                                                                            if let image = media["image"] as? [String:AnyObject]
//                                                                            {
//                                                                                if let src = image["src"] as? String
//                                                                                {
//                                                                                    highResImagesURLs[item["id"] as! String] = src
//                                                                                    break;
//                                                                                }
//                                                                                else
//                                                                                {
//                                                                                    print("potty")
//                                                                                }
//                                                                                
//                                                                            }
//                                                                        }
//                                                                    }
//                                                                }
//                                                                break;
//                                                            }
//                                                            else
//                                                            {
//                                                                break;
//                                                            }
//                                                            
//                                                        }
//                                                        
//                                                        for x in attachmentData
//                                                        {
//                                                            
//                                                            if let media = x["media"] as? [String:AnyObject]
//                                                            {
//                                                                if let image = media["image"] as? [String:AnyObject]
//                                                                {
//                                                                    if let src = image["src"] as? String
//                                                                    {
//                                                                        highResImagesURLs[item["id"] as! String] = src
//                                                                    }
//                                                                }
//                                                            }
//                                                            
//                                                        }
//                                                        
//                                                    }
//                                                }
//                                                
//                                                
//                                                if item["message"] != nil
//                                                {
//                                                    messages.append(item["message"] as! String)
//                                                }
//                                                objectIds.append(item["id"] as! String)
//                                                pictureURLs[item["id"] as! String] = item["picture"] as? String
//                                                
//                                                if item["created_time"] != nil
//                                                {
//                                                    
//                                                    let fbDate = item["created_time"] as! String
//                                                    let dateFormatter = NSDateFormatter()
//                                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
//                                                    let newDate = dateFormatter.dateFromString(fbDate)!
//                                                    dateFormatter.AMSymbol = "AM"
//                                                    dateFormatter.PMSymbol = "PM"
//                                                    dateFormatter.dateFormat = "dd MMM, HH:mm a"
//                                                    let dateString = dateFormatter.stringFromDate(newDate)
//                                                    dates.append(dateString)
//                                                }
//                                                
//                                                
//                                                let pictureId = item["object_id"] as? String
//                                                if pictureId != nil
//                                                {
//                                                    pictureIds[item["id"] as! String] = pictureId
//                                                    
//                                                }
//                                                
//                                                let like = item["likes"]
//                                                let summary = like!["summary"]
//                                                let count = summary!!["total_count"]
//                                                likes.append(count as! NSInteger)
//                                                
//                                                
//                                                let id = item["id"] as? String
//                                                let pictureURL = item["picture"] as? String
//                                                if pictureURL == nil
//                                                {
//                                                    images[id!] = nil
//                                                }
//                                                if pictureURL != nil
//                                                {
//                                                    let placeholderURL = NSURL(string: pictureURL!)
//                                                    
//                                                    
//                                                    let newTask = NSURLSession.sharedSession().dataTaskWithURL(placeholderURL!, completionHandler: { (data, response, error) -> Void in
//                                                        
//                                                        if error != nil
//                                                        {
//                                                            print(error)
//                                                        }
//                                                        else
//                                                        {
//                                                            dispatch_async(dispatch_get_main_queue(), {
//                                                                
//                                                                let placeholderImage = UIImage(data: data!)
//                                                                images[id!] = placeholderImage
//                                                                
//                                                                if images.count == pictureURLs.count
//                                                                {
//                                                                    
//                                                                    spinner.stopAnimating()
//                                                                    //UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                                                                    self.tableView.flashScrollIndicators()
//                                                                    self.tableView.reloadData()
//                                                                    
//                                                                }
//                                                                
//                                                            })
//                                                            
//                                                            
//                                                        }
//                                                        
//                                                    })
//                                                    newTask.resume()
//                                                    
//                                                    
//                                                    
//                                                }
//                                                
//                                            }
//                                        }
//                                    }
//                                    
//                                }
//                                    
//                                catch
//                                {
//                                    
//                                }
//                                
//                                
//                            }
//                        })
//                        
//                        
//                        
//                    }
//                    
//                    
//                }
//                
//                task.resume()
//                loaded = true
//            }
//            
//        }
//        
//    }
    
    
    
    
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
