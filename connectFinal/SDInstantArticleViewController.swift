//
//  ViewController.swift
//  scrollViewTest
//
//  Created by Swapnil Dhanwal on 24/08/16.
//  Copyright © 2016 Swapnil Dhanwal. All rights reserved.
//

import UIKit
import MWPhotoBrowser
import SDWebImage

class SDInstantArticleViewController : UIViewController, UIScrollViewDelegate, MWPhotoBrowserDelegate {
    
    var scrollView = UIScrollView()
    var imageView = UIImageView()
    var infoView = UIView()
    var textView = UITextView()
    var photos = [MWPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need to set nav height to avoid image getting clipped
        let navHeight = self.navigationController?.navigationBar.frame.height
        
        //setting up the scroll view
        scrollView = UIScrollView(frame: CGRect(x: 0, y: navHeight!, width: self.view.frame.width, height: self.view.frame.height))
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.delegate = self
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        self.view.addSubview(scrollView)
        
        //setting up the image view and adding it to the scroll view as a subview
        imageView = UIImageView(frame: CGRect(x: 0, y: navHeight!-20, width: self.view.frame.width, height: 200))
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        
        //setting up the second view, to display text, to the scroll view
        infoView = UIView(frame: CGRect(x: 0, y: 180, width: self.view.frame.width, height: 500))
        
        //here it is important to set the content size property of the scroll view. If we assume the scroll view to be a window, then the content size is the size of the view looking through it.
        scrollView.contentSize = CGSizeMake(imageView.frame.width, imageView.frame.height+infoView.frame.height)
        scrollView.addSubview(infoView)
        
        //Setting up the coloured line demarcating the image view and the info view and adding it as a subview to the info view.
        let lineLabel = UILabel(frame: CGRect(x: 0, y: 0, width: infoView.frame.width, height: 5))
        lineLabel.backgroundColor = UIColor(red: 0, green: 179/255, blue: 164/255, alpha: 1)
        lineLabel.text = ""
        lineLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth]
        infoView.addSubview(lineLabel)
        
        //OPTIONAL : set the text to be displayed in the info view's text view
        let text = passMessage
        
        //set background colours as per requirements
        scrollView.backgroundColor = UIColor(red: 231/255, green: 234/255, blue: 236/255, alpha: 1)
        infoView.backgroundColor = UIColor(red: 231/255, green: 234/255, blue: 236/255, alpha: 1)
        
        //setting up the text view.
        textView.text = text
        textView.selectable = true
        textView.editable = true
        textView.font = UIFont(name: "Avenir Next Condensed", size: 20)
        textView.font = UIFont.systemFontOfSize(20)
//        let textHeight = max(textView.sizeThatFits(CGSize(width: self.infoView.frame.width-20, height: 1000)).height, 500)
        let textHeight = textView.sizeThatFits(CGSize(width: self.infoView.frame.width-20, height: 1000)).height
        let textViewFrame = CGRectMake(10, lineLabel.frame.height+20, self.infoView.frame.width-20, textHeight)
        textView = UITextView(frame: textViewFrame)
        textView.dataDetectorTypes = .All
        textView.editable = false
        textView.text = text
        infoView.addSubview(textView)
        textView.font = UIFont.systemFontOfSize(20)
        textView.font = UIFont(name: "Avenir Next Condensed", size: 20)
        textView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        
        
        //need to change the info view frame again to such that its height remains the maximum of 500 and the height of the text view
        infoView.frame = CGRect(x: 0, y: 180, width: self.view.frame.width, height: max(self.textView.frame.height+50,550))
        
        //need to update the scrollview's frame again to account for the textview and navigation bar.
        
        scrollView.contentSize = CGSizeMake(imageView.frame.width, imageView.frame.height+infoView.frame.height + navHeight!+75)
        
        
        
        //setting the images in the photo browser
        photos.removeAll()
        print(passAttachments)
        if let attachments = passAttachments
        {
            if let data = attachments["data"] as? [[String:AnyObject]]
            {
                for dataItem in data
                {
                    if let subattachments = dataItem["subattachments"] as? [String:AnyObject]
                    {
                        if let subData = subattachments["data"] as? [[String:AnyObject]]
                        {
                            for subDataItem in subData
                            {
                                if let media = subDataItem["media"] as? [String:AnyObject]
                                {
                                    if let image = media["image"] as? [String:AnyObject]
                                    {
                                        if let src = image["src"] as? String
                                        {
                                            photos.append(MWPhoto(URL: NSURL(string: src)!))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        if let media = dataItem["media"] as? [String:AnyObject]
                        {
                            if let image = media["image"] as? [String:AnyObject]
                            {
                                if let src = image["src"] as? String
                                {
                                    photos.append(MWPhoto(URL: NSURL(string : src)!))
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        imageView.setShowActivityIndicatorView(true)
        imageView.sd_setImageWithURL(NSURL(string: passHighResImageURL))
        imageView.sd_setImageWithURL(NSURL(string: passHighResImageURL)) { (image, error, cache, url) in
            
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SDInstantArticleViewController.tapped))
        tap.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(tap)
        imageView.userInteractionEnabled = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func tapped()
    {
        print("tapped!")
        print(photos)
        let browser = MWPhotoBrowser(photos: photos)
        browser.delegate = self
        
        self.navigationController?.pushViewController(browser, animated: true)
    }
    
    
    internal func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt
    {
        return UInt(photos.count)
    }
    internal func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol!
    {
        return photos[Int(index)]
    }
    
    
    //This method is called whenever the view changes the layout of its sub views. In this case, this happens when the phone's orientation changes. So we need to accound for the change in the height of the navigation bar. This involves changing the frames of each sub view of the main view and also the content size property of the scroll view.
    override func viewWillLayoutSubviews() {
        
        if let navHeight = self.navigationController?.navigationBar.frame.height
        {
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: navHeight, width: self.view.frame.width, height: self.view.frame.height))
        
        imageView.frame = CGRect(x: 0, y: navHeight-20, width: self.view.frame.width, height: 200)
        infoView.frame =  CGRect(x: 0, y: 180+navHeight, width: self.view.frame.width, height: 500)
        scrollView.contentSize = CGSizeMake(imageView.frame.width, imageView.frame.height+infoView.frame.height+75)
        }
    }
    
    //This is probably the most important method of this class. It accounts for the zooming effect when the user drags down on the scroll view from the top.
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        if (y < 0)
        {
            if let navHeight = self.navigationController?.navigationBar.frame.height
            {
            self.imageView.frame = CGRectMake(0, navHeight-20, self.view.frame.width, 200 - y*1.5)
            self.imageView.center.y += (y*1.5)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

