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
    
    @IBAction func segmentTapped(_ sender: AnyObject) {
        
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
        
        self.tableView.separatorColor = UIColor.clear
        
        //configuring the custom refresher
        refresher.addTarget(self, action: #selector(codeRadarTableView.refresh), for: UIControlEvents.valueChanged)
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
        codeSpinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        codeSpinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        codeSpinner.hidesWhenStopped = true
        codeSpinner.activityIndicatorViewStyle = .gray
        codeSpinner.layer.cornerRadius = 10
        codeSpinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        self.view.addSubview(codeSpinner)
        codeSpinner.startAnimating()
        
        //configuring the segmented control
        segmentedControl.isEnabled = false
        segmentedControl.isUserInteractionEnabled = false
        
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
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: { 
                    
                    self.codeSpinner.stopAnimating()
                    
                })
                
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        self.items.removeAll()
        self.itemsToDisplay.removeAll()
        let url = "https://www.hackerrank.com/calendar/feed.json";
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
            
            DispatchQueue.main.async(execute: { 
                
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
                    alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                if error == nil
                {
                    if let data = data
                    {
                        do
                        {
                            
                            self.items.removeAll()
                            self.itemsToDisplay.removeAll()
                            
                            let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                            if let models = jsonData["models"] as? [[String:AnyObject]]
                            {
                                for item in models
                                {
                                    
                                    self.items.append(item as AnyObject)
                                    
                                }
        
                            }
                            
                            self.codeSpinner.stopAnimating()
                            self.segmentedControl.isEnabled = true
                            self.segmentedControl.isUserInteractionEnabled = true
                            
                            for item in self.items
                            {
                                var startDate = Date()
                                var currentDate = Date()
                                var endDate = Date()
                                if let start = item["start"] as? String
                                {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    startDate = dateFormatter.date(from: start)!
                                    
                                }
                                if let end = item["end"] as? String
                                {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                    endDate = dateFormatter.date(from: end)!
                                }
                                currentDate = Date()
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
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: { 
                    
                    refresher.endRefreshing()
                    
                })
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            
            
            let url = "https://www.hackerrank.com/calendar/feed.json";
            
            let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) in
                
                DispatchQueue.main.async(execute: {
                    
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
                        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                            self.dismiss(animated: true, completion: { 
                                
                                refresher.endRefreshing()
                                
                            })
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    if error == nil
                    {
                        if let data = data
                        {
                            do
                            {
                                self.items.removeAll()
                                self.itemsToDisplay.removeAll()
                                
                                let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSDictionary
                                if let models = jsonData["models"] as? [[String:AnyObject]]
                                {
                                    for item in models
                                    {
                                        
                                        self.items.append(item as AnyObject)
                                        
                                    }
                                    
                                }
                                
                                self.codeSpinner.stopAnimating()
                                self.segmentedControl.isEnabled = true
                                self.segmentedControl.isUserInteractionEnabled = true
                                
                                for item in self.items
                                {
                                    var startDate = Date()
                                    var currentDate = Date()
                                    var endDate = Date()
                                    if let start = item["start"] as? String
                                    {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        startDate = dateFormatter.date(from: start)!
                                        
                                    }
                                    if let end = item["end"] as? String
                                    {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                                        endDate = dateFormatter.date(from: end)!
                                    }
                                    currentDate = Date()
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
                
                
            }) 
            task.resume()

        }
    }
    
    override func viewWillLayoutSubviews() {
        
        self.codeSpinner.center = CGPoint(x: self.view.center.x, y: self.view.center.y-100)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "codeCell", for: indexPath) as! compCell
        
        cell.layoutIfNeeded()
        
        if self.segmentedControl.selectedSegmentIndex == 0
        {
            cell.titleLabel.text = items[(indexPath as NSIndexPath).row]["title"] as? String
            
            //setting up the date formatter
            let startTime = items[(indexPath as NSIndexPath).row]["start"] as? String
            let endTime = items[(indexPath as NSIndexPath).row]["end"] as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            var temp = dateFormatter.date(from: startTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newStartTime = dateFormatter.string(from: temp!)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            temp = dateFormatter.date(from: endTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newEndTime = dateFormatter.string(from: temp!)
            
            cell.start.text = newStartTime
            cell.end.text = newEndTime
        }
        else if self.segmentedControl.selectedSegmentIndex == 1
        {
            cell.titleLabel.text = itemsToDisplay[(indexPath as NSIndexPath).row]["title"] as? String
            let startTime = itemsToDisplay[(indexPath as NSIndexPath).row]["start"] as? String
            let endTime = itemsToDisplay[(indexPath as NSIndexPath).row]["end"] as? String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            var temp = dateFormatter.date(from: startTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newStartTime = dateFormatter.string(from: temp!)
            
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            temp = dateFormatter.date(from: endTime!)
            dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
            let newEndTime = dateFormatter.string(from: temp!)
            cell.start.text = newStartTime
            cell.end.text = newEndTime
        }
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.cgPath
        cell.paddingView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        return cell
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentedControl.selectedSegmentIndex == 0
        {
            passItem = items[(indexPath as NSIndexPath).row]
        }
        else
        {
            passItem = itemsToDisplay[(indexPath as NSIndexPath).row]
        }
        self.performSegue(withIdentifier: "competitionSegue", sender: self)
        
    }
    
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
    
    
    
    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magenta, UIColor.brown, UIColor.yellow, UIColor.red, UIColor.green, UIColor.blue, UIColor.orange]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }
    

    

    

}
