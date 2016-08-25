//
//  testFeedCell.swift
//  connectFinal
//
//  Created by Swapnil Dhanwal on 22/06/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class testFeedCell: UITableViewCell {

    @IBOutlet var paddingView: UIView!
    @IBOutlet var likes: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var date: UILabel!
    
    
    @IBOutlet var societyImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
