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
import MWPhotoBrowser

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

class customFeedTable: UITableViewController, MWPhotoBrowserDelegate {
    
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
    var photos = [MWPhoto]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isAnimating = false
        currentColorIndex = 0
        currentLabelIndex = 0
        customView = UIView()
        labelsArray.removeAll()
        
        promptToRefresh()
        self.tableView.separatorColor = UIColor.clear
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        //fbFeedRefresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        loadCustomViewContents()
        fbFeedRefresher.addTarget(self, action: #selector(customFeedTable.refresh), for: UIControlEvents.valueChanged)
        self.view.addSubview(fbFeedRefresher)
        print("view loaded!")
        didGoToFeedPage = false
        fbCustomFeedToHome = false
        didGoToSettings = false
        feedPageSpinner.activityIndicatorViewStyle = .gray
        feedPageSpinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        feedPageSpinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        
        feedPageSpinner.hidesWhenStopped = true
        feedPageSpinner.layer.cornerRadius = 10
        feedPageSpinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        feedPageSpinner.startAnimating()
        self.view.addSubview(feedPageSpinner)
        
        if UserDefaults.standard.object(forKey: "empty") == nil
        {
            empty = 0
        }
        
        else
        {
            empty = UserDefaults.standard.object(forKey: "empty") as! Int
        }
        
        if UserDefaults.standard.object(forKey: "selectedFeeds") == nil
        {
            selectedFeeds = ["184835371535420":false, "252117054812001":false, "109582689081817":false, "158168947539641":false, "604809706256620":false, "376394819102290":false, "278952135548721":false, "126976547314225":false, "185960271431856":false, "135639763273290":false, "499766883378107":false, "1457237581165961":false]
        }
        else
        {
            selectedFeeds = UserDefaults.standard.object(forKey: "selectedFeeds") as! [String:Bool]
            
            if UserDefaults.standard.object(forKey: "fbFeedIds") == nil || UserDefaults.standard.object(forKey: "fbFeedAttachments") == nil
            {
                print("fbFeedIds was nil")
                fbPagesObjectIds.removeAll(keepingCapacity: true)
                
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
                    
                    DispatchQueue.main.async { () -> Void in
                        
                        self.loader(fbPagesURLS)
                        
                    }
                }
                
            }
            else
            {
                
                feedPageSpinner.stopAnimating()
                fbFeedMessages = UserDefaults.standard.object(forKey: "fbFeedMessages") as! [String]
                fbFeedIds = UserDefaults.standard.object(forKey: "fbFeedIds") as! [String]
                fbFeedPictureURLs = UserDefaults.standard.object(forKey: "fbFeedPictureURLs") as! [String:String]
                fbFeedDates = UserDefaults.standard.object(forKey: "fbFeedDates") as! [String]
                fbFeedLikes = UserDefaults.standard.object(forKey: "fbFeedLikes") as! [NSInteger]
                fbFeedSociety = UserDefaults.standard.object(forKey: "fbFeedSociety") as! [String]
                fbFeedThumbnailURLs = UserDefaults.standard.object(forKey: "fbFeedThumbnailURLs") as! [String:String]
                fbPassHighResImageURLs = UserDefaults.standard.object(forKey: "fbPassHighResImageURLs") as! [String:String]
                fbFeedAttachments = UserDefaults.standard.object(forKey: "fbFeedAttachments") as! [String:[String:AnyObject]]
                self.tableView.reloadData()
                
            }
        }
        
        
        
        //print(selectedFeeds)
        //print(empty)
        
        
        
