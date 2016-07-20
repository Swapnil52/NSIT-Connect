//
//  resultsTableView.swift
//  locationsModule
//
//  Created by Swapnil Dhanwal on 16/06/16.
//  Copyright © 2016 Swapnil Dhanwal. All rights reserved.
//

import UIKit
import NYAlertViewController
import MapKit
import CoreLocation

//variables to pass to the next view controller
var passLat = CLLocationDegrees()
var passLon = CLLocationDegrees()
var passCurrentLocation = CLLocation()
var passName = String()

class resultsTableView: UITableViewController, CLLocationManagerDelegate {
    
    var names = [String]()
    var spinner = UIActivityIndicatorView()
    var latitudes = [Double]()
    var longitudes = [Double]()
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var gotLocation = Bool()
    //var gotLocation = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        if CLLocationManager.locationServicesEnabled() == true
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            gotLocation = false
        }
        
        if CLLocationManager.locationServicesEnabled() == false
        {
            
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
        return names.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath)

        cell.textLabel?.text = names[indexPath.row]
        
        return cell
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("enable services!")
        let alert = NYAlertViewController()
        alert.title = "Location Services Not Enabled"
        alert.message = "Please allow NSIT Connect to access your location in Settings"
        alert.addAction(NYAlertAction(title: "Settings", style: .Default, handler: { (action) in
            
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            self.dismissViewControllerAnimated(false, completion: nil)
            
        }))
        alert.addAction(NYAlertAction(title: "Cancel", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: {
                
                self.navigationController?.popViewControllerAnimated(true)
                
            })
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if gotLocation == false
        {
            print("updating")
            gotLocation = true
            currentLocation = locations[0]
            //setting up the spinner
            spinner.frame = CGRectMake(0, 0, 50, 50)
            spinner.center = CGPointMake(self.view.center.x, self.view.center.y-100)
            spinner.activityIndicatorViewStyle = .WhiteLarge
            spinner.layer.backgroundColor = UIColor.lightGrayColor().CGColor
            spinner.layer.cornerRadius = 5
            spinner.hidesWhenStopped = true
            self.view.addSubview(spinner)
            spinner.startAnimating()
            
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            
            
            
            let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=\(passRange)&types=\(passType)&sensor=true&key=AIzaSyBgApnLxwHxTvcV9Go2YTcqiWVIY1eUgdA")
            
            print(url)
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
                
                if error != nil
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let alert = NYAlertViewController()
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                            self.navigationController?.popViewControllerAnimated(true)
                            self.locationManager.startUpdatingLocation()
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: { 
                            
                            self.spinner.stopAnimating()
                            
                            
                        })
                    })
                }
                    
                    
                else
                {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        do
                        {
                            self.names.removeAll()
                            self.latitudes.removeAll()
                            self.longitudes.removeAll()
                            
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                            if jsonData["status"] as? String == "ZERO_RESULTS"
                            {
                                let alert = NYAlertViewController()
                                alert.title = "No Results Found"
                                alert.message = "Please try a different range"
                                alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                                    
                                    self.dismissViewControllerAnimated(true, completion: {
                                        
                                        self.navigationController?.popViewControllerAnimated(true)
                                        
                                    })
                                    
                                }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                            if jsonData["status"] as? String == "OK"
                            {
                                print(jsonData)
                                if let results = jsonData["results"] as? [[String:AnyObject]]
                                {
                                    for item in results
                                    {
                                        if (item["types"] as? [String])!.contains(passType)
                                        {
                                            if let geometry = item["geometry"] as?
                                                [String:AnyObject]
                                            {
                                                
                                                if let location = geometry["location"] as? [String:AnyObject]
                                                {
                                                    let lat = location["lat"] as? Double
                                                    let lon = location["lng"] as? Double
                                                    self.latitudes.append(lat!)
                                                    self.longitudes.append(lon!)
                                                }
                                                
                                            }
                                            if let name = item["name"] as? String
                                            {
                                                self.names.append(name)
                                            }
                                        }
                                    }
                                    if (self.names.count > 0)
                                    {
                                        print(self.latitudes.count)
                                        print(self.longitudes.count)
                                        print(self.names.count)
                                        self.spinner.stopAnimating()
                                        self.tableView.reloadData()
                                        self.locationManager.stopUpdatingLocation()
                                    }
                                    else
                                    {
                                        let alert = NYAlertViewController()
                                        alert.title = "No Results Found"
                                        alert.message = "Please try a different range"
                                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                                            
                                            self.dismissViewControllerAnimated(true, completion: {
                                                
                                                self.navigationController?.popViewControllerAnimated(true)
                                                
                                            })
                                            
                                        }))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                        catch
                        {
                            
                        }
                        
                    })
                }
                
            }
            task.resume()
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        passLat = latitudes[indexPath.row]
        passLon = longitudes[indexPath.row]
        passCurrentLocation = currentLocation
        passName = names[indexPath.row]
        self.performSegueWithIdentifier("mapSegue", sender: self)
        
        
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
