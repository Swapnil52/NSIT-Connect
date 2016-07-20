//
//  tapToViewImage.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 13/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import Photos

class tapToViewImage: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image = UIImage()
    var pictureURLs = [String]()
    var imageView = UIImageView()
    var spinner = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        if  passPictureId == nil{
            print("potty")
        }
        
        if passPictureId != nil || passPictureId == nil
        {
            print(passHighResImageURL)
            spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            spinner.center = self.view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = .WhiteLarge
            spinner.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
            view.addSubview(spinner)
            spinner.layer.cornerRadius = 10
            spinner.startAnimating()
            //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            //let urlString = "https://graph.facebook.com/"+passPictureId+"?fields=images&access_token=CAAGZAwVFNCKgBAANhEYok6Xh7Q7UZBeTZCUqwPDLYhRZCmNn0igI8SE339jSn2zjxCpA1JUmXHm55XKVXslhdKKoTF3b5sLsiZBVd0ylYwX3MIGOnRyzn0T2XVywwoPKP7ML9WZCqELGRuIGxoM8ia05CiUiqcbgsb4wzTuBKkvKaqb7TPt2VnPtprRZBWda4kZD"
            let urlString = passHighResImageURL
            
            let url = NSURL(string: urlString)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                
                dispatch_async(dispatch_get_main_queue(), { 
                    
                    if let _  = data
                    {
                        self.image = UIImage(data: data!)!
                        self.spinner.stopAnimating()
                        

                        self.image = UIImage(data: data!)!

                        self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.image.size)

                        self.scrollView.addSubview(self.imageView)
                        self.scrollView.contentSize = self.imageView.frame.size
                        self.imageView.image = self.image

                        self.imageView.contentMode = .ScaleAspectFill
                        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToViewImage.scrollViewDoubleTapped(_:)))
                        doubleTapRecognizer.numberOfTapsRequired = 2
                        doubleTapRecognizer.numberOfTouchesRequired = 1
                        self.scrollView.addGestureRecognizer(doubleTapRecognizer)
                        let scrollViewFrame = self.view.frame
                        let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width
                        let scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height
                        let minScale = min(scaleWidth, scaleHeight);
                        self.scrollView.minimumZoomScale = minScale;

                        self.scrollView.maximumZoomScale = 1
                        
                        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(tapToViewImage.saveImage))
                        button.title = "Save"
                        
                        self.navigationItem.rightBarButtonItem = button

                    }
                    
                })
                
            })
//            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
//                
//                dispatch_async(dispatch_get_main_queue(), { 
//                    
//                    if let data = data
//                    {
//                        do
//                        {
//                            let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
//                            
//                            print(jsonData)
//                            
//                            if jsonData["error"] != nil
//                            {
//                                self.spinner.stopAnimating()
//                                //UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                                
//                                self.image = passImage
//                            
//                                self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.image.size)
//                                
//                                //self.imageView.frame = self.view.bounds
//                                self.scrollView.addSubview(self.imageView)
//                                self.scrollView.contentSize = self.image.size
//                                self.imageView.image = self.image
//                                // 3
//                                let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
//                                doubleTapRecognizer.numberOfTapsRequired = 2
//                                doubleTapRecognizer.numberOfTouchesRequired = 1
//                                self.scrollView.addGestureRecognizer(doubleTapRecognizer)
//                                
//                                // 4
//                                let scrollViewFrame = self.scrollView.frame
//                                let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width
//                                let scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height
//                                let minScale = min(scaleWidth, scaleHeight);
//                                self.scrollView.minimumZoomScale = minScale;
//                                
//                                // 5
//                                self.scrollView.maximumZoomScale = 1.0
//                                self.scrollView.zoomScale = minScale;
//                                
//                                // 6
//                                self.centerScrollViewContents()
//                            }
//                            
//                            if let items = jsonData["images"] as? [[String : AnyObject]]
//                            {
//                                for item in items
//                                {
//                                    self.pictureURLs.append(item["source"] as! String)
//                                    let highRes = self.pictureURLs[0]
//                                    
//                                    let newTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string : highRes)!, completionHandler: { (data, response, error) in
//                                        
//                                        dispatch_async(dispatch_get_main_queue(), { 
//                                            
//                                            self.spinner.stopAnimating()
//                                            //UIApplication.sharedApplication().endIgnoringInteractionEvents()
//                                            
//                                            self.image = UIImage(data: data!)!
//                                            
//                                            self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.image.size)
//                                            
//                                            //self.imageView.frame = self.scrollView.bounds
//                                            self.scrollView.addSubview(self.imageView)
//                                            self.scrollView.contentSize = self.imageView.frame.size
//                                            self.imageView.image = self.image
//                                            // 3
//                                            self.imageView.contentMode = .ScaleAspectFit
//                                            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
//                                            doubleTapRecognizer.numberOfTapsRequired = 2
//                                            doubleTapRecognizer.numberOfTouchesRequired = 1
//                                            self.scrollView.addGestureRecognizer(doubleTapRecognizer)
//                                            
//                                            // 4
//                                            let scrollViewFrame = self.view.frame
//                                            let scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width
//                                            let scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height
//                                            let minScale = min(scaleWidth, scaleHeight);
//                                            self.scrollView.minimumZoomScale = minScale;
//                                            //self.scrollView.zoomScale = self.view.frame.width/self.imageView.image!.size.width
//                                            
//                                            // 5
//                                            self.scrollView.maximumZoomScale = 1
//                                            self.scrollView.zoomScale = 1;
//                                            
//                                            // 6
//                                            //self.centerScrollViewContents()
//                                            
//                                            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveImage")
//                                            button.title = "Save"
//                                            
//                                            self.navigationItem.rightBarButtonItem = button
//                                        })
//                                        
//                                    })
//                                    newTask.resume()
//                                    
//                                }
//                            }
//                            
//                        }
//                        
//                        catch
//                        {
//                            print(error)
//                        }
//                    }
//                    
//                })
//                
//                
//            })
            task.resume()
            
        }
        

        // Do any additional setup after loading the view.
    }
    
    func saveImage()
    {
        
        let status:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if status == PHAuthorizationStatus.Authorized
        {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("potty")
            let alert = UIAlertController(title: "Image Saved!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        else
        {
            let alert = UIAlertController(title: "Please allow NSITConnect to acess the camera roll", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (action) in
                
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.sharedApplication().openURL(url)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(imageView)
        
        // 2
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        centerScrollViewContents()
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
