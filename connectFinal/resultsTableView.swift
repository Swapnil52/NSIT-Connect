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
    var addresses = [String]()
    var openStatus = [String]()
    var ids = [String]()
    var photos = [String:String]()
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var gotLocation = Bool()
    //var gotLocation = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = UIColor.clearColor()
        
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
            let alert = NYAlertViewController()
            alert.title = "Location Services Are Disabled"
            alert.message = "Please enable location services in settings"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(false, completion: { 
                    
                    UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=LOCATION_SERVICES")!)
                    self.navigationController?.popViewControllerAnimated(false)
                })
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
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
        
        if photos[ids[indexPath.row]] != nil
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("resultCell", forIndexPath: indexPath) as! resultTableViewCell
            
            cell.layoutIfNeeded()
            
            let path = UIBezierPath(rect: (cell.paddingView.bounds))
            cell.paddingView.layer.shadowPath = path.CGPath
            cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
            cell.paddingView.layer.shadowOpacity = 0.4
            cell.resultName.text = names[indexPath.row]
            cell.resultAddress.text = addresses[indexPath.row]
            cell.openStatus.text = openStatus[indexPath.row]
            
            cell.resultImageview.setShowActivityIndicatorView(true)
            cell.resultImageview.setIndicatorStyle(.White)
            cell.resultImageview.sd_setImageWithURL(NSURL(string: photos[ids[indexPath.row]]!))
            cell.resultImageview.sd_setImageWithURL(NSURL(string: photos[ids[indexPath.row]]!), completed: { (image, error, cache, url) in
                
                if error == nil
                {
                    cell.resultImageview.layer.masksToBounds = true
                }
                
            })
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("noImageResultCell", forIndexPath: indexPath) as! noImageResultCell
        
        cell.layoutIfNeeded()
        
        let path = UIBezierPath(rect: (cell.paddingView.bounds))
        cell.paddingView.layer.shadowPath = path.CGPath
        cell.paddingView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        cell.paddingView.layer.shadowOpacity = 0.4
        cell.resultName.text = names[indexPath.row]
        cell.resultAddress.text = addresses[indexPath.row]
        cell.openStatus.text = openStatus[indexPath.row]
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("resultMapSegue", sender: self)
        passName = names[indexPath.row]
        passLat = latitudes[indexPath.row]
        passLon = longitudes[indexPath.row]
        passCurrentLocation = currentLocation
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("enable services!")
        let alert = NYAlertViewController()
        alert.title = "An Error Occurred"
        alert.message = "Please check your internet connection or locations preferences"
        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
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
                        alert.buttonColor = UIColor(red: 0x1b/255, green: 0xb2/255, blue: 0x9b/255, alpha: 1)
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
                            self.addresses.removeAll()
                            self.openStatus.removeAll()
                            self.photos.removeAll()
                            self.ids.removeAll()
                            
                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                            if jsonData["status"] as? String == "ZERO_RESULTS"
                            {
                                let alert = NYAlertViewController()
                                alert.title = "No Results Found"
                                alert.message = "Please try a different range"
                                alert.buttonColor = UIColor(red: 0x1b/255, green: 0xb2/255, blue: 0x9b/255, alpha: 1)
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
                                            if let id = item["id"] as? String
                                            {
                                                self.ids.append(id)
                                            }
                                            if let name = item["name"] as? String
                                            {
                                                self.names.append(name)
                                            }
                                            if let address = item["vicinity"] as? String
                                            {
                                                self.addresses.append(address)
                                            }
                                            
                                            if item["opening_hours"] != nil
                                            {
                                                if let openingHours = item["opening_hours"] as? [String:AnyObject]
                                                {
                                                    if let openStatus = openingHours["open_now"] as? Bool
                                                    {
                                                        if openStatus == true
                                                        {
                                                            self.openStatus.append("Open Now")
                                                        }
                                                        else
                                                        {
                                                            self.openStatus.append("Closed")
                                                        }
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                self.openStatus.append("No Information Available")
                                            }
                                            
                                            
                                            if let photos = item["photos"] as? [[String:AnyObject]]
                                            {
                                                for photo in photos
                                                {
                                                    if let reference = photo["photo_reference"] as? String
                                                    {
                                                        let url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(reference)&key=AIzaSyBgApnLxwHxTvcV9Go2YTcqiWVIY1eUgdA"
                                                        self.photos[(item["id"] as? String)!] = url
                                                        break;
                                                    }
                                                    else
                                                    {
                                                        self.photos[item["id"] as! String] = nil
                                                        break;
                                                    }

                                                }
                                            }
                                        }
                                    }
                                    if (self.names.count > 0)
                                    {
                                        print(self.openStatus.count)
                                        print(self.photos.count)
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
                                        alert.buttonColor = UIColor(red: 0x1b/255, green: 0xb2/255, blue: 0x9b/255, alpha: 1)
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
    


}
