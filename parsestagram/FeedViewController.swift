//
//  FeedViewController.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/20/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

protocol GuestProfileHandler : class {
    func goToProfile (user : PFUser)
}

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, GuestProfileHandler {

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [PFObject] = [] {
        didSet {
            self.tableView.reloadData()
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
        
        queryLimit = 20
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(FeedViewController.loadData), userInfo: nil, repeats: true)
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadData()
        MBProgressHUD.hideHUDForView(self.view, animated: true)

        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
        let scrollViewContentHeight = tableView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
            isMoreDataLoading = true
            queryLimit = queryLimit + 5
            
            // Update position of loadingMoreView, and start loading indicator
            let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            loadData()
        }
    }
        
    
    func loadData() {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        if isMoreDataLoading {
            query.limit = queryLimit
        } else {
            query.limit = 5
        }
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                
                if let objects = objects {
                    self.isMoreDataLoading = false
                    self.posts = objects
                    self.loadingMoreView!.stopAnimating()
                    self.tableView.reloadData()
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        
        let post = posts[indexPath.row]
        cell.gram = post
        cell.handler = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
        
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FeedToDetailSegue" {
            print("FeedToDetailSegue")
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            let post = posts[indexPath!.row]
            print("\(post)")
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            detailViewController.post = post
        }
        if segue.identifier == "FeedToGuestDetailSegue" {
//            print("FeedToGuestProfileSegue????")
            let guestProfileViewController = segue.destinationViewController as! GuestProfileViewController
//            
//            let cell = sender?.containerView() as! UITableViewCell
//            
//            let indexPath = tableView.indexPathForCell(cell)
//            let post = posts[indexPath!.row]
//            print("post: \(post)")
//            let user = post["author"] as? PFUser
//            print("user: \(user)")
            guestProfileViewController.user = sender as! PFUser
        }
    }
    
    func goToProfile (user : PFUser) {
        self.performSegueWithIdentifier("FeedToGuestDetailSegue", sender: user)
    }
}
