//
//  PostViewController.swift
//  parsestagram
//
//  Created by Shea Ketsdever on 6/20/16.
//  Copyright © 2016 Shea Ketsdever. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var image: UIImage?
    
    @IBOutlet weak var captionField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTakePicture(sender: AnyObject) {
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func onSelectFromCameraRoll(sender: AnyObject) {
        
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        // Get the image captured by the UIImagePickerController
        //let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Do something with the images (based on your use case)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func submitButtonPressed(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let post = PFObject(className: "Post")
        post["caption"] = captionField.text
        post["media"] = getPFFileFromImage(image)
        post["author"] = PFUser.currentUser()
        post["likesCount"] = 0
        post["commentsCount"] = 0
        post.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("new post saved")
                self.captionField.text = ""
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            } else {
                print(error?.localizedDescription)
            }
        }
    }
        /* let caption = captionField.text
        let completion: PFBooleanResultBlock = { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        Post.postUserImage(image, withCaption: caption, withCompletion: completion)
        print("submitted") */

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