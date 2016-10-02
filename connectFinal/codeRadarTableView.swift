//
//  codeRadarTableView.swift
//  
//
//  Created by Swapnil Dhanwal on 28/05/16.
//
//

import UIKit
import SWRevealViewController
import NYAlertViewController

var passItem : AnyObject!

class codeRadarTableView: UITableViewController{

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentTapped(sender: AnyObject) {
        
        if self.segmentedControl.selectedSegmentIndex == 1
        {
            self.tableView.reloadData()
        }
        if self.segmentedControl.selectedSegmentIndex == 0
        {
            self.tableView.reloadData()
        }
    }
    
    var items = [AnyObject]()
    var itemsToDisplay = [AnyObject]()
    
    
    var codeSpinner = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = UIColor.clearColor()
        
        //configuring the custom refresher
        refresher.addTarget(self, action: #selector(codeRadarTableView.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(refresher)
        isAnimating = false
        currentColorIndex = 0
        currentLabelIndex = 0
        customView = UIView()
        labelsArray.removeAll()
        self.loadCustomViewContents()
        
        //setting up the tint of the navigation bar
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        
        //configuring the activity indicator
        codeSpinner.frame = CGRectMake(0, 0, 100, 100)
        codeSpinner.center = CGPointMake(self.view.center.x, self.view.center.y-100)
        codeSpinner.hidesWhenStopped = true
        codeSpinner.activityIndicatorViewStyle = .Gray
        codeSpinner.layer.cornerRadius = 10
        codeSpinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        self.view.addSubview(codeSpinner)
        codeSpinner.startAnimating()
        
        //configuring the segmented control
        segmentedControl.enabled = false
        segmentedControl.userInteractionEnabled = false
        
        //configuring the swipe menu
        if self.revealViewController() != nil
        {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if Reachability.isConnectedToNetwork() == false
        {
//            let alert = UIAlertController(title: "Internet connection unavailable", message: "Please refresh when the connection is established", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
            
            let alert = NYAlertViewController()
            alert.title = "Internet Connection Unavailable"
            alert.message = "Please refresh when the connection is reestablished"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: { 
                    
                    self.codeSpinner.stopAnimating()
                    
                })
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        self.items.removeAll()
        self.itemsToDisplay.removeAll()
        let url = "https://www.hackerrank.com/calendar/feed.json";
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
            
            dispatch_async(dispatch_get_main_queue(), { 
                
                if error != nil
                {
//                    print(error)
//                    let alert = UIAlertController(title: "An error occured", message: "Please try again later", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    let alert = NYAlertViewController()
                    alert.title = "An Error Occurred"
                    alert.message = "Please try again later"
                    alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                    alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                if error == nil
                {
                    if let data = data
                    {
                        do
                        {
                            
                            self.items.removeAll()
                            self.itemsToDisplay.removeAll()
                            
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
                            if let models = jsonData["models"] as? [[String:AnyObject]]
                            {
                                for item in models
                                {
                                    
                                    self.items.append(item as AnyObject)
                                    
                                }
        
                            }
                            
                            self.codeSpinner.stopAnimating()
                            self.segmentedControl.enabled = true
                            self.segmentedControl.userInteractionEnabled = true
                            
                            for item in self.items
                            {
                                var startDate = NSDate()
                                var currentDate = NSDate()
                                var endDate = NSDate()
                                if let start = item["start"] as? String
                                {
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    startDate = dateFormatter.dateFromString(start)!
                                    
                                }
                                if let end = item["end"] as? String
                                {
                                    let dateFormatter = NSDateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    endDate = dateFormatter.dateFromString(end)!
                                }
                                currentDate = NSDate()
                                if currentDate.compare(startDate).rawValue == 1 && currentDate.compare(endDate).rawValue == -1
                                {
                                    self.itemsToDisplay.append(item)
                                }
                                
                            }
                            self.tableView.reloadData()
                        }
                        catch
                        {
                            
                        }
                    }
                }

                
            })
            
            
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
        
        if self.segmentedControl.selectedSegmentIndex == 0
        {
            return items.count
        }
        
        return self.itemsToDisplay.count
    }
    
    func refresh()
    {
        if Reachability.isConnectedToNetwork() == false
        {
//            let alert = UIAlertController(title: "Unable to refresh", message: "Please try again when the connection is re-established", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
//                refresher.endRefreshing()
//            }))
//            presentViewController(alert, animated: true, completion: nil)
            
            let alert = NYAlertViewController()
            alert.title = "Unable to refresh"
            alert.message = "Please try again when the internet connection is re-established"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: { 
                    
                    refresher.endRefreshing()
                    
                })
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            
            
            let url = "https://www.hackerrank.com/calendar/feed.json";
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    if error != nil
                    {
                        print(error)
//                        let alert = UIAlertController(title: "An error occured", message: "Please try again later", preferredStyle: UIAlertControllerStyle.Alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                        self.presentViewController(alert, animated: true, completion: nil)
//                        refresher.endRefreshing()
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(true, completion: { 
                                
                                refresher.endRefreshing()
                                
                            })
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    }
                    if error == nil
                    {
                        if let data = data
                        {
                            do
                            {
                                self.items.removeAll()
                                self.itemsToDisplay.removeAll()
                                
                                let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
                                if let models = jsonData["models"] as? [[String:AnyObject]]
                                {
                                    for item in models
                                    {
                                        
                                        self.items.append(item as AnyObject)
                                        
                                    }
                                    
                                }
                                
                                self.codeSpinner.stopAnimating()
                                self.segmentedControl.enabled = true
                                self.segmentedControl.userInteractionEnabled = true
                                
                                for item in self.items
                                {
                                    var startDate = NSDate()
                                    var currentDate = NSDate()
                                    var endDate = NSDate()
                                    if let start = item["start"] as? String
                                    {
                                        let dateFormatter = NSDateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        startDate = dateFormatter.dateFromString(start)!
                                        
                                    }
                                    if let end = item["end"] as? String
                                    {
                                        let dateFormatter = NSDateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        endDate = dateFormatter.dateFromString(end)!
                                    }
                                    currentDate = NSDate()
                                    if currentDate.compare(startDate).rawValue == 1 && currentDate.compare(endDate).rawValue == -1
                                    {
                                        self.itemsToDisplay.append(item)
                                    }
                                    
                                }
                                refresher.endRefreshing()
                                self.tableView.reloadData()
                            }
                            catch
                            {
                                
                            }
                        }
                    }
                    
                    
                })
                
                
            }
            task.resume()

        }
    }
    
    override func viewWillLayoutSubviews() {
        
        self.codeSpinner.center = CGPointMake(self.view.center.x, self.view.center.y-100)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("codeCell", forIndexPath: indexPath) as! compCell
        
        cell.layoutIfNeeded()
        
        if self.segmentedControl.selectedSegmentIndex == 0
        {
            cell.titleLabel.text = items[indexPath.row]["title"] as? String
            
            //setting up the date formatter
            let startTime = items[indexPath.row]["start"] as? String
            let endTime = items[indexPath.row]["end"] as? String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            var temp = dateFormatter.dateFromString(startTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newStartTime = dateFormatter.stringFromDate(temp!)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            temp = dateFormatter.dateFromString(endTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newEndTime = dateFormatter.stringFromDate(temp!)
            
            cell.start.text = newStartTime
            cell.end.text = newEndTime
        }
        else if self.segmentedControl.selectedSegmentIndex == 1
        {
            cell.titleLabel.text = itemsToDisplay[indexPath.row]["title"] as? String
            let startTime = itemsToDisplay[indexPath.row]["start"] as? String
            let endTime = itemsToDisplay[indexPath.row]["end"] as? String
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            var temp = dateFormatter.dateFromString(startTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newStartTime = dateFormatter.stringFromDate(temp!)
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            temp = dateFormatter.dateFromString(endTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newEndTime = dateFormatter.stringFromDate(temp!)
            cell.start.text = newStartTime
            cell.end.text = newEndTime
        }
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.CGPath
        cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        return cell
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if segmentedControl.selectedSegmentIndex == 0
        {
            passItem = items[indexPath.row]
        }
        else
        {
            passItem = itemsToDisplay[indexPath.row]
        }
        self.performSegueWithIdentifier("competitionSegue", sender: self)
        
    }
    
    func loadCustomViewContents()
    {
        let refreshContents = NSBundle.mainBundle().loadNibNamed("RefreshContents", owner: self, options: nil)
        customView = refreshContents![0] as! UIView
        customView.frame = refresher.bounds
        
        for i in 0 ..< customView.subviews.count
        {
            labelsArray.append(customView.viewWithTag(i+1) as! UILabel)
        }
        
        refresher.backgroundColor = UIColor.clearColor()
        refresher.tintColor = UIColor.clearColor()
        refresher.addSubview(customView)
        
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
    
    
    
    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magentaColor(), UIColor.brownColor(), UIColor.yellowColor(), UIColor.redColor(), UIColor.greenColor(), UIColor.blueColor(), UIColor.orangeColor()]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }
    

    

    

}
