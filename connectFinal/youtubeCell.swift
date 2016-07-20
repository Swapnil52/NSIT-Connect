//
//  youtubeCell.swift
//  connect2
//
//  Created by Swapnil Dhanwal on 26/03/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class youtubeCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
