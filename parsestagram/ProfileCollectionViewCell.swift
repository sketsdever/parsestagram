//
//  ProfileCollectionViewCell.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/22/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileCollectionViewCell: UICollectionViewCell {
    
    var user: PFUser!
    var photo: PFFile!
    
    @IBOutlet weak var photoView: PFImageView!
    
    var gram: PFObject! {
        didSet {
            
            user = gram["author"] as? PFUser
            
            photo = gram["media"] as? PFFile
            self.photoView.file = photo
            self.photoView.loadInBackground()

            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.photoView.file = photo
//        self.photoView.loadInBackground()
    }
}
