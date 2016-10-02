//
//  feedCell.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 12/02/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class feedCell: UITableViewCell {

    //@IBOutlet weak var cellPaddingView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var societyImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
