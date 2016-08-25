//
//  testCustomFeedCell.swift
//  connectFinal
//
//  Created by Swapnil Dhanwal on 22/06/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class testCustomFeedCell: UITableViewCell {

    @IBOutlet var paddingView: UIView!
    @IBOutlet var societyName: UILabel!
    @IBOutlet var message: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var likes: UILabel!
    @IBOutlet var thumbnail: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
