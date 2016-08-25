//
//  locationsTableView.swift
//  locationsModule
//
//  Created by Swapnil Dhanwal on 15/06/16.
//  Copyright © 2016 Swapnil Dhanwal. All rights reserved.
//

import UIKit
import NYAlertViewController
import CoreLocation
import SWRevealViewController

var passType = String()
var passRange = String()

class locationsTableView: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    var picker = UIPickerView()
    var pickerData = [Int]()
    var range = Int()
    var types = ["atm", "cafe", "bar", "restaurant", "shopping_mall", "bowling_alley", "food", "movie_theater", "amusement_park", "park", "night_club"]
    var typeStrings = ["ATM", "Cafes", "Bars", "Restaurants", "Malls", "Bowling", "Food", "Movies", "Amusement", "Parks", "Nightclubs"]
    
    @IBAction func rangeButton(sender: AnyObject) {
        
        let alert = NYAlertViewController()
        alert.title = "Select Range (Km)"
        alert.message = ""
        alert.alertViewContentView = picker
        alert.buttonColor = UIColor(red: 01/255, green: (179)/255, blue: (164)/255, alpha: 1)
        alert.alertViewBackgroundColor = UIColor(red: 231/255, green: 234/255, blue: 236/255, alpha: 1)
        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
            
            self.range = Int(self.pickerData[self.picker.selectedRowInComponent(0)])
            print(Int(self.pickerData[self.picker.selectedRowInComponent(0)]))
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 179/255, blue: 155/255, alpha: 1)
        self.tableView.separatorColor = UIColor.clearColor()
        
        
        picker = UIPickerView(frame: CGRectMake(0, 0, 50, 50))
        
        var i = 1
        while i <= 25
        {
            pickerData.append(i)
            i += 1
        }
        
        range = 1
        
        picker.delegate = self
        picker.dataSource = self
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
        return types.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("typeCell", forIndexPath: indexPath) as! locationTypeCell
        
        cell.layoutIfNeeded()
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.CGPath
        //cell.paddingView.layer.shadowRadius = 2
        cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        cell.typeName.text = typeStrings[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if Reachability.isConnectedToNetwork() == true
        {
            passType = types[indexPath.row]
            passRange = String(self.pickerData[self.picker.selectedRowInComponent(0)]*1000)
            self.performSegueWithIdentifier("resultsSegue", sender: self)
        }
        else
        {
            let alert = NYAlertViewController()
            alert.title = "Unable to Load Results"
            alert.message = "Please connect to the internet and try again"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
    

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(pickerData[row])
    }


}
