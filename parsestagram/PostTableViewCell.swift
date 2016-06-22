//
//  PostCell.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/20/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PostTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var photoView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    var user: PFUser!
    
    var gram: PFObject! {
        didSet {
            self.photoView.file = gram["media"] as? PFFile
            self.photoView.loadInBackground()
            
            if let user = gram["author"] as? PFUser {
                self.usernameLabel.text = user.username
            }
            
            self.captionLabel.text = gram["caption"] as? String
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let dateString = dateFormatter.stringFromDate(gram.createdAt!)
            
            self.timeStampLabel.text = dateString
            
            user = PFUser.currentUser()!
            if user["profileImage"] != nil {
                loadProfileImage()
            } else {
                profileImageView.image = nil
            }
        }
    }
    
    func loadProfileImage() {
        profileImageView.file = user["profileImage"] as? PFFile
        profileImageView.loadInBackground()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButtonClicked(sender: AnyObject) {
        var numLikes = gram["likes"] as! Int
        numLikes = numLikes + 1
        gram["likes"] = numLikes
        
        gram.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("liked!")
            } else {
                print(error?.localizedDescription)
            }
        }
        
        likeLabel.text = numLikes as! String
    }
}
