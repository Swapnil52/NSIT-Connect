//
//  playerView.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 24/03/16.
//  Copyright © 2016 SwApp. All rights reserved.
//


import UIKit
var height = CGFloat()
var width = CGFloat()


class playerView: UIViewController, YTPlayerViewDelegate {

    @IBOutlet weak var playerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(passVideoId)
        playerView.loadWithVideoId(passVideoId)
        height = 64
        width = (self.navigationController?.navigationBar.frame.width)!
        updateNavBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView) {
        
        print("ready!")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        updateNavBar()
        
    }
    
    
    func updateNavBar()
    {
        self.navigationController?.navigationBar.frame = CGRectMake(0, 0, width, 64)
        
    }
    
    func playerView(playerView: YTPlayerView, didChangeToState state: YTPlayerState) {
        
        if state == .Ended
        {
            print("potty")
        }
        if state == YTPlayerState.Paused
        {
            print("tutti")
        }
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
