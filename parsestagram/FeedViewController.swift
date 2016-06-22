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

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var posts: [PFObject] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    //var isMoreDataLoading = false
    //var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        /*
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        */
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
        
    
    func loadData() {
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                print("successfully retrieved things")
                
                if let objects = objects {
                    //self.isMoreDataLoading = false
                    self.posts = objects
                    //self.loadingMoreView!.stopAnimating()
                    //self.tableView.reloadData()
                }
            } else {
                print(error?.localizedDescription)
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        
        let post = posts[indexPath.row]
        //cell.captionLabel.text = post["caption"] as? String
        cell.gram = post
        
        print("returning cell: \(post["caption"])")
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    /*
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the position of one screen length before the bottom of the results
        let scrollViewContentHeight = tableView.contentSize.height
        let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
            isMoreDataLoading = true
            
            // Update position of loadingMoreView, and start loading indicator
            let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView!.startAnimating()
            
            loadData()
        }
    }*/
    
    
    /*let photo = post["media"] as! PFFile
     photo.getDataInBackgroundWithBlock { (result: NSData, error: NSError) -> Void in
     if error == nil {
     let photo = UIImage(data: result)
     cell.photoView.image = photo
     } else {
     print(error.localizedDescription)
     }
     }*/
    
    /*photo.getDataInBackgroundWithBlock {
     (photoData: NSData!, error: NSError!) -> Void in
     if !error {
     let photo = UIImage(data: photoData)
     cell.photoView.image = photo
     }
     }*/
    //cell.photoView.image = photo
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let post = posts[indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        
        detailViewController.post = post
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
