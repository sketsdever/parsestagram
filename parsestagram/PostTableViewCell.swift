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
    
    weak var handler: GuestProfileHandler?
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var photoView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: PFUser!
    var numLikes: Int!
    
    var gram: PFObject! {
        didSet {
            
            user = gram["author"] as? PFUser
            print("user in view did load: \(user)")
            
            self.photoView.file = gram["media"] as? PFFile
            self.photoView.loadInBackground()
            
            self.usernameLabel.text = user.username
            if user["profileImage"] != nil {
                loadProfileImage()
            }
            
            numLikes = gram["likesCount"] as! Int
            likeLabel.text = "\(numLikes)"
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
        numLikes = numLikes + 1
        gram["likesCount"] = numLikes
        
        gram.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("liked!")
            } else {
                print(error?.localizedDescription)
            }
        }
        
        likeLabel.text = "\(numLikes)"
    }
    
    
    @IBAction func tappedUsername(sender: AnyObject) {
        handler?.goToProfile(user)
    }
}
