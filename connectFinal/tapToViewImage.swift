//
//  tapToViewImage.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 13/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit
import Photos
import NYAlertViewController

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
            let urlString = passHighResImageURL
            
            let url = NSURL(string: urlString)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let bytes = data?.length
                    print(bytes == 0)
                    
                    if error != nil
                    {
                        
                        let alert = NYAlertViewController()
                        alert.title = "An Error Occurred"
                        alert.message = "Please try again later"
                        alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                        alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        }))
                        self.presentViewController(alert, animated: true, completion: { 
                            
                           self.spinner.stopAnimating()
                            
                        })
                    }
                    
                    if data?.length != 0
                    {
                        let image = UIImage(data: (data)!)
                        if image != nil
                        {
                            self.image = UIImage(data: data!)!
                            self.spinner.stopAnimating()
                            

                            self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.image.size)
                            
                            self.scrollView.addSubview(self.imageView)
                            self.scrollView.contentSize = self.imageView.frame.size
                            self.imageView.image = self.image

                            self.imageView.contentMode = .ScaleAspectFill
                            let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapToViewImage.scrollViewDoubleTapped(_:)))
                            doubleTapRecognizer.numberOfTapsRequired = 2
                            doubleTapRecognizer.numberOfTouchesRequired = 1
                            self.scrollView.addGestureRecognizer(doubleTapRecognizer)
                            //self.setZoomScale()
                            let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(tapToViewImage.saveImage))
                            button.title = "Save"
                            
                            self.navigationItem.rightBarButtonItem = button
                        }

                    }
                    
                })
                
            })

            task.resume()
            
        }
        
    }
    
    
    
    func saveImage()
    {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized
        {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//            let alert = UIAlertController(title: "Image Saved!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
            
            let alert = NYAlertViewController()
            alert.title = "Image Saved!"
            alert.message = ""
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)

            
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.NotDetermined
        {
            PHPhotoLibrary.requestAuthorization({ (status) in
                
                if status == PHAuthorizationStatus.Authorized
                {
                    UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
                    print("potty")
//                    let alert = UIAlertController(title: "Image Saved!", message: "", preferredStyle: UIAlertControllerStyle.Alert)
//                    
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    let alert = NYAlertViewController()
                    alert.title = "Image Saved!"
                    alert.message = ""
                    alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
                    alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)

                    
                }
                
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Denied
        {
//            let alert = UIAlertController(title: "NSIT Connect Does Not Have Permission to Save Images to The Camera Roll", message: "Please allow permission in settings", preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { (action) in
//                
//                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
//                
//            }))
//            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
            
            let alert = NYAlertViewController()
            alert.view.frame = CGRectMake(0, 0, 100, 100)
            alert.title = "NSIT Connect Does Not Have Permission to Save Images"
            alert.message = "Please allow permission in settings"
            alert.buttonColor = UIColor(red: 1/255, green: 179/255, blue: 164/255, alpha: 1)
            alert.addAction(NYAlertAction(title: "Settings", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(false, completion: nil)
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                
            }))
            alert.addAction(NYAlertAction(title: "OK", style: .Default, handler: { (action) in
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func centerScrollViewContents()
    {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)

    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        centerScrollViewContents()
    }
    
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.locationInView(imageView)
        
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        scrollView.zoomToRect(rectToZoomTo, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return imageView
    }
    
    
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.maximumZoomScale = 4
        scrollView.zoomScale = 1.0
    }
    
    
    override func viewDidLayoutSubviews() {
        
        centerScrollViewContents()
        setZoomScale()
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