        //print(fbPagesObjectIds)
        
        
        let settings = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.plain, target: self, action: #selector(customFeedTable.action))
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
        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.dismiss(animated: false, completion: nil)
            self.performSegue(withIdentifier: "feedSettingsSegue", sender: self)
            
        }))
        
        
        if UserDefaults.standard.object(forKey: "fbFeedIds") == nil && Reachability.isConnectedToNetwork() == false
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
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: false, completion: nil)
                
            }))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        if empty == 0
        {
            self.present(alert, animated: true, completion: nil)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fbFeedMessages.count
    }
    
    func action()
    {
        
        currentSelectedFeeds = selectedFeeds
        self.performSegue(withIdentifier: "feedSettingsSegue", sender: self)
        
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
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
        if UserDefaults.standard.object(forKey: "fbFeedIds") == nil && Reachability.isConnectedToNetwork() == false
        {
            
            self.view.makeToast("Please pull to refresh when the internet connection is re-established", duration: 1, position: CSToastPositionTop)
        
        }
    }
    
    
    
    //MARK
    func refresh()
    {
        
        if UserDefaults.standard.object(forKey: "fbFeedIds") == nil || UserDefaults.standard.object(forKey: "fbFeedAttachments") == nil
        {
            let alert = NYAlertViewController()
            alert.title = "Oops!"
            alert.message = "Select societies to view feeds of?"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "feedSettingsSegue", sender: self)
                currentSelectedFeeds = selectedFeeds
                self.fbFeedRefresher.endRefreshing()
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if Reachability.isConnectedToNetwork() == true
        {
            fbPagesObjectIds.removeAll(keepingCapacity: true)
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
                
                DispatchQueue.main.async { () -> Void in
                    
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
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            self.present(alert, animated: true, completion: nil)
            fbFeedRefresher.endRefreshing()
        }

        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
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
            UserDefaults.standard.set(selectedFeeds, forKey: "selectedFeeds")
            UserDefaults.standard.set(empty, forKey: "empty")
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
                selectedFeeds = UserDefaults.standard.object(forKey: "selectedFeeds") as! [String:Bool]
                
                    
                    fbPagesObjectIds.removeAll(keepingCapacity: true)
                    
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
                        
                        DispatchQueue.main.async { () -> Void in
                            
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
                        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            self.dismiss(animated: false, completion: { 
                                
                                self.performSegue(withIdentifier: "feedSettingsSegue", sender: self)
                                
                            })
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
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
                alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                    self.dismiss(animated: false, completion: {
                        
                        self.performSegue(withIdentifier: "feedSettingsSegue", sender: self)
                        
                    })
                    
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if fbFeedThumbnailURLs[fbFeedIds[(indexPath as NSIndexPath).row]] == nil
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noImageTestCustomFeedCell", for: indexPath) as! noImageTestCustomFeedCell
            
            cell.layoutIfNeeded()
            
            let path = UIBezierPath(rect: cell.paddingView.bounds)
            cell.paddingView.layer.shadowPath = path.cgPath
            cell.paddingView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            cell.paddingView.layer.shadowOpacity = 0.4
            
            cell.message.text = fbFeedMessages[(indexPath as NSIndexPath).row]
            cell.societyName.text = fbFeedSociety[(indexPath as NSIndexPath).row]
            cell.date.text = fbFeedDates[(indexPath as NSIndexPath).row]
            cell.likes.text = String(fbFeedLikes[(indexPath as NSIndexPath).row])
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCustomFeedCell", for: indexPath) as! testCustomFeedCell
        
        cell.layoutIfNeeded()
        
        cell.message.text = fbFeedMessages[(indexPath as NSIndexPath).row]
        if fbFeedMessages[(indexPath as NSIndexPath).row] == ""
        {
            cell.message.text = "No description available"
        }
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.cgPath
        cell.paddingView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        cell.thumbnail.layer.masksToBounds = true
        if fbFeedThumbnailURLs[fbFeedIds[(indexPath as NSIndexPath).row]] != nil
        {
            
            cell.thumbnail.setShowActivityIndicator(true)
            cell.thumbnail.setIndicatorStyle(UIActivityIndicatorViewStyle.white)
            cell.thumbnail.sd_setImage(with: URL(string: fbFeedThumbnailURLs[fbFeedIds[(indexPath as NSIndexPath).row]]!), completed: { (image, error, cache, url) in
                
                
            })
            
            
        }
        
        if fbFeedThumbnailURLs[fbFeedIds[(indexPath as NSIndexPath).row]] == nil
        {
            
            if cell.message.text == fbFeedMessages[(indexPath as NSIndexPath).row]
            {
                //cell.messageLeft.constant -= 190
                //imageSet.addObject(indexPath)
            }
            
        }
        
        //setting up shadow
        cell.thumbnail.layer.shadowColor = UIColor.black.cgColor
        cell.thumbnail.layer.shadowOffset = CGSize(width: 0, height: 5)
        cell.thumbnail.layer.shadowOpacity = 1.0
        cell.thumbnail.layer.masksToBounds = false
        
        cell.societyName.text = fbFeedSociety[(indexPath as NSIndexPath).row]
        cell.date.text = fbFeedDates[(indexPath as NSIndexPath).row]
        cell.likes.text = String(fbFeedLikes[(indexPath as NSIndexPath).row])
        return cell
    }
    
    func loader(_ array : [String])
    {
        
        if counter < array.count
        {
            
            let url = URL(string: array[counter])
            //print(url)
            //print("---")
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                
                if error != nil
                {
                    
                    DispatchQueue.main.async(execute: { 
                        
                        print(error)
                        feedPageSpinner.stopAnimating()
                        if self.fbFeedRefresher.isRefreshing == true
                        {
                            self.fbFeedRefresher.endRefreshing()
                            self.refreshOnce = 0
                        }
                        let alert = NYAlertViewController()
                        alert.title = "An error occured"
                        alert.message = "Please try again"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        self.tableView.reloadData()
                        
                    })
                    
                }
                else
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        do
                        {
                        
                            let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            
                            if let jsonData = jsonData as? [String:AnyObject]
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
                                        let likes = item["likes"] as? [String:AnyObject]
                                        let summary = likes!["summary"] as? [String:AnyObject]
                                        let totalCount = summary!["total_count"] as! NSInteger
                                        self.fbFeedLikes.append(totalCount)
                                        
                                        //Adding the creation time
                                        if item["created_time"] != nil
                                        {
                                            let fbDate = item["created_time"] as! String
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
                                            let newDate = dateFormatter.date(from: fbDate)!
                                            dateFormatter.amSymbol = "AM"
                                            dateFormatter.pmSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, HH:mm a"
                                            let dateString = dateFormatter.string(from: newDate)
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
                                            UserDefaults.standard.set(self.fbFeedIds, forKey: "fbFeedIds")
                                            UserDefaults.standard.set(fbPagesObjectIds, forKey: "fbPagesObjectIds")
                                            UserDefaults.standard.set(self.fbFeedMessages, forKey: "fbFeedMessages")
                                            UserDefaults.standard.set(self.fbFeedPictureURLs, forKey: "fbFeedPictureURLs")
                                            UserDefaults.standard.set(self.fbFeedSociety, forKey: "fbFeedSociety")
                                            UserDefaults.standard.set(self.fbFeedThumbnailURLs, forKey: "fbFeedThumbnailURLs")
                                            UserDefaults.standard.set(self.fbPassHighResImageURLs, forKey: "fbPassHighResImageURLs")
                                            UserDefaults.standard.set(self.fbFeedDates, forKey: "fbFeedDates")
                                            UserDefaults.standard.set(self.fbFeedLikes, forKey: "fbFeedLikes")
                                            UserDefaults.standard.set(self.fbFeedAttachments, forKey: "fbFeedAttachments")
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
                
            }) 
            task.resume()
            
            counter += 1;
        }
            
        else
        {
            return
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        passMessage = fbFeedMessages[(indexPath as NSIndexPath).row]
        passLikes = fbFeedLikes[(indexPath as NSIndexPath).row]
        passObjectId = fbFeedIds[(indexPath as NSIndexPath).row]
        passImageURL = fbFeedThumbnailURLs[passObjectId]
        passPictureId = fbFeedPictureIds[passObjectId]
        passImage = fbFeedImages[fbFeedIds[(indexPath as NSIndexPath).row]]
        currentSelectedFeeds = selectedFeeds
        passHighResImageURL = fbPassHighResImageURLs[passObjectId]
        passAttachments = fbFeedAttachments[passObjectId]
        didGoToFeedPage = true
        self.photos.removeAll()
        
        if passImageURL == nil || passImageURL == ""
        {

            self.performSegue(withIdentifier: "customFeedToNoImage", sender: self)
            return
        }
        
        if (passMessage == nil || passMessage == "")
        {
            if Reachability.isConnectedToNetwork() == true
            {
                
                //self.performSegue(withIdentifier: "customFeedToImage", sender: self)
                
                let browser = MWPhotoBrowser()
                browser.delegate = self
                if let attachments = passAttachments
                {
                    if let data = attachments["data"] as? [[String:AnyObject]]
                    {
                        for dataItem in data
                        {
                            if let subattachments = dataItem["subattachments"] as? [String:AnyObject]
                            {
                                if let subData = subattachments["data"] as? [[String:AnyObject]]
                                {
                                    for subDataItem in subData
                                    {
                                        if let media = subDataItem["media"] as? [String:AnyObject]
                                        {
                                            if let image = media["image"] as? [String:AnyObject]
                                            {
                                                if let src = image["src"] as? String
                                                {
                                                    photos.append(MWPhoto(url: URL(string: src)!))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if let media = dataItem["media"] as? [String:AnyObject]
                                {
                                    if let image = media["image"] as? [String:AnyObject]
                                    {
                                        if let src = image["src"] as? String
                                        {
                                            photos.append(MWPhoto(url: URL(string : src)!))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                self.navigationController?.pushViewController(browser, animated: true)
            
            }
            else
            {
                
                let alert = NYAlertViewController()
                alert.title = "Unable to download Full Resolution Image"
                alert.message = "Please connect to the internet"
                alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in

                    self.dismiss(animated: true, completion: nil)

                }))
                self.present(alert, animated: true, completion: nil)
                
            }
            return
        }
        self.performSegue(withIdentifier: "customFeedToInstantArticleSegue", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Reachability.isConnectedToNetwork() == false && (UserDefaults.standard.object(forKey: "fbFeedIds") == nil || UserDefaults.standard.object(forKey: "fbFeedAttachments") == nil)
        {
            
            let alert = NYAlertViewController()
            alert.title = "Internet Connection Unavailable"
            alert.message = "Please connect to the internet"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in

                self.dismiss(animated: true, completion: nil)

            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //MARK : MWPhotoBrowserDelegate methods
    
    public func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt
    {
        
        return UInt(self.photos.count)
        
    }
    
    public func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol!
    {
        
        return photos[Int(index)]
        
    }
    
    
    //Setting up the custom refresh control and its animations
    
    func loadCustomViewContents()
    {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents![0] as! UIView
        customView.frame = fbFeedRefresher.bounds
        
        for i in 0 ..< customView.subviews.count
        {
            labelsArray.append(customView.viewWithTag(i+1) as! UILabel)
        }
        
        fbFeedRefresher.backgroundColor = UIColor.clear
        fbFeedRefresher.tintColor = UIColor.clear
        fbFeedRefresher.addSubview(customView)
        
    }
    
    func animateRefreshStep1() {
        isAnimating = true
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            labelsArray[currentLabelIndex].transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
            labelsArray[currentLabelIndex].textColor = self.getNextColor()
            
            }, completion: { (finished) -> Void in
                
                UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                    labelsArray[currentLabelIndex].transform = CGAffineTransform.identity
                    labelsArray[currentLabelIndex].textColor = UIColor.black
                    
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
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            labelsArray[0].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            labelsArray[1].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            labelsArray[2].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            labelsArray[3].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            labelsArray[4].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            labelsArray[5].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            labelsArray[6].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            }, completion: { (finished) -> Void in
                UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                    labelsArray[0].transform = CGAffineTransform.identity
                    labelsArray[1].transform = CGAffineTransform.identity
                    labelsArray[2].transform = CGAffineTransform.identity
                    labelsArray[3].transform = CGAffineTransform.identity
                    labelsArray[4].transform = CGAffineTransform.identity
                    labelsArray[5].transform = CGAffineTransform.identity
                    labelsArray[6].transform = CGAffineTransform.identity
                    
                    }, completion: { (finished) -> Void in
                        if self.fbFeedRefresher.isRefreshing {
                            currentLabelIndex = 0
                            self.animateRefreshStep1()
                        }
                        else {
                            isAnimating = false
                            currentLabelIndex = 0
                            for i in 0 ..< labelsArray.count {
                                labelsArray[i].textColor = UIColor.black
                                labelsArray[i].transform = CGAffineTransform.identity
                            }
                        }
                })
        })
    }
    
    
    
    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magenta, UIColor.brown, UIColor.yellow, UIColor.red, UIColor.green, UIColor.blue, UIColor.orange]
        
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
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if fbFeedRefresher.isRefreshing
        {
            if !isAnimating
            {
                
                animateRefreshStep1()
            }
        }
    }
    
}
