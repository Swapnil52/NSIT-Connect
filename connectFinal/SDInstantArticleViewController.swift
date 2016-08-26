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
//    var photos = [M]()
    var photos = [MWPhoto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navHeight = self.navigationController?.navigationBar.frame.height
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: navHeight!, width: self.view.frame.width, height: self.view.frame.height))
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        imageView = UIImageView(frame: CGRect(x: 0, y: navHeight!-20, width: self.view.frame.width, height: 200))
        imageView.backgroundColor = UIColor.lightGrayColor()
        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        infoView = UIView(frame: CGRect(x: 0, y: 180, width: self.view.frame.width, height: 500))
        
        scrollView.contentSize = CGSizeMake(imageView.frame.width, imageView.frame.height+infoView.frame.height)
        infoView.backgroundColor = UIColor.redColor()
        scrollView.addSubview(infoView)
        
        let lineLabel = UILabel(frame: CGRect(x: 0, y: 0, width: infoView.frame.width, height: 5))
        lineLabel.backgroundColor = UIColor(red: 0, green: 179/255, blue: 164/255, alpha: 1)
        lineLabel.text = ""
        infoView.addSubview(lineLabel)
        
        let text = passMessage
        
        scrollView.backgroundColor = UIColor(red: 231/255, green: 234/255, blue: 236/255, alpha: 1)
        infoView.backgroundColor = UIColor(red: 231/255, green: 234/255, blue: 236/255, alpha: 1)
        
        textView.text = text
        textView.selectable = true
        textView.editable = true
        textView.font = UIFont(name: "Avenir Next Condensed", size: 20)
        textView.font = UIFont.systemFontOfSize(20)
        let textHeight = min(textView.sizeThatFits(CGSize(width: self.infoView.frame.width-20, height: 1000)).height, 500)
        let textViewFrame = CGRectMake(10, lineLabel.frame.height+20, self.infoView.frame.width-20, textHeight)
        textView = UITextView(frame: textViewFrame)
        textView.dataDetectorTypes = .All
        textView.editable = false
        textView.text = text
        infoView.addSubview(textView)
        textView.font = UIFont.systemFontOfSize(20)
        textView.font = UIFont(name: "Avenir Next Condensed", size: 20)
        
        
        infoView.frame = CGRect(x: 0, y: 180, width: self.view.frame.width, height: max(self.textView.frame.height+50,500))
        
        textView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        
        scrollView.contentSize = CGSizeMake(imageView.frame.width, imageView.frame.height+infoView.frame.height + navHeight!)
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        lineLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth]
        
        
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
    
    override func viewWillLayoutSubviews() {
        
        if let navHeight = self.navigationController?.navigationBar.frame.height
        {
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: navHeight, width: self.view.frame.width, height: self.view.frame.height))
        
        imageView.frame = CGRect(x: 0, y: navHeight-20, width: self.view.frame.width, height: 200)
        infoView.frame =  CGRect(x: 0, y: 180+navHeight, width: self.view.frame.width, height: 500)
        scrollView.contentSize = CGSizeMake(imageView.frame.width, imageView.frame.height+infoView.frame.height)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let y = scrollView.contentOffset.y
        if (y < 0)
        {
            if let navHeight = self.navigationController?.navigationBar.frame.height
            {
            self.imageView.frame = CGRectMake(0, navHeight-20, self.view.frame.width, 200 - y*1.5)
            self.imageView.center.y += (y*1.5)
            }
            print(y)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

