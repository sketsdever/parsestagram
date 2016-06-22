
//
//  DetailViewController.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/21/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class DetailViewController: UIViewController {

    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var photoView: PFImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var post: PFObject!
    
    var user: PFUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoView.file = post["media"] as? PFFile
        photoView.loadInBackground()
        
        if let user = post["author"] as? PFUser {
            usernameLabel.text = user.username
        }
        
        captionLabel.text = post["caption"] as? String
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.stringFromDate(post.createdAt!)
        
        timeStampLabel.text = dateString
        
        user = PFUser.currentUser()!
        if user["profileImage"] != nil {
            loadProfileImage()
        } else {
            profileImageView.image = nil
        }
    }
    
    func loadProfileImage() {
        profileImageView.file = user["profileImage"] as? PFFile
        profileImageView.loadInBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
