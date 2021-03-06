//
//  CustomCellTableViewCell.swift
//  Park 'N Go
//
//  Created by Shaheen Sharifian on 7/13/15.
//  Copyright (c) 2015 Shaheen Sharifian. All rights reserved.
//

import UIKit

class CustomCellTableViewCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var imageRight: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(leftLabel:String, imageName:String) {
        self.leftLabel.text = leftLabel;
        self.imageRight.image = UIImage(named: imageName);
    }

}
