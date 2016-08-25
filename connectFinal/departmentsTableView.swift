//
//  departmentsTableView.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 09/04/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import SWRevealViewController

//variables to populate the tableView
var headers = [AnyObject]()
var dpts = ["DM", "DC", "DP", "DoM", "H&M", "ECE", "COE", "ICE", "MPAE", "IT", "BT", "SAS"]

//variables to pass to the next table containing the
var passDepartment = String()
var passObject = [[String:AnyObject]]()

class departmentsTableView: UITableViewController {
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.Portrait
        
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headers.removeAll()
        
        self.tableView.separatorColor = UIColor.clearColor()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        
        
        let filePath : NSString = NSBundle.mainBundle().pathForResource("professorsList", ofType: "json")!
        do
        {
            let dataString = try NSString(contentsOfFile: filePath as String, encoding: NSUTF8StringEncoding)
            let data = dataString.dataUsingEncoding(NSUTF8StringEncoding)!
            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? NSArray
            
            if jsonData != nil
            {
                //print(jsonData)
                for item in jsonData!
                {
                    headers.append(item)
                }
                
                tableView.reloadData()
            }
            
        }
        catch let error as NSError
        {
            print("error: \(error.localizedDescription)")
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
        return headers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("departmentCell1", forIndexPath: indexPath) as! departmentCell
        
        cell.layoutIfNeeded()
        
        cell.boldDpt.text = headers[indexPath.row]["Header"] as? String
        //cell.department.text = headers[indexPath.row]["Header"] as? String
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.CGPath
        cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        passDepartment = (headers[indexPath.row]["Header"] as? String)!
        self.performSegueWithIdentifier("showProfessors", sender: self)
        passObject = (headers[indexPath.row]["ContentArray"] as? [[String:AnyObject]])!
    
    }
    
    

    

}
