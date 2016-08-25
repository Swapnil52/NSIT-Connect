//
//  professorsTableView.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 09/04/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

var professorNames = [String:String]()
var professorEmails = [String:String]()
var professorPhones = [String:String]()
var professorDesignations = [String:String]()

var contents = [String:AnyObject]()


class professorsTableView: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = UIColor.clearColor()
        
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.Portrait
        
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
        return passObject.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("professorCell", forIndexPath: indexPath) as! professorCell
        
        cell.layoutIfNeeded()
        
        cell.name.text = passObject[indexPath.row]["Name"] as? String
        let path = UIBezierPath(rect: cell.cellPaddingView.bounds)
        cell.cellPaddingView.layer.shadowPath = path.CGPath
        cell.cellPaddingView.layer.shadowColor = UIColor.blackColor().CGColor
        cell.cellPaddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cell.cellPaddingView.layer.shadowOpacity = 0.4
        
        if let designation = passObject[indexPath.row]["Designation"] as? String
        {
            cell.designation.text = designation
            if designation == ""
            {
                cell.designation.text = "No designation available"
            }
        }
        else
        {
            cell.designation.text = "No designation available"
        }
        
        if let email = passObject[indexPath.row]["Email"] as? String
        {
            cell.email.text = "Email: \(email)"
            if email == ""
            {
                cell.email.text = "No email-id available"
            }
        }
        else
        {
            cell.email.text = "No email-id available"
        }
        
        if var phone = passObject[indexPath.row]["ContactNo"] as? String
        {
            phone = phone.stringByReplacingOccurrencesOfString("(DID)", withString: "")
            phone = phone.stringByReplacingOccurrencesOfString("(Int)", withString: "")
            phone = phone.stringByReplacingOccurrencesOfString(" ", withString: "")
            if (phone.hasPrefix("2"))
            {
                phone = "011\(phone)"
            }
            cell.phone.text = "Phone: \(phone)"
            if phone == ""
            {
                cell.phone.text = "No phone number available"
            }
        }
        
        return cell
    }


}
