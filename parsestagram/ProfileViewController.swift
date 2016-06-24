//
//  ProfileViewController.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/20/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var profile: UIImage?
    
    var user: PFUser!
    var comingFromSegue = false

    @IBOutlet weak var profileImageView: PFImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [PFObject] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var queryLimit: Int!
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let logo = UIImage(named: "logo_small")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        if !comingFromSegue {
            user = PFUser.currentUser()!
        }
        
        if user["profileImage"] != nil {
            loadProfileImage()
        }
        
        usernameLabel.text = user.username
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        queryLimit = 20
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(FeedViewController.loadData), userInfo: nil, repeats: true)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadData()
        MBProgressHUD.hideHUDForView(self.view, animated: true)
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        collectionView.addSubview(loadingMoreView!)
        var insets = collectionView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        collectionView.contentInset = insets
        
        self.collectionView.reloadData()
    }
    
    func loadProfileImage() {
        profileImageView.file = user["profileImage"] as? PFFile
        profileImageView.loadInBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*@IBAction func onLogOut(sender: AnyObject) {
        print("on log out")
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if let error = error {
                print ("cant log out")
                print(error.localizedDescription)
            } else {
                print("logging out")
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
        }
    }
        
    @IBAction func onUpdateProfileImage(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        profile = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onSetNewProfileImage(sender: AnyObject) {
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        //let user = PFUser.currentUser()!
        user["profileImage"] = getPFFileFromImage(profile)
        //user.saveInBackground()
        user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("profile updated")
                self.loadProfileImage()
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else {
                print(error?.localizedDescription)
            }
        }
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func getPFFileFromImage(image: UIImage?) -> PFFile? {
        // check if image is not nil
        if let image = image {
            // get image data and check if that is not nil
            if let imageData = UIImagePNGRepresentation(image) {
                return PFFile(name: "image.png", data: imageData)
            }
        }
        return nil
    }*/
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // perform network request
        loadData()
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the position of one screen length before the bottom of the results
        let scrollViewContentHeight = collectionView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - collectionView.bounds.size.height
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && collectionView.dragging) {
            isMoreDataLoading = true
            queryLimit = queryLimit + 5
            
            // Update position of loadingMoreView, and start loading indicator
            let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            loadData()
        }
    }
    
    
    func loadData() {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.whereKey("author", equalTo: user)
        if isMoreDataLoading {
            query.limit = queryLimit
        } else {
            query.limit = 5
        }
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("successfully retrieved things")
                
                if let objects = objects {
                    self.isMoreDataLoading = false
                    self.posts = objects
                    
                    // also update the profile image here in case it was changed
                    if self.user["profileImage"] != nil {
                        self.loadProfileImage()
                    }
                    
                    self.loadingMoreView!.stopAnimating()
                    self.collectionView.reloadData()
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfileCollectionViewCell", forIndexPath: indexPath) as! ProfileCollectionViewCell
        
        let post = posts[indexPath.row]
        cell.gram = post
        
        print("returning cell: \(post["caption"])")
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProfileToDetailSegue" {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)
            let post = posts[indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            detailViewController.post = post
        }
        if segue.identifier == "ProfileToSettingsSegue" {
            let settingsViewController = segue.destinationViewController as! SettingsViewController
            settingsViewController.user = user
        }
    }
}
