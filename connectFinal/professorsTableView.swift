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
        
        self.tableView.separatorColor = UIColor.clear
        
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.portrait
        
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
        return passObject.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "professorCell", for: indexPath) as! professorCell
        
        cell.layoutIfNeeded()
        
        cell.name.text = passObject[(indexPath as NSIndexPath).row]["Name"] as? String
        let path = UIBezierPath(rect: cell.cellPaddingView.bounds)
        cell.cellPaddingView.layer.shadowPath = path.cgPath
        cell.cellPaddingView.layer.shadowColor = UIColor.black.cgColor
        cell.cellPaddingView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.cellPaddingView.layer.shadowOpacity = 0.4
        
        if let designation = passObject[(indexPath as NSIndexPath).row]["Designation"] as? String
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
        
        if let email = passObject[(indexPath as NSIndexPath).row]["Email"] as? String
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
        
        if var phone = passObject[(indexPath as NSIndexPath).row]["ContactNo"] as? String
        {
            phone = phone.replacingOccurrences(of: "(DID)", with: "")
            phone = phone.replacingOccurrences(of: "(Int)", with: "")
            phone = phone.replacingOccurrences(of: " ", with: "")
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
