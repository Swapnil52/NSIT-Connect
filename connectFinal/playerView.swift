//
//  playerView.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 24/03/16.
//  Copyright © 2016 SwApp. All rights reserved.
//


import UIKit
import youtube_ios_player_helper
var height = CGFloat()
var width = CGFloat()


class playerView: UIViewController, YTPlayerViewDelegate {

    @IBOutlet weak var playerView: YTPlayerView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerView.delegate = self
        
        print(passVideoId)
        playerView.loadWithVideoId(passVideoId)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        
        self.playerView.removeFromSuperview()
        self.playerView.delegate = nil
        self.playerView = nil
        
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
