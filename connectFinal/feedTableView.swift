//
//  feedTableView.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 12/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import QuartzCore
import SDWebImage
import SWRevealViewController
import Toast
import NYAlertViewController

//Variables to populate the tableView

var pictureURLs = [String : String]()
var images = [String : UIImage]()
var animateCells = [Int]()
var preventAnimation = Set<NSIndexPath>()

var passMessage : String!
var passImageURL : String!
var passImage : UIImage!
var passLikes : NSInteger!
var passObjectId : String!
var passPictureId : String!
var passHighResImageURL : String!
var passAttachments : [String:AnyObject]!
var loaded : Bool = false
var refreshed = false
var didScrollOnce = false
var numberOfLoads = 1;
var next20 : String = ""
var y = 0

var refresher = UIRefreshControl()
var customView = UIView()
var labelsArray = Array<UILabel>()
var isAnimating = false
var currentColorIndex = 0
var currentLabelIndex = 0


class feedTableView: UITableViewController {
    
    var attachments = [String:[String:AnyObject]]()
    var highResImagesURLs = [String:String]()
    var messages = [String]()
    var objectIds = [String]()
    var pictureIds = [String : String]()
    var likes = [NSInteger]()
    var dates = [String]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var spinner = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAnimating = false
        currentColorIndex = 0
        currentLabelIndex = 0
        customView = UIView()
        labelsArray.removeAll()
        
        print("Welcome to NSIT Connect")
        
        self.tableView.separatorColor = UIColor.clearColor()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        self.view.makeToast("Pull to refresh!", duration: 1.5, position: CSToastPositionTop)
        
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        

        refresher.addTarget(self, action: #selector(feedTableView.refresh), forControlEvents: UIControlEvents.ValueChanged)
        refresher.attributedTitle = NSAttributedString(string: "")
        loadCustomViewContents()
        self.view.addSubview(refresher)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("objectIds") == nil || NSUserDefaults.standardUserDefaults().objectForKey("attachments") == nil
        {
            if Reachability.isConnectedToNetwork() == false
            {
                
                let alert = NYAlertViewController()
                alert.title = "Internet Connection Unavailable"
                alert.message = "Please enable the internet connection"
                alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (ation) in
                    
                    self.dismissViewControllerAnimated(true, completion: { 
                        
                    })
                    
                }))
                
