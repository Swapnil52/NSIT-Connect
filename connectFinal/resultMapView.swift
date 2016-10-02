//
//  resultMapView.swift
//  connectFinal
//
//  Created by Swapnil Dhanwal on 24/06/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import NYAlertViewController

class resultMapView: UIViewController, MKMapViewDelegate {

    @IBOutlet var resultMap: MKMapView!
    @IBAction func getDirections(_ sender: AnyObject) {
        
        let sourceLocation = CLLocationCoordinate2DMake(passCurrentLocation.coordinate.latitude, passCurrentLocation.coordinate.longitude)
        
        let destinationLocation = CLLocationCoordinate2DMake(passLat, passLon)
        
        //let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(passCurrentLocation.coordinate.latitude, passCurrentLocation.coordinate.longitude), addressDictionary: nil)
        
        //let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(passLat, passLon), addressDictionary: nil)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "You are here"
        sourceAnnotation.coordinate = sourceLocation

        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationLocation
        destinationAnnotation.title = passName
        
        //self.resultMap.showAnnotations([sourceAnnotation, destinationAnnotation], animated: true)
    
        
        let url = "http://maps.google.com/maps?saddr=\(sourceLocation.latitude),\(sourceLocation.longitude)&daddr=\(destinationLocation.latitude),\(destinationLocation.longitude)"
        
        UIApplication.shared.openURL(URL(string: url)!)
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //akanksha is a baby potty
        
        self.resultMap.delegate = self
        
        let destinationLocation = CLLocationCoordinate2DMake(passLat, passLon)
        
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.coordinate = destinationLocation
        destinationAnnotation.title = passName
        
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(destinationLocation, span)
        resultMap.setRegion(region, animated: true)
        resultMap.addAnnotations([destinationAnnotation])
        resultMap.selectAnnotation(destinationAnnotation, animated: true)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.resultMap.delegate = nil
        self.resultMap = nil
        super.viewDidDisappear(animated)
        
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
