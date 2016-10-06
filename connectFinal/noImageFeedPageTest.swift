//
//  noImageFeedPageTest.swift
//  connectFinal
//
//  Created by Swapnil Dhanwal on 03/10/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class noImageFeedPageTest: UIViewController, UIScrollViewDelegate {
    
    var viewHeight = CGFloat()
    var viewWidth = CGFloat()
    var navHeight = CGFloat()
    var scrollView = UIScrollView()
    var scrollHeight = CGFloat()
    var scrollWidth = CGFloat()
    var textView = UITextView()
    var textHeight = CGFloat()
    var textWidth = CGFloat()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting view and subviews' height and width properties
        navHeight = (self.navigationController?.navigationBar.frame.height)!
        viewHeight = self.view.frame.height
        viewWidth = self.view.frame.width
        scrollHeight = viewHeight-navHeight
        scrollWidth = viewWidth
        textHeight = scrollHeight * 0.90
        textWidth = scrollWidth * 0.90
        
        //Adding the UIScrollView to the view
        scrollView = UIScrollView(frame: CGRect(x: viewWidth/2-scrollWidth/2, y: viewHeight/2-scrollHeight/2+navHeight, width: scrollWidth, height: scrollHeight-navHeight/2))
        scrollView.backgroundColor = UIColor.clear
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(scrollView)
        
        //Adding the UITextView to the view
        textView = UITextView(frame: CGRect(x: scrollWidth/2-textWidth/2, y: scrollHeight/2-textHeight/2, width: textWidth, height: textHeight))
        let text = passMessage
        textView.isEditable = true
        textView.text = text
        textView.font = UIFont(name: "Avenir Next Condensed", size: 20)
        textHeight = textView.sizeThatFits(CGSize(width: textWidth, height: 1000)).height
        textView.frame = CGRect(x: scrollWidth/2-textWidth/2, y: 20, width: textWidth, height: textHeight)
        textView.isScrollEnabled = false
        textView.autoresizingMask = [.flexibleWidth]
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        self.scrollView.addSubview(textView)
        
        //setting the scrollView's contentSize property
        scrollView.contentSize = CGSize(width: scrollWidth, height: max(scrollHeight, textHeight+50))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //we need to change the frame dimensions in case the user changes the orientation of his/her phone and reset the frames
    override func viewDidLayoutSubviews() {
        
        print(textView.frame)
        print(textView.frame.origin)
        
        navHeight = (self.navigationController?.navigationBar.frame.height)!
        viewHeight = self.view.frame.height
        viewWidth = self.view.frame.width
        scrollHeight = viewHeight-navHeight
        scrollWidth = viewWidth
        textHeight = scrollHeight * 0.90
        textWidth = scrollWidth * 0.90
        
        scrollView = UIScrollView(frame: CGRect(x: viewWidth/2-scrollWidth/2, y: viewHeight/2-scrollHeight/2+navHeight, width: scrollWidth, height: scrollHeight-navHeight/2))
        textView = UITextView(frame: CGRect(x: scrollWidth/2-textWidth/2, y: scrollHeight/2-textHeight/2, width: textWidth, height: textHeight))
        scrollView.contentSize = CGSize(width: scrollWidth, height: max(scrollHeight, textHeight))
        
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