                self.presentViewController(alert, animated: true, completion: {
                    
                    self.view.makeToast("Please pull to refresh when the internet connection is re-established", duration: 1.5, position: CSToastPositionTop)
                    
                })
            }
            else
            {
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
                        
                        dispatch_async(dispatch_get_main_queue(), { 
                            
                            let alert = NYAlertViewController()
                            alert.title = "An Error Occurred"
                            alert.message = "Please try again later"
                            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                                
                                self.dismissViewControllerAnimated(true, completion: nil)
                                
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        })
                        
                    }
                        
                    else
                    {
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            if let data = data
                            {
                                do
                                {
                                    
                                    self.messages.removeAll()
                                    self.objectIds.removeAll()
                                    self.likes.removeAll()
                                    //society.removeAll()
                                    pictureURLs.removeAll()
                                    self.dates.removeAll()
                                    self.highResImagesURLs.removeAll()
                                    
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
                                                    self.attachments[(item["id"] as? String)!] = attachments
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
                                                                                    self.highResImagesURLs[item["id"] as! String] = src
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
                                                                        
                                                                        self.highResImagesURLs[item["id"] as! String] = src
                                                                        
                                                                        
                                                                    }
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                }
                                                
                                                if item["message"] != nil
                                                {
                                                    self.messages.append(item["message"] as! String)
                                                }
                                                else
                                                {
                                                    self.message.append("")
                                                }
                                                
                                                self.objectIds.append(item["id"] as! String)
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
                                                    self.dates.append(dateString)
                                                }
                                                
                                                
                                                let pictureId = item["object_id"] as? String
                                                if pictureId != nil
                                                {
                                                    self.pictureIds[item["id"] as! String] = pictureId
                                                    
                                                }
                                                
                                                let like = item["likes"]
                                                let summary = like!["summary"]
                                                let count = summary!!["total_count"]
                                                self.likes.append(count as! NSInteger)
                                                
                                                
                                                let id = item["id"] as? String
                                                let pictureURL = item["picture"] as? String
                                                if pictureURL == nil
                                                {
                                                    images[id!] = nil
                                                }
                                                
                                                if self.objectIds.count == 20
                                                {
                                                    
                                                    self.spinner.stopAnimating()
                                                    NSUserDefaults.standardUserDefaults().setObject(self.objectIds, forKey: "objectIds")
                                                    NSUserDefaults.standardUserDefaults().setObject(self.messages, forKey: "messages")
                                                    NSUserDefaults.standardUserDefaults().setObject(self.highResImagesURLs, forKey: "highResImageURLs")
                                                    NSUserDefaults.standardUserDefaults().setObject(pictureURLs, forKey: "pictureURLs")
                                                    NSUserDefaults.standardUserDefaults().setObject(self.likes, forKey: "likes")
                                                    NSUserDefaults.standardUserDefaults().setObject(self.dates, forKey: "dates")
                                                    NSUserDefaults.standardUserDefaults().setObject(self.attachments, forKey: "attachments")
                                                    self.tableView.reloadData()
                                                    refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
                                                    refresher.addTarget(self, action: #selector(feedTableView.refresh), forControlEvents: UIControlEvents.ValueChanged)
                                                }
                                                
                                            }
                                            
                                            print(messages)
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
            attachments = NSUserDefaults.standardUserDefaults().objectForKey("attachments") as! [String:[String:AnyObject]]
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
        
        if pictureURLs[objectIds[indexPath.row]] == nil
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("testNoImageFeedCell", forIndexPath: indexPath) as! noImageTestFeedCell
            
            cell.layoutIfNeeded()
            
            cell.paddingView.layer.shadowOffset = CGSizeMake(-0.5, 0.5)
            cell.paddingView.layer.shadowOpacity = 0.4
            cell.paddingView.layer.masksToBounds = false
            let path = UIBezierPath(rect: cell.paddingView.bounds)
            cell.paddingView.layer.shadowPath = path.CGPath
            
            cell.message.text = messages[indexPath.row]
            cell.likes.text = String(likes[indexPath.row])
            cell.date.text = String(dates[indexPath.row])
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("testCell", forIndexPath: indexPath) as! testFeedCell
        
        cell.layoutIfNeeded()
        
        cell.message.text = messages[indexPath.row]
        cell.likes.text = String(likes[indexPath.row])
        cell.date.text = String(dates[indexPath.row])
        
        cell.paddingView.layer.shadowOffset = CGSizeMake(-0.5, 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        cell.paddingView.layer.masksToBounds = false
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.CGPath
    
        
        if cell.message.text == ""
        {
            cell.message.text = "No description available"
        }
    
        if pictureURLs[objectIds[indexPath.row]] != nil
        {

            cell.societyImage.setIndicatorStyle(UIActivityIndicatorViewStyle.White)
            cell.societyImage.setShowActivityIndicatorView(true)
            cell.societyImage.sd_setImageWithURL(NSURL(string: pictureURLs[objectIds[indexPath.row]]!),completed: { (image, error, cache, url) in
                
                cell.societyImage.layer.shadowRadius = 2
                cell.societyImage.layer.borderColor = UIColor.clearColor().CGColor
                cell.societyImage.layer.shadowColor = UIColor.blackColor().CGColor
                cell.societyImage.layer.shadowOffset = CGSizeMake(0, 5)
                cell.societyImage.layer.shadowOpacity = 0.4
                cell.societyImage.layer.masksToBounds = false
            })
        }
        
        
        
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
        passAttachments = attachments[objectIds[indexPath.row]]
        if passMessage == nil || passMessage == ""
        {
            self.performSegueWithIdentifier("homeToImageSegue", sender: self)
            return;
        }
        if passImageURL == nil
        {
            self.performSegueWithIdentifier("homeToNoImageFeedPage", sender: self)
            return
        }
        self.performSegueWithIdentifier("fbFeedToInstantArticleSegue", sender: self)
        
    }
    
   
    
   override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if refresher.refreshing
        {
            if !isAnimating
            {

                animateRefreshStep1()
            }
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        let currentOffset : CGFloat = scrollView.contentOffset.y;
        let maximumOffset : CGFloat =  scrollView.contentSize.height - scrollView.frame.size.height;
        
        if maximumOffset - currentOffset <= 0
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
            navigationBarActivityIndicator.color = UIColor(red: 1/256, green: 178/255, blue: 155/255, alpha: 1)
            navigationBarActivityIndicator.startAnimating()
            
            let loadMorePostsURL = NSURL(string: next20)
            let task = NSURLSession.sharedSession().dataTaskWithURL(loadMorePostsURL!, completionHandler: { (data, response, error) -> Void in
                
                print(next20)
                
                if error != nil
                {
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        print(error)
                        
                        self.view.makeToast("An error occurred. Please try again later", duration: 1, position: CSToastPositionBottom)
                        
                        //stopping activity indicators and resetting next page URl and number of scrolls
                        navigationBarActivityIndicator.stopAnimating()
                        self.navigationItem.rightBarButtonItem = nil
                        didScrollOnce = false
                        numberOfLoads += 0
                        
                        //saving all arrays, dictionaries and variables in the current state to user defaults
                        NSUserDefaults.standardUserDefaults().setObject(self.objectIds, forKey: "objectIds")
                        NSUserDefaults.standardUserDefaults().setObject(self.messages, forKey: "messages")
                        NSUserDefaults.standardUserDefaults().setObject(self.highResImagesURLs, forKey: "highResImageURLs")
                        NSUserDefaults.standardUserDefaults().setObject(pictureURLs, forKey: "pictureURLs")
                        NSUserDefaults.standardUserDefaults().setObject(self.likes, forKey: "likes")
                        NSUserDefaults.standardUserDefaults().setObject(self.dates, forKey: "dates")
                        NSUserDefaults.standardUserDefaults().setObject(self.attachments, forKey: "attachments")
                        NSUserDefaults.standardUserDefaults().setObject(numberOfLoads, forKey: "numberOfLoads")
                        NSUserDefaults.standardUserDefaults().setObject(next20, forKey: "next20")
                        
                    })
                    
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
                                    
                                    if jsonData["error"] != nil
                                    {
                                        navigationBarActivityIndicator.stopAnimating()
                                        didScrollOnce = false
                                        return
                                    }
                                    
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
                                                self.attachments[item["id"] as! String] = attachments
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
                                                                                self.highResImagesURLs[item["id"] as! String] = src
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
                                                                    
                                                                    self.highResImagesURLs[item["id"] as! String] = src
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                            
                                            if item["message"] == nil
                                            {
                                                self.messages.append("")
                                            }
                                            if item["message"] != nil
                                            {
                                                self.messages.append(item["message"] as! String)
                                            }
                                            
                                            if item["created_time"] != nil
                                            {
                                                
                                                let fbDate = item["created_time"] as! String
                                                let dateFormatter = NSDateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
                                                let newDate = dateFormatter.dateFromString(fbDate)!
                                                dateFormatter.dateFormat = "dd-MM-yyyy,HH:mm"
                                                let dateString = dateFormatter.stringFromDate(newDate)
                                                self.dates.append(dateString)
                                            }
                                            
                                            
                                            self.objectIds.append(item["id"] as! String)
                                            pictureURLs[item["id"] as! String] = item["picture"] as? String
                                            
                                            
                                            
                                            let pictureId = item["object_id"] as? String
                                            if pictureId != nil
                                            {
                                                self.pictureIds[item["id"] as! String] = pictureId
                                                
                                            }
                                            
                                            let like = item["likes"]
                                            let summary = like!["summary"]
                                            let count = summary!!["total_count"]
                                            self.likes.append(count as! NSInteger)
                                            
                                            //society.append(name as! String)
                                            
                                            let id = item["id"] as? String
                                            let pictureURL = item["picture"] as? String
                                            if pictureURL == nil
                                            {
                                                images[id!] = nil
                                            }
                                            
                                            if self.objectIds.count%20 == 0
                                            {
                                                self.tableView.reloadData()
                                                navigationBarActivityIndicator.stopAnimating()
                                                self.navigationItem.rightBarButtonItem = nil
                                                didScrollOnce = false
                                                numberOfLoads += 1
                                                NSUserDefaults.standardUserDefaults().setObject(self.objectIds, forKey: "objectIds")
                                                NSUserDefaults.standardUserDefaults().setObject(self.messages, forKey: "messages")
                                                NSUserDefaults.standardUserDefaults().setObject(self.highResImagesURLs, forKey: "highResImageURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(pictureURLs, forKey: "pictureURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(self.likes, forKey: "likes")
                                                NSUserDefaults.standardUserDefaults().setObject(self.dates, forKey: "dates")
                                                NSUserDefaults.standardUserDefaults().setObject(numberOfLoads, forKey: "numberOfLoads")
                                                NSUserDefaults.standardUserDefaults().setObject(self.attachments, forKey: "attachments")
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
    
    //MARK : Pull to refresh function
    func refresh()
    {
        
        if Reachability.isConnectedToNetwork() == false
        {
            
            let alert = NYAlertViewController()
            alert.title = "No internet connection available"
            alert.message = "Please connect to the internet"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            
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
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        refresher.endRefreshing()
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    })
                    
                }
                    
                else
                {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let data = data
                        {
                            do
                            {
                                
                                self.messages.removeAll()
                                self.objectIds.removeAll()
                                self.likes.removeAll()
                                //society.removeAll()
                                pictureURLs.removeAll()
                                self.dates.removeAll()
                                self.highResImagesURLs.removeAll()
                                self.attachments.removeAll()
                                
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
                                                self.attachments[item["id"] as! String] = attachments
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
                                                                                self.highResImagesURLs[item["id"] as! String] = src
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
                                                                    self.highResImagesURLs[item["id"] as! String] = src
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                            
                                            
                                            if item["message"] != nil
                                            {
                                                self.messages.append(item["message"] as! String)
                                            }
                                            self.objectIds.append(item["id"] as! String)
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
                                                self.dates.append(dateString)
                                            }
                                            
                                            
                                            let pictureId = item["object_id"] as? String
                                            if pictureId != nil
                                            {
                                                self.pictureIds[item["id"] as! String] = pictureId
                                                
                                            }
                                            
                                            let like = item["likes"]
                                            let summary = like!["summary"]
                                            let count = summary!!["total_count"]
                                            self.likes.append(count as! NSInteger)
                                            
                                            
                                            let id = item["id"] as? String
                                            let pictureURL = item["picture"] as? String
                                            if pictureURL == nil
                                            {
                                                images[id!] = nil
                                            }
                                            
                                            if self.objectIds.count == 20
                                            {
                                                numberOfLoads = 1
                                                NSUserDefaults.standardUserDefaults().setObject(self.objectIds, forKey: "objectIds")
                                                NSUserDefaults.standardUserDefaults().setObject(self.messages, forKey: "messages")
                                                NSUserDefaults.standardUserDefaults().setObject(self.highResImagesURLs, forKey: "highResImageURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(pictureURLs, forKey: "pictureURLs")
                                                NSUserDefaults.standardUserDefaults().setObject(self.likes, forKey: "likes")
                                                NSUserDefaults.standardUserDefaults().setObject(self.dates, forKey: "dates")
                                                NSUserDefaults.standardUserDefaults().setObject(numberOfLoads, forKey: "numberOfLoads")
                                                NSUserDefaults.standardUserDefaults().setObject(self.attachments, forKey: "attachments")
                                                NSUserDefaults.standardUserDefaults().setObject(next20, forKey: "next20")
                                                refresher.endRefreshing()
                                                self.tableView.reloadData()
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
    
    
    override func viewWillLayoutSubviews() {
        
        spinner.center = CGPointMake(self.view.center.x, self.view.center.y-100)
        
    }
    
    func loadCustomViewContents()
    {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents[0] as! UIView
        customView.frame = refresher.bounds
        
        for i in 0 ..< customView.subviews.count
        {
            labelsArray.append(customView.viewWithTag(i+1) as! UILabel)
        }
        
        refresher.backgroundColor = UIColor.clearColor()
        refresher.tintColor = UIColor.clearColor()
        refresher.addSubview(customView)
        
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
                        if refresher.refreshing {
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
    
}
