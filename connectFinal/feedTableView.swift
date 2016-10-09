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
import MWPhotoBrowser

//Variables to populate the tableView

var pictureURLs = [String : String]()
var images = [String : UIImage]()
var animateCells = [Int]()
var preventAnimation = Set<IndexPath>()

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
var didUpdateApplication = true

var refresher = UIRefreshControl()
var customView = UIView()
var labelsArray = Array<UILabel>()
var isAnimating = false
var currentColorIndex = 0
var currentLabelIndex = 0


class feedTableView: UITableViewController, MWPhotoBrowserDelegate {
    
    var attachments = [String:[String:AnyObject]]()
    var highResImagesURLs = [String:String]()
    var messages = [String]()
    var objectIds = [String]()
    var pictureIds = [String : String]()
    var likes = [NSInteger]()
    var dates = [String]()
    var photos = [MWPhoto]()
    
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
        
        //Need to remove all items in NSUserDefaults if the app has been updated to accomodate the new arrays being stored i.e. attachments along with a bug fix in feedTable.swift
        if UserDefaults.standard.object(forKey: "didUpdateApplication") == nil
        {
            didUpdateApplication = true
        }
        else
        {
            didUpdateApplication = UserDefaults.standard.object(forKey: "didUpdateApplication") as! Bool
        }
        
        if didUpdateApplication == true
        {
            
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            didUpdateApplication = false
            UserDefaults.standard.set(didUpdateApplication, forKey : "didUpdateApplication")
            
            
        }
        
        self.tableView.separatorColor = UIColor.clear
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        self.view.makeToast("Pull to refresh!", duration: 1.5, position: CSToastPositionTop)
        
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        

        refresher.addTarget(self, action: #selector(feedTableView.refresh), for: UIControlEvents.valueChanged)
        refresher.attributedTitle = NSAttributedString(string: "")
        loadCustomViewContents()
        self.view.addSubview(refresher)
        
        if UserDefaults.standard.object(forKey: "objectIds") == nil || UserDefaults.standard.object(forKey: "attachments") == nil
        {
            if Reachability.isConnectedToNetwork() == false
            {
                
                let alert = NYAlertViewController()
                alert.title = "Internet Connection Unavailable"
                alert.message = "Please enable the internet connection"
                alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (ation) in
                    
                    self.dismiss(animated: true, completion: { 
                        
                    })
                    
                }))
                
