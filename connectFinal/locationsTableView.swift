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
    
    @IBAction func rangeButton(_ sender: AnyObject) {
        
        let alert = NYAlertViewController()
        alert.title = "Select Range (Km)"
        alert.message = ""
        alert.alertViewContentView = picker
        alert.buttonColor = UIColor(red: 01/255, green: (179)/255, blue: (164)/255, alpha: 1)
        alert.alertViewBackgroundColor = UIColor(red: 231/255, green: 234/255, blue: 236/255, alpha: 1)
        alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
            
            self.range = Int(self.pickerData[self.picker.selectedRow(inComponent: 0)])
            print(Int(self.pickerData[self.picker.selectedRow(inComponent: 0)]))
            self.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 1/255, green: 179/255, blue: 155/255, alpha: 1)
        self.tableView.separatorColor = UIColor.clear
        
        
        picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return types.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell", for: indexPath) as! locationTypeCell
        
        cell.layoutIfNeeded()
        
        let path = UIBezierPath(rect: cell.paddingView.bounds)
        cell.paddingView.layer.shadowPath = path.cgPath
        //cell.paddingView.layer.shadowRadius = 2
        cell.paddingView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        
        cell.typeName.text = typeStrings[(indexPath as NSIndexPath).row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if Reachability.isConnectedToNetwork() == true
        {
            passType = types[(indexPath as NSIndexPath).row]
            passRange = String(self.pickerData[self.picker.selectedRow(inComponent: 0)]*1000)
            self.performSegue(withIdentifier: "resultsSegue", sender: self)
        }
        else
        {
            let alert = NYAlertViewController()
            alert.title = "Unable to Load Results"
            alert.message = "Please connect to the internet and try again"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .default, handler: { (action) in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(pickerData[row])
    }


}
