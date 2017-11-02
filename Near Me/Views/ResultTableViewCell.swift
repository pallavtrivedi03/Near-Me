//
//  ResultTableViewCell.swift
//  Near Me
//
//  Created by Pallav Trivedi on 31/10/17.
//  Copyright © 2017 Pallav Trivedi. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var siteAddressLabel: UILabel!
    @IBOutlet weak var siteRatingLabel: UILabel!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var siteImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