                self.present(alert, animated: true, completion: {
                    
                    self.view.makeToast("Please pull to refresh when the internet connection is re-established", duration: 1.5, position: CSToastPositionTop)
                    
                })
            }
            else
            {
                spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = .gray
                spinner.layer.cornerRadius = 10
                spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
                self.view.addSubview(spinner)
                spinner.startAnimating()
                //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                
                let url = URL(string: "https://graph.facebook.com/109315262061/posts?limit=20&fields=id,full_picture,picture,from,shares,attachments,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD")
                
                let session = URLSession.shared
                
                let task = session.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                    
                    if error != nil
                    {
                        
                        DispatchQueue.main.async(execute: { 
                            
                            let alert = NYAlertViewController()
                            alert.title = "An Error Occurred"
                            alert.message = "Please try again later"
                            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                                
                                self.dismiss(animated: true, completion: nil)
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                        })
                        
                    }
                        
                    else
                    {
                        
                        DispatchQueue.main.async(execute: { () -> Void in
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
                                    
                                    let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                                    if let jsonData = jsonData as? [String:AnyObject]
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
                                                    
                                                    self.messages.append("")
                                                    
                                                }
                                                
                                                self.objectIds.append(item["id"] as! String)
                                                pictureURLs[item["id"] as! String] = item["picture"] as? String
                                                
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
                                                    self.dates.append(dateString)
                                                }
                                                
                                                
                                                let pictureId = item["object_id"] as? String
                                                
                                                if pictureId != nil
                                                {
                                                    self.pictureIds[item["id"] as! String] = pictureId
                                                    
                                                }
                                                
                                                let like = item["likes"] as? [String:AnyObject]
                                                let summary = like!["summary"] as? [String:AnyObject]
                                                let count = summary!["total_count"] as? NSInteger
                                                self.likes.append(count!)
                                                
                                                
                                                let id = item["id"] as? String
                                                let pictureURL = item["picture"] as? String
                                                if pictureURL == nil
                                                {
                                                    images[id!] = nil
                                                }
                                                
                                                if self.objectIds.count == 20
                                                {
                                                    
                                                    self.spinner.stopAnimating()
                                                    UserDefaults.standard.set(self.objectIds, forKey: "objectIds")
                                                    UserDefaults.standard.set(self.messages, forKey: "messages")
                                                    UserDefaults.standard.set(self.highResImagesURLs, forKey: "highResImageURLs")
                                                    UserDefaults.standard.set(pictureURLs, forKey: "pictureURLs")
                                                    UserDefaults.standard.set(self.likes, forKey: "likes")
                                                    UserDefaults.standard.set(self.dates, forKey: "dates")
                                                    UserDefaults.standard.set(self.attachments, forKey: "attachments")
                                                    UserDefaults.standard.set(next20, forKey: "next20")
                                                    self.tableView.reloadData()
                                                    refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
                                                    refresher.addTarget(self, action: #selector(feedTableView.refresh), for: UIControlEvents.valueChanged)
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
        else
        {
            
            messages = UserDefaults.standard.object(forKey: "messages") as! [String]
            highResImagesURLs = UserDefaults.standard.object(forKey: "highResImageURLs") as! [String:String]
            likes = UserDefaults.standard.object(forKey: "likes") as! [NSInteger]
            dates = UserDefaults.standard.object(forKey: "dates") as! [String]
            pictureURLs = UserDefaults.standard.object(forKey: "pictureURLs") as! [String:String]
            objectIds = UserDefaults.standard.object(forKey: "objectIds") as! [String]
            attachments = UserDefaults.standard.object(forKey: "attachments") as! [String:[String:AnyObject]]
            if UserDefaults.standard.object(forKey: "numberOfLoads") != nil
            {
                numberOfLoads = UserDefaults.standard.object(forKey: "numberOfLoads") as! Int
            }
            if UserDefaults.standard.object(forKey: "next20") != nil
            {
                next20 = UserDefaults.standard.object(forKey: "next20") as! String
            }
            self.tableView.reloadData()
        
        }
        
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
        return messages.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if pictureURLs[objectIds[(indexPath as NSIndexPath).row]] == nil
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "testNoImageFeedCell", for: indexPath) as! noImageTestFeedCell
            
            cell.layoutIfNeeded()
            
            cell.paddingView.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
            cell.paddingView.layer.shadowOpacity = 0.4
            cell.paddingView.layer.masksToBounds = false
            let path = UIBezierPath(rect: cell.paddingView.bounds)
            cell.paddingView.layer.shadowPath = path.cgPath
            
            cell.message.text = messages[(indexPath as NSIndexPath).row]
            cell.likes.text = String(likes[(indexPath as NSIndexPath).row])
            cell.date.text = String(dates[(indexPath as NSIndexPath).row])
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath) as! testFeedCell
        
        cell.layoutIfNeeded()
        
        cell.message.text = messages[(indexPath as NSIndexPath).row]
        cell.likes.text = String(likes[(indexPath as NSIndexPath).row])
        cell.date.text = String(dates[(indexPath as NSIndexPath).row])
        
        cell.paddingView.layer.shadowOffset = CGSize(width: -0.5, height: 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        cell.paddingView.layer.masksToBounds = false
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.cgPath
    
        
        if cell.message.text == ""
        {
            cell.message.text = "No description available"
        }
    
        if pictureURLs[objectIds[(indexPath as NSIndexPath).row]] != nil
        {

            cell.societyImage.setIndicatorStyle(UIActivityIndicatorViewStyle.white)
            cell.societyImage.setShowActivityIndicator(true)
            cell.societyImage.sd_setImage(with: URL(string: pictureURLs[objectIds[(indexPath as NSIndexPath).row]]!),completed: { (image, error, cache, url) in
                
                cell.societyImage.layer.shadowRadius = 2
                cell.societyImage.layer.borderColor = UIColor.clear.cgColor
                cell.societyImage.layer.shadowColor = UIColor.black.cgColor
                cell.societyImage.layer.shadowOffset = CGSize(width: 0, height: 5)
                cell.societyImage.layer.shadowOpacity = 0.4
                cell.societyImage.layer.masksToBounds = false
            })
        }
        
        return cell
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        passMessage = messages[(indexPath as NSIndexPath).row]
        passLikes = likes[(indexPath as NSIndexPath).row]
        passObjectId = objectIds[(indexPath as NSIndexPath).row]
        passImageURL = pictureURLs[passObjectId]
        passPictureId = pictureIds[passObjectId]
        passImage = images[objectIds[(indexPath as NSIndexPath).row]]
        passHighResImageURL = highResImagesURLs[passObjectId]
        passAttachments = attachments[objectIds[(indexPath as NSIndexPath).row]]
        self.photos.removeAll()
        
        if passMessage == nil || passMessage == ""
        {
            
            //self.performSegue(withIdentifier: "homeToImageSegue", sender: self)
            
            if Reachability.isConnectedToNetwork() == true
            {
                
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
            
            return;
        
        }
        if passImageURL == nil
        {
            
            self.performSegue(withIdentifier: "homeToNoImageFeedPage", sender: self)
            return
            
        }
        self.performSegue(withIdentifier: "fbFeedToInstantArticleSegue", sender: self)
        
    }
    

   
    
   override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refresher.isRefreshing
        {
            if !isAnimating
            {

                animateRefreshStep1()
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
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
            navigationBarActivityIndicator = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            navigationBarActivityIndicator.hidesWhenStopped = true
            let barItem = UIBarButtonItem.init(customView: navigationBarActivityIndicator)
            self.navigationItem.setRightBarButton(barItem, animated: true)
            navigationBarActivityIndicator.color = UIColor(red: 1/256, green: 178/255, blue: 155/255, alpha: 1)
            navigationBarActivityIndicator.startAnimating()
            
            let loadMorePostsURL = URL(string: next20)
            let task = URLSession.shared.dataTask(with: loadMorePostsURL!, completionHandler: { (data, response, error) -> Void in
                
                print(next20)
                
                if error != nil
                {
                    
                    DispatchQueue.main.async(execute: { 
                        
                        print(error!)
                        
                        self.view.makeToast("An error occurred. Please try again later", duration: 1, position: CSToastPositionBottom)
                        
                        //stopping activity indicators and resetting next page URl and number of scrolls
                        navigationBarActivityIndicator.stopAnimating()
                        self.navigationItem.rightBarButtonItem = nil
                        didScrollOnce = false
                        numberOfLoads += 0
                        
                        //saving all arrays, dictionaries and variables in the current state to user defaults
                        UserDefaults.standard.set(self.objectIds, forKey: "objectIds")
                        UserDefaults.standard.set(self.messages, forKey: "messages")
                        UserDefaults.standard.set(self.highResImagesURLs, forKey: "highResImageURLs")
                        UserDefaults.standard.set(pictureURLs, forKey: "pictureURLs")
                        UserDefaults.standard.set(self.likes, forKey: "likes")
                        UserDefaults.standard.set(self.dates, forKey: "dates")
                        UserDefaults.standard.set(self.attachments, forKey: "attachments")
                        UserDefaults.standard.set(numberOfLoads, forKey: "numberOfLoads")
                        UserDefaults.standard.set(next20, forKey: "next20")
                        
                    })
                    
                }
                    
                else if error == nil
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        if let data = data
                        {
                            do
                            {
                                
                                let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
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
                                                
                                                self.messages.append("")
                                                
                                            }
                                            
                                            if item["created_time"] != nil
                                            {
                                                
                                                let fbDate = item["created_time"] as! String
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
                                                let newDate = dateFormatter.date(from: fbDate)!
                                                dateFormatter.dateFormat = "dd-MM-yyyy,HH:mm"
                                                let dateString = dateFormatter.string(from: newDate)
                                                self.dates.append(dateString)
                                            }
                                            
                                            self.objectIds.append(item["id"] as! String)
                                            pictureURLs[item["id"] as! String] = item["picture"] as? String
                                            
                                            let pictureId = item["object_id"] as? String
                                            if pictureId != nil
                                            {
                                                
                                                self.pictureIds[item["id"] as! String] = pictureId
                                                
                                            }
                                            
                                            let like = item["likes"] as? [String:AnyObject]
                                            let summary = like!["summary"] as? [String:AnyObject]
                                            let count = summary!["total_count"] as? NSInteger
                                            self.likes.append(count!)
                                            
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
                                                UserDefaults.standard.set(self.objectIds, forKey: "objectIds")
                                                UserDefaults.standard.set(self.messages, forKey: "messages")
                                                UserDefaults.standard.set(self.highResImagesURLs, forKey: "highResImageURLs")
                                                UserDefaults.standard.set(pictureURLs, forKey: "pictureURLs")
                                                UserDefaults.standard.set(self.likes, forKey: "likes")
                                                UserDefaults.standard.set(self.dates, forKey: "dates")
                                                UserDefaults.standard.set(numberOfLoads, forKey: "numberOfLoads")
                                                UserDefaults.standard.set(self.attachments, forKey: "attachments")
                                                UserDefaults.standard.set(next20, forKey: "next20")
                                                
                                            }
                                            
                                            
                                        }
                                    }
                                }
                                
                            }
                                
                            catch
                            {
                                print("JSON Serialisation Failed")
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
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            self.present(alert, animated: true, completion: {
                
                refresher.endRefreshing()
                UserDefaults.standard.set(numberOfLoads, forKey: "numberOfLoads")
                
            })
        }
        else
        {
            let url = URL(string: "https://graph.facebook.com/109315262061/posts?limit=20&fields=id,full_picture,picture,from,shares,attachments,message,object_id,link,created_time,comments.limit(0).summary(true),likes.limit(0).summary(true)&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD")
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                
                if error != nil
                {
                    
                    DispatchQueue.main.async(execute: { 
                        
                        refresher.endRefreshing()
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            self.dismiss(animated: true, completion: nil)
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                    
                }
                    
                else
                {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
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
                                
                                let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
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
                                            
                                                self.messages.append("")
                                                
                                            }
                                            
                                            self.objectIds.append(item["id"] as! String)
                                            pictureURLs[item["id"] as! String] = item["picture"] as? String
                                            
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
                                                self.dates.append(dateString)
                                            }
                                            
                                            let pictureId = item["object_id"] as? String
                                            if pictureId != nil
                                            {
                                                self.pictureIds[item["id"] as! String] = pictureId
                                                
                                            }
                                            
                                            let like = item["likes"] as? [String:AnyObject]
                                            let summary = like!["summary"] as? [String:AnyObject]
                                            let count = summary!["total_count"] as? NSInteger
                                            self.likes.append(count!)
                                            
                                            let id = item["id"] as? String
                                            let pictureURL = item["picture"] as? String
                                            if pictureURL == nil
                                            {
                                                images[id!] = nil
                                            }
                                            
                                            if self.objectIds.count == 20
                                            {
                                            
                                                numberOfLoads = 1
                                                UserDefaults.standard.set(self.objectIds, forKey: "objectIds")
                                                UserDefaults.standard.set(self.messages, forKey: "messages")
                                                UserDefaults.standard.set(self.highResImagesURLs, forKey: "highResImageURLs")
                                                UserDefaults.standard.set(pictureURLs, forKey: "pictureURLs")
                                                UserDefaults.standard.set(self.likes, forKey: "likes")
                                                UserDefaults.standard.set(self.dates, forKey: "dates")
                                                UserDefaults.standard.set(numberOfLoads, forKey: "numberOfLoads")
                                                UserDefaults.standard.set(self.attachments, forKey: "attachments")
                                                UserDefaults.standard.set(next20, forKey: "next20")
                                                refresher.endRefreshing()
                                                self.tableView.reloadData()
                                            
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                                
                            }
                                
                            catch
                            {
                                print("JSON Serialisation Failed")
                            }
                            
                            
                        }
                    })
                    
                    
                    
                }
                
                
            }) 
            
            task.resume()
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        
    }
    
    //MARK : MWPhotoBrowser delegate methods
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt
    {
        
        return UInt(self.photos.count)
        
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol!
    {
        
        return photos[Int(index)]
        
    }
    
    //MARK : Animation for the refresh control
    
    func loadCustomViewContents()
    {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents![0] as! UIView
        customView.frame = refresher.bounds
        
        for i in 0 ..< customView.subviews.count
        {
            labelsArray.append(customView.viewWithTag(i+1) as! UILabel)
        }
        
        refresher.backgroundColor = UIColor.clear
        refresher.tintColor = UIColor.clear
        refresher.addSubview(customView)
        
    }
    
    func animateRefreshStep1()
    {
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
    
    
    func animateRefreshStep2()
    {
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
                        if refresher.isRefreshing {
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
    
    
    
    func getNextColor() -> UIColor
    {
        var colorsArray: Array<UIColor> = [UIColor.magenta, UIColor.brown, UIColor.yellow, UIColor.red, UIColor.green, UIColor.blue, UIColor.orange]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }
    
}
