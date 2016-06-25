
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
import MBProgressHUD

class DetailViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var photoView: PFImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var post: PFObject!
    var user: PFUser!
    var numLikes: Int!
    
    var comments: [PFObject] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo_small")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        photoView.file = post["media"] as? PFFile
        photoView.loadInBackground()
        
        user = post["author"] as? PFUser
        
        if user["profileImage"] != nil {
            loadProfileImage()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        captionLabel.text = post["caption"] as? String
        usernameLabel.text = user.username
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let dateString = dateFormatter.stringFromDate(post.createdAt!)
        
        timeStampLabel.text = dateString
        
        if user["profileImage"] != nil {
            loadProfileImage()
        }
        
        numLikes = post["likesCount"] as! Int
        likeLabel.text = "\(numLikes)"
        
        loadComments()
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(DetailViewController.loadComments), userInfo: nil, repeats: true)
        
        self.tableView.reloadData()
    }
    
    func loadComments() {
        print("loading comments")
        let query = PFQuery(className: "Comment")
        //query.orderByDescending("createdAt")
        query.includeKey("post")
        query.whereKey("post", equalTo: post)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("no error")
                if let objects = objects {
                    print("success")
                    self.comments = objects
                    print("count: \(self.comments.count)")
                    self.tableView.reloadData()
                }
            } else {
                print(error?.localizedDescription)
            }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /*if segue.identifier == "DetailToProfileSegue" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            
            profileViewController.comingFromSegue = true
            profileViewController.user = self.user
        }*/
        
        if segue.identifier == "DetailToGuestProfileSegue" {
            let guestProfileViewController = segue.destinationViewController as! GuestProfileViewController
            
            guestProfileViewController.user = self.user
        }
    }

    @IBAction func commentClicked(sender: AnyObject) {
        //MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        print("commenting!")
        let comment = PFObject(className: "Comment")
        comment["text"] = self.commentTextField.text
        comment["author"] = PFUser.currentUser()
        comment["post"] = post
        comment.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("new comment saved")
                self.commentTextField.text = ""
                //MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.loadComments()
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    @IBAction func likeClicked(sender: AnyObject) {
        
        numLikes = numLikes + 1
        post["likesCount"] = numLikes
        
        post.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("liked!")
            } else {
                print(error?.localizedDescription)
            }
        }
        
        likeLabel.text = "\(numLikes)"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("comments.count: \(comments.count)")
        return comments.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("updating cell")
        
        let comment = comments[indexPath.row]
        if comment["text"] == nil {
            print("sad")
        } else {
            print("text: \(comment["text"])")
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        
        cell.commentLabel.text = comment["text"] as? String
        
        /*var author: PFUser!
        author = post["author"] as? PFUser
        print("\(author)")
        if author["profileImage"] != nil {
            print("yay")
            cell.profileImageView.file = author["profileImage"] as? PFFile
            cell.profileImageView.loadInBackground()
        }*/
        
        return cell
    }
}
