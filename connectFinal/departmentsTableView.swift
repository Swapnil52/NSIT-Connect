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
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.portrait
        
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headers.removeAll()
        
        self.tableView.separatorColor = UIColor.clear
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        self.navigationController?.navigationBar.tintColor = UIColor(red: 01/256, green: 178/256, blue: 155/256, alpha: 1)
        
        
        let filePath : NSString = Bundle.main.path(forResource: "professorsList", ofType: "json")! as NSString
        do
        {
            let dataString = try NSString(contentsOfFile: filePath as String, encoding: String.Encoding.utf8.rawValue)
            let data = dataString.data(using: String.Encoding.utf8.rawValue)!
            let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSArray
            
            if jsonData != nil
            {
                //print(jsonData)
                for item in jsonData!
                {
                    headers.append(item as AnyObject)
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return headers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departmentCell1", for: indexPath) as! departmentCell
        
        cell.layoutIfNeeded()
        
        cell.boldDpt.text = headers[(indexPath as NSIndexPath).row]["Header"] as? String
        //cell.department.text = headers[indexPath.row]["Header"] as? String
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.cgPath
        cell.paddingView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        passDepartment = (headers[(indexPath as NSIndexPath).row]["Header"] as? String)!
        self.performSegue(withIdentifier: "showProfessors", sender: self)
        passObject = (headers[(indexPath as NSIndexPath).row]["ContentArray"] as? [[String:AnyObject]])!
    
    }
    
    

    

}
