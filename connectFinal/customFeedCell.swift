//
//  customFeedCell.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 18/03/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class customFeedCell: UITableViewCell {

    //constraints
    //@IBOutlet weak var titleLeft: NSLayoutConstraint!
    @IBOutlet weak var stackTop: NSLayoutConstraint!
    @IBOutlet weak var lineTop: NSLayoutConstraint!
    @IBOutlet weak var dateTop: NSLayoutConstraint!
    //@IBOutlet weak var messageLeft: NSLayoutConstraint!
    //@IBOutlet weak var dateLeft: NSLayoutConstraint!
    //@IBOutlet weak var lineLeft: NSLayoutConstraint!
    //@IBOutlet weak var stackLeft: NSLayoutConstraint!
    
    
    @IBOutlet weak var societyName: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var line: UILabel!
    @IBOutlet weak var likesThumb: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
