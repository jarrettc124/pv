//
//  ReviewTableViewCell.swift
//  
//
//  Created by Jarrett Chen on 2/25/16.
//
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    
    //Mark - Methods
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    //Mark - Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
