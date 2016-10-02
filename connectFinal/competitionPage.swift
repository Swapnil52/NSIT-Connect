//
//  competitionPage.swift
//  connectFinal
//
//  Created by Swapnil Dhanwal on 30/05/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class competitionPage: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var end: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var url: UITextView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let startTime = passItem["start"] as! String
        let endTime = passItem["end"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        var temp = dateFormatter.date(from: startTime)
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        let newStartTime = dateFormatter.string(from: temp!)
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        temp = dateFormatter.date(from: endTime)
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        let newEndTime = dateFormatter.string(from: temp!)
        
        start.text = "Starts at: \(newStartTime)"
        end.text = "Ends at: \(newEndTime)"
        
        
        descriptionTextView.text = passItem["description"] as? String
        if descriptionTextView.text == ""
        {
            descriptionTextView.text = "No description available"
        }
        
        descriptionTextView.layer.cornerRadius = 3
        descriptionTextView.layer.borderColor = UIColor(red: 00/255, green: (179/255), blue: 164/255, alpha: 1).cgColor
        
        
        titleLabel.text = passItem["title"] as? String
        
        url.text = passItem["url"] as? String
        url.scrollRangeToVisible(NSMakeRange(0, 0))
        
        scrollView.contentSize.height = 200
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.descriptionTextView.isScrollEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.descriptionTextView.isScrollEnabled = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
