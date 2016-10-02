//
//  compCell.swift
//  connectFinal
//
//  Created by Swapnil Dhanwal on 01/06/16.
//  Copyright © 2016 SwApp. All rights reserved.
//

import UIKit

class compCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var end: UILabel!
    
    @IBOutlet weak var paddingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
