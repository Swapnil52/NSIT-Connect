//
//  customFeedTable.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 17/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import QuartzCore
import SWRevealViewController
import Toast
import NYAlertViewController

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

class customFeedTable: UITableViewController {
    
    //variables to polulate the tableView
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
    var fbFeedAttachments = [String : [String:AnyObject]]()
    var refreshOnce = 0
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAnimating = false
        currentColorIndex = 0
        currentLabelIndex = 0
        customView = UIView()
        labelsArray.removeAll()
        
        promptToRefresh()
        self.tableView.separatorColor = UIColor.clearColor()
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        //fbFeedRefresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        loadCustomViewContents()
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
            
            if NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil || NSUserDefaults.standardUserDefaults().objectForKey("fbFeedAttachments") == nil
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
                    fbFeedAttachments.removeAll()
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
                fbFeedAttachments = NSUserDefaults.standardUserDefaults().objectForKey("fbFeedAttachments") as! [String:[String:AnyObject]]
                self.tableView.reloadData()
                
            }
        }
        
        
        
        //print(selectedFeeds)
        //print(empty)
        
        
        
        //print(fbPagesObjectIds)
        
        
        let settings = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(customFeedTable.action))
        self.navigationItem.rightBarButtonItem = settings
        
//        let alert = UIAlertController(title: "Oops!", message: "Select societies to view feeds of?", preferredStyle: UIAlertControllerStyle.Alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//            
//            self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
//            
//        }))
//        self.presentViewController(alert, animated: true, completion: nil)
        
        let alert = NYAlertViewController()
        alert.title = "Oops!"
        alert.message = "Select societies to view feeds of?"
        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(false, completion: nil)
            self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
            
        }))
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil && Reachability.isConnectedToNetwork() == false
        {
//            let alert = UIAlertController(title: "Can't load posts", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
//                
//                self.navigationController?.popViewControllerAnimated(true)
//                
//            }))
//            self.presentViewController(alert, animated: true, completion: nil)
            
            let alert = NYAlertViewController()
            alert.title = "Can't Load Posts"
            alert.message = "Please connect to the internet"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(false, completion: nil)
                
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
    
    
    //function to display a toast message if the user is opening the app for the first time and doesn't have a working internet connection
    
    func promptToRefresh()
    {
        if NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil && Reachability.isConnectedToNetwork() == false
        {
            
            self.view.makeToast("Please pull to refresh when the internet connection is re-established", duration: 1, position: CSToastPositionTop)
        
        }
    }
    
    
    
    //MARK
    func refresh()
    {
        
        if NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil || NSUserDefaults.standardUserDefaults().objectForKey("fbFeedAttachments") == nil
        {
            let alert = NYAlertViewController()
            alert.title = "Oops!"
            alert.message = "Select societies to view feeds of?"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(false, completion: nil)
                self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
                currentSelectedFeeds = selectedFeeds
                self.fbFeedRefresher.endRefreshing()
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
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
            fbFeedAttachments.removeAll()
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
            if empty != 0 
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
            
//            let alert = UIAlertController(title: "Refresh failed", message: "Please connect to the internet", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
            
            let alert = NYAlertViewController()
            alert.title = "Refresh Failed"
            alert.message = "Please connect to the internet"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            fbFeedRefresher.endRefreshing()
        }

        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        print(didGoToSettings)
        print(didGoToFeedPage)
        
        if Reachability.isConnectedToNetwork() == false
        {
            self.view.makeToast("Internet connection unavailable", duration: 2, position: CSToastPositionTop)
        }
        
        refreshOnce = 0
        if didGoToSettings == true && Reachability.isConnectedToNetwork() == false
        {
            empty = 0
            for (_, j) in currentSelectedFeeds
            {
                
                if j == true
                {
                    empty+=1
                }
            }
            
            selectedFeeds = currentSelectedFeeds
            NSUserDefaults.standardUserDefaults().setObject(selectedFeeds, forKey: "selectedFeeds")
            NSUserDefaults.standardUserDefaults().setObject(empty, forKey: "empty")
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
                        fbFeedAttachments.removeAll()
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
                        
//                        let alert = UIAlertController(title: "Oops!", message: "Select societies to view feeds of?", preferredStyle: UIAlertControllerStyle.Alert)
//                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                            
//                            self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
//                            
//                        }))
//                        
//                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        let alert = NYAlertViewController()
                        alert.title = "Oops!"
                        alert.message = "Select societies to view feeds of?"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(false, completion: { 
                                
                                self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
                                
                            })
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                
                didGoToSettings = false

            }
            
            else
            {
                
//                let alert = UIAlertController(title: "Oops!", message: "Select societies to view feeds of?", preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                    
//                    self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
//                    
//                }))
//                
//                self.presentViewController(alert, animated: true, completion: nil)
                
                let alert = NYAlertViewController()
                alert.title = "Oops!"
                alert.message = "Select societies to view feeds of?"
                alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                    
                    self.dismissViewControllerAnimated(false, completion: {
                        
                        self.performSegueWithIdentifier("feedSettingsSegue", sender: self)
                        
                    })
                    
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
        
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if fbFeedThumbnailURLs[fbFeedIds[indexPath.row]] == nil
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("noImageTestCustomFeedCell", forIndexPath: indexPath) as! noImageTestCustomFeedCell
            
            cell.layoutIfNeeded()
            
            let path = UIBezierPath(rect: cell.paddingView.bounds)
            cell.paddingView.layer.shadowPath = path.CGPath
            cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
            cell.paddingView.layer.shadowOpacity = 0.4
            
            cell.message.text = fbFeedMessages[indexPath.row]
            cell.societyName.text = fbFeedSociety[indexPath.row]
            cell.date.text = fbFeedDates[indexPath.row]
            cell.likes.text = String(fbFeedLikes[indexPath.row])
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("testCustomFeedCell", forIndexPath: indexPath) as! testCustomFeedCell
        
        cell.layoutIfNeeded()
        
        cell.message.text = fbFeedMessages[indexPath.row]
        if fbFeedMessages[indexPath.row] == ""
        {
            cell.message.text = "No description available"
        }
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.CGPath
        cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        cell.thumbnail.layer.masksToBounds = true
        if fbFeedThumbnailURLs[fbFeedIds[indexPath.row]] != nil
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
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        print(error)
                        feedPageSpinner.stopAnimating()
                        if self.fbFeedRefresher.refreshing == true
                        {
                            self.fbFeedRefresher.endRefreshing()
                            self.refreshOnce = 0
                        }
                        let alert = NYAlertViewController()
                        alert.title = "An error occured"
                        alert.message = "Please try again"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.tableView.reloadData()
                        
                    })
                    
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        do
                        {
                        
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
                                            self.fbFeedAttachments[item["id"] as! String] = attachments
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
                                                                            self.fbPassHighResImageURLs[id!] = src
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
                                                                self.fbPassHighResImageURLs[id!] = src
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                                
                                            }
                                        }
                                        
                                        
                                        
                                        //Adding the message to be displayed
                                        if item["message"] != nil
                                        {
                                            self.fbFeedMessages.append(item["message"] as! String)
                                        }
                                        if item["message"] == nil || item["message"] as? String == ""
                                        {
                                            self.fbFeedMessages.append("")
                                        }
                                        
                                        self.fbFeedIds.append(item["id"] as! String)
                                        
                                        if let from  = item["from"] as? [String:AnyObject]
                                        {
                                            self.fbFeedSociety.append(from["name"] as! String)
                                        }
                                        
                                        //Adding the URL for the thumbnail
                                        if item["picture"] != nil
                                        {
                                            self.fbFeedThumbnailURLs[item["id"] as! String] = item["picture"] as? String
                                            
                                        }
                                        
                                        //adding the high res picture id
                                        let pictureId = item["object_id"] as? String
                                        if pictureId == nil
                                        {
                                            self.fbFeedPictureIds[item["id"] as! String] = nil
                                        }
                                        else
                                        {
                                            self.fbFeedPictureIds[item["id"] as! String] = pictureId
                                        }
                                        
                                        //Adding the post likes
                                        let likes = item["likes"]
                                        let summary = likes!["summary"]
                                        let totalCount = summary!!["total_count"] as! NSInteger
                                        self.fbFeedLikes.append(totalCount)
                                        
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
                                            self.fbFeedDates.append(dateString)
                                        }
                                        
                                        if item["picture"]  == nil
                                        {
                                            self.fbFeedThumbnailURLs[item["id"] as! String] = nil
                                            self.fbFeedImages[item["id"] as! String] = nil
                                        }
                                        
                                        if self.fbFeedIds.count%20 == 0
                                        {
                                            self.tableView.reloadData()
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedIds, forKey: "fbFeedIds")
                                            NSUserDefaults.standardUserDefaults().setObject(fbPagesObjectIds, forKey: "fbPagesObjectIds")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedMessages, forKey: "fbFeedMessages")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedPictureURLs, forKey: "fbFeedPictureURLs")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedSociety, forKey: "fbFeedSociety")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedThumbnailURLs, forKey: "fbFeedThumbnailURLs")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbPassHighResImageURLs, forKey: "fbPassHighResImageURLs")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedDates, forKey: "fbFeedDates")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedLikes, forKey: "fbFeedLikes")
                                            NSUserDefaults.standardUserDefaults().setObject(self.fbFeedAttachments, forKey: "fbFeedAttachments")
                                            feedPageSpinner.stopAnimating()
                                            self.fbFeedRefresher.endRefreshing()
                                            self.refreshOnce = 0
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
        passAttachments = fbFeedAttachments[passObjectId]
        didGoToFeedPage = true
        
        if passImageURL == nil || passImageURL == ""
        {

            self.performSegueWithIdentifier("customFeedToNoImage", sender: self)
            return
        }
        
        if (passMessage == nil || passMessage == "")
        {
            if Reachability.isConnectedToNetwork() == true
            {
            self.performSegueWithIdentifier("customFeedToImage", sender: self)
            }
            else
            {
                
                let alert = NYAlertViewController()
                alert.title = "Unable to download Full Resolution Image"
                alert.message = "Please connect to the internet"
                alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in

                    self.dismissViewControllerAnimated(true, completion: nil)

                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            return
        }
        self.performSegueWithIdentifier("customFeedToInstantArticleSegue", sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false && (NSUserDefaults.standardUserDefaults().objectForKey("fbFeedIds") == nil || NSUserDefaults.standardUserDefaults().objectForKey("fbFeedAttachments") == nil)
        {
            
            let alert = NYAlertViewController()
            alert.title = "Internet Connection Unavailable"
            alert.message = "Please connect to the internet"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in

                self.dismissViewControllerAnimated(true, completion: nil)

            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    
    //Setting up the custom refresh control and its animations
    
    func loadCustomViewContents()
    {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents![0] as! UIView
        customView.frame = fbFeedRefresher.bounds
        
        for i in 0 ..< customView.subviews.count
        {
            labelsArray.append(customView.viewWithTag(i+1) as! UILabel)
        }
        
        fbFeedRefresher.backgroundColor = UIColor.clearColor()
        fbFeedRefresher.tintColor = UIColor.clearColor()
        fbFeedRefresher.addSubview(customView)
        
    }
    
    func animateRefreshStep1() {
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
    
    
    func animateRefreshStep2() {
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
                        if self.fbFeedRefresher.refreshing {
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
    
    
    
    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magentaColor(), UIColor.brownColor(), UIColor.yellowColor(), UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.orangeColor()]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }
    
    override func viewWillLayoutSubviews() {
        
        feedPageSpinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if fbFeedRefresher.refreshing
        {
            if !isAnimating
            {
                
                animateRefreshStep1()
            }
        }
    }
    
}
