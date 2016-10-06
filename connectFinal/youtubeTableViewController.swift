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
    
    @IBAction func previous(_ sender: AnyObject) {
        
        if pageIndex == 1
        {
            previousOutlet.isEnabled = false
        }
        else
        {
            pageIndex-=1
            print(pageIndex)
            if pageIndex == 1
            {
                previousOutlet.isEnabled = false
            }
            previousURL = currentURL
            ytPublishedTimes.removeAll()
            ytVideoDescriptions.removeAll()
            ytVideoIds.removeAll()
            ytVideoTitles.removeAll()
            ytThumbnailURLs.removeAll()
            ytThumbnails.removeAll()
            self.tableView.reloadData()
            previousOutlet.isEnabled = false
            nextOutlet.isEnabled = false
            
            spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = .gray
            spinner.layer.cornerRadius = 10
            spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
            self.view.addSubview(spinner)
            spinner.startAnimating()
            //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let url = URL(string: nextURL + "&pageToken=\(prevPageToken!)")
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                
                if error != nil
                {
                    
                    DispatchQueue.main.async(execute: { 
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            self.dismiss(animated: true, completion: {
                                
                                self.spinner.stopAnimating()
                                self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
                            })
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                    
                }

                
                if error == nil
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        do
                        {
                            let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
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
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                            let newDate = dateFormatter.date(from: time)!
                                            dateFormatter.amSymbol = "AM"
                                            dateFormatter.pmSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                            let dateString = dateFormatter.string(from: newDate)
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
                                                        self.previousOutlet.isEnabled = true
                                                        self.nextOutlet.isEnabled = true
                                                        if prevPageToken == nil
                                                        {
                                                            self.previousOutlet.isEnabled = false
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
                
            }) 
            task.resume()

        }
        
    }
    @IBAction func next(_ sender: AnyObject) {
        
        pageIndex += 1
        
        previousOutlet.isEnabled = true
        
        print(pageIndex)
        
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .gray
        spinner.layer.cornerRadius = 10
        spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        self.view.addSubview(spinner)
        
        if nextPageToken == nil || nextPageToken == ""
        {
            nextOutlet.isEnabled = false
        }
        
        if nextPageToken != nil && pageIndex != totalNumberOfPages
        {
            nextURL = currentURL
            print(nextURL)
            print(nextURL + "&pageToken=\(nextPageToken!)")
            let url = URL(string: nextURL + "&pageToken=\(nextPageToken!)")
            ytPublishedTimes.removeAll()
            ytVideoDescriptions.removeAll()
            ytVideoIds.removeAll()
            ytVideoTitles.removeAll()
            ytThumbnailURLs.removeAll()
            ytThumbnails.removeAll()
            tableView.reloadData()
            previousOutlet.isEnabled = false
            nextOutlet.isEnabled = false
            spinner.startAnimating()
            //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                
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
                    
                    DispatchQueue.main.async(execute: { 
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            self.dismiss(animated: true, completion: {
                                
                                self.spinner.stopAnimating()
                                self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
                                
                            })
                            
                        }))
                        self.present(alert, animated: true, completion: nil)

                        
                    })
                    
            
                }
                
                if error == nil
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        do
                        {
                            print(nextURL + "&pageToken=\(nextPageToken)")
                            let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
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
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                            let newDate = dateFormatter.date(from: time)!
                                            dateFormatter.amSymbol = "AM"
                                            dateFormatter.pmSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                            let dateString = dateFormatter.string(from: newDate)
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
                                                            self.nextOutlet.isEnabled = true
                                                        }
                                                        else
                                                        {
                                                            self.nextOutlet.isEnabled = false
                                                        }
                                                        self.previousOutlet.isEnabled = true
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
                
            }) 
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
        
        self.tableView.separatorColor = UIColor.clear
        
        self.navigationController?.isToolbarHidden = false
        
        if pageIndex == 1
        {
            previousOutlet.isEnabled = false
        }
        
        //setting up spinner
        spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .gray
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
        ytRefresher.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
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
        let url = URL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=UUu445B5LTXzkNr5eft8wNHg&key=AIzaSyBgktirlOODUO9zWD-808D7zycmP7smp-Y")
        currentURL = urlString
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            if error != nil
            {
                
                DispatchQueue.main.async(execute: { 
                    
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
                    alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                       
                        self.spinner.stopAnimating()
                        self.view.makeToast("Pull to refresh to reload", duration: 1, position: CSToastPositionTop)
                        self.nextOutlet.isEnabled = false
                        
                        
                    }))
                    
                    
                })
                
            }
            
            if error == nil
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    do
                    {
                        let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
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
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                        let newDate = dateFormatter.date(from: time)!
                                        dateFormatter.amSymbol = "AM"
                                        dateFormatter.pmSymbol = "PM"
                                        dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                        let dateString = dateFormatter.string(from: newDate)
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
                                                        self.previousOutlet.isEnabled = false
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
            
        }) 
        task.resume()
        
        
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
        return ytVideoTitles.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testYoutubeCell", for: indexPath) as! youtubeCell
        
        cell.layoutIfNeeded()
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.cgPath
        cell.paddingView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        let titleString = ytVideoTitles[(indexPath as NSIndexPath).row].replacingOccurrences(of: "\"", with: "")
        
        cell.title.text = titleString
        cell.title.numberOfLines = 0
        cell.thumbnail.image = ytThumbnails[ytVideoIds[(indexPath as NSIndexPath).row]]
        cell.desc.text = "No description available"
        if ytVideoDescriptions[(indexPath as NSIndexPath).row] != ""
        {
            cell.desc.text = ytVideoDescriptions[(indexPath as NSIndexPath).row]
        }
        cell.date.text = ytPublishedTimes[(indexPath as NSIndexPath).row]
        cell.thumbnail.setIndicatorStyle(UIActivityIndicatorViewStyle.white)
        cell.thumbnail.setShowActivityIndicator(true)
        cell.thumbnail.sd_setImage(with: URL(string: ytThumbnailURLs[(indexPath as NSIndexPath).row]))
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        passVideoId = ytVideoIds[(indexPath as NSIndexPath).row]
        performSegue(withIdentifier: "playVideoSegue", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: { 
                    
                    self.spinner.stopAnimating()
                    
                })
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.dismiss(animated: true, completion: nil)
        
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
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: {
                    
                    self.spinner.stopAnimating()
                    self.ytRefresher.endRefreshing()
                    
                })
                
            }))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        if Reachability.isConnectedToNetwork() == true
        {
        
            if spinner.isAnimating
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
            let url = URL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=UUu445B5LTXzkNr5eft8wNHg&key=AIzaSyBgktirlOODUO9zWD-808D7zycmP7smp-Y")
            currentURL = urlString
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                
                if error != nil
                {
                    
                    DispatchQueue.main.async(execute: { 
                        
//                        let alert = UIAlertController(title: "An Error Occurred", message: "Please try again later", preferredStyle: .Alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//                        self.presentViewController(alert, animated: true, completion: nil)
//                        self.spinner.stopAnimating()
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            self.dismiss(animated: true, completion: { 
                                
                                self.spinner.stopAnimating()
                                
                            })
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                    
                }
                
                if error == nil
                {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        do
                        {
                            self.spinner.stopAnimating()
                            let jsonData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
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
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                                            let newDate = dateFormatter.date(from: time)!
                                            dateFormatter.amSymbol = "AM"
                                            dateFormatter.pmSymbol = "PM"
                                            dateFormatter.dateFormat = "dd MMM, hh:mm a"
                                            let dateString = dateFormatter.string(from: newDate)
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
                                                        self.previousOutlet.isEnabled = false
                                                        pageIndex = 1
                                                        self.nextOutlet.isEnabled = true
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
                
            }) 
            task.resume()
        }

    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if ytRefresher.isRefreshing
        {
            if !isAnimating
            {
                
                animateRefreshStep1()
            }
        }
    }
    
    func loadCustomViewContents()
    {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents![0] as! UIView
        customView.frame = ytRefresher.bounds
        
        for i in 0 ..< customView.subviews.count
        {
            labelsArray.append(customView.viewWithTag(i+1) as! UILabel)
        }
        
        ytRefresher.backgroundColor = UIColor.clear
        ytRefresher.tintColor = UIColor.clear
        ytRefresher.addSubview(customView)
        
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
                        if self.ytRefresher.isRefreshing {
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
    
    override func viewWillLayoutSubviews() {
        
        spinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        
    }

    
    
}
