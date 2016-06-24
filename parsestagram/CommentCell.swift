//
//  CommentCell.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/23/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var profileImageView: PFImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //commentLabel.text = comment["text"] as? String
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
