//
//  feedSettings.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 17/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

//variables :

var selectedFeeds = ["184835371535420":false, "252117054812001":false, "109582689081817":false, "158168947539641":false, "604809706256620":false, "376394819102290":false, "278952135548721":false, "126976547314225":false, "185960271431856":false, "135639763273290":false, "499766883378107":false, "1457237581165961":false]
var societies = ["CROSSLINKS", "COLLEGESPACE", "BULLETHAWK", "JUNOON", "ROTARACT", "DEBSOC", "IEEE", "CSI", "QUIZ CLUB", "ASHWAMEDH", "ENACTUS", "AAGAZ"]
var societyIds = ["184835371535420", "252117054812001", "109582689081817", "158168947539641", "604809706256620", "376394819102290", "278952135548721", "126976547314225", "185960271431856", "135639763273290", "499766883378107", "1457237581165961"]
var empty = 0

var selectedFeedsMutable = [String:Bool]()
var emptyMutable : Int!

//crosslinks, collegespace, bullet, junoon, rotaract, debsoc, ieee, csi, quiz, ashwa, enactus, aagaz

import UIKit

class feedSettings: UITableViewController {
    
    var logoURLs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.reloadData()
        print(selectedFeeds)
        print(empty)
        
        logoURLs = ["crosslinks.png", "collegespace.png", "bullethawk.png", "junoon.png", "rotaract.png", "debsoc.png", "ieee.png", "csi.png", "quiz.png", "ashwamedh.png", "enactus.png", "aagaz.png"]
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "societyCell", for: indexPath) as! feedSettingsCell
        
        cell.societyName.text = societies[(indexPath as NSIndexPath).row]
        cell.logo.image = UIImage(named: self.logoURLs[(indexPath as NSIndexPath).row])
        
        if selectedFeeds[societyIds[(indexPath as NSIndexPath).row]] == true
        {
            cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedFeeds[societyIds[(indexPath as NSIndexPath).row]] == false
        {
            
            selectedFeeds[societyIds[(indexPath as NSIndexPath).row]] = true
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            empty += 1
            print(empty)
            UserDefaults.standard.set(empty, forKey: "empty")
            UserDefaults.standard.set(selectedFeeds, forKey: "selectedFeeds")
            
        }
        
        else
        {
            
            selectedFeeds[societyIds[(indexPath as NSIndexPath).row]] = false
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .none
            empty -= 1
            UserDefaults.standard.set(empty, forKey: "empty")
            UserDefaults.standard.set(selectedFeeds, forKey: "selectedFeeds")
            print(empty)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        didGoToFeedPage = false
        didGoToSettings = true
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
