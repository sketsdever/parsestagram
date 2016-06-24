//
//  SettingsViewController.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/22/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var user: PFUser!
    var profile: UIImage?
    @IBOutlet weak var profileImageView: PFImageView!

    @IBOutlet weak var updateProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo_small")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        if user["profileImage"] != nil {
            loadProfileImage()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func loadProfileImage() {
        profileImageView.file = user["profileImage"] as? PFFile
        profileImageView.loadInBackground()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogOut(sender: AnyObject) {
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
