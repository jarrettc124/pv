//
//  SignupViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 1/28/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLUploaderDelegate {

    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var imageButton: UIButton!
    
    
    
    var avatarImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //Mark - UIImagePickerController Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let scaledHeight = 300.0*(chosenImage!.size.height/chosenImage!.size.width)
        self.avatarImage = UIImage.imageWithImage(chosenImage!, newSize: CGSizeMake(300, scaledHeight))
        self.imageButton.setImage(self.avatarImage, forState: UIControlState.Normal)
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
        }
        
    }
    @IBAction func imageButtonAction(sender: AnyObject) {
        
        
        let photoActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.takePhoto()
        }
        let selectPhotoAction = UIAlertAction(title: "Choose Existing", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.selectPhoto()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
        }
        photoActionSheet.addAction(takePhotoAction)
        photoActionSheet.addAction(selectPhotoAction)
        photoActionSheet.addAction(cancelAction)
        
        self.presentViewController(photoActionSheet, animated: true, completion: nil)
        
        
    }
    func takePhoto(){
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            let picker = UIImagePickerController()
            picker.delegate=self
            picker.allowsEditing=true
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }else{
            print("No Camera Available")
        }
    }
    func selectPhoto(){
        let picker = UIImagePickerController()
        picker.delegate=self
        picker.allowsEditing=true
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(picker, animated: true, completion: nil)
    }

    //Mark: - Functions
    func validateTextfieldInput()->Bool{
        let tfArray = [self.firstNameTextfield,self.lastNameTextfield,self.emailTextfield,self.passwordTextfield]
        
        var isEmpty = false
        
        for tf:UITextField in tfArray{
            let str:String! = tf.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            if(str.isEmpty == true){
                isEmpty = true
                tf.layer.borderColor = UIColor.redColor().CGColor
            }else{
                tf.layer.borderColor = UIColor.whiteColor().CGColor
            }
            
        }
        
        if(isEmpty == true){
            let alert = UIAlertController(title: "You need to complete all fields.", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        
        return true
        
    }
    
    @IBAction func nextBarButtonAction(sender: UIBarButtonItem) {
        
        self.completeProfile()
        
    }
    
    func completeProfile(){
        self.nextButton.enabled=false
        self.hideKeyboard()
        
        if(self.validateTextfieldInput() == true){
            
            let loadingView = UINib(nibName: "LoadingView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
            
            loadingView.frame = self.navigationController!.view.frame
            
            self.navigationController!.view.addSubview(loadingView)
            
            self.uploadImageWithHandler({ (error, imageUrl) -> Void in
                if let error = error{
                    self.nextButton.enabled=true;
                    loadingView.removeFromSuperview()
                    
                    print("errrrror: \(error.userInfo)")
                
                }else{
                    var userParam = [String:AnyObject]()
                    userParam["firstName"] = self.firstNameTextfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).capitalizedString
                    userParam["lastName"] = self.lastNameTextfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).capitalizedString
                    userParam["email"] = self.emailTextfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
                    userParam["password"] = PPMyUser.hashPassword((self.passwordTextfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))!)
                    
                    if let url = imageUrl{
                        userParam["imageUrl"] = url
                    }
                    
                    NetworkUtil.postToRoute("user/signup", params: nil, json: userParam, completionHandler: { (error, result) -> Void in
                        self.nextButton.enabled=true;
                        loadingView.removeFromSuperview()
                        if let error = error{
                            
                            var alertMessage:String? = nil;
                            
                            if (error.code == NetworkUtil.NETWORK_NO_INTERNET){
                                alertMessage = "Can't find network"
                            }else{
                                alertMessage = error.userInfo[NetworkUtil.NetworkErrorMessageKey] as! String
                            }
                            let alert = UIAlertController(title: "Try Again", message:alertMessage, preferredStyle: .Alert)
                            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alert.addAction(alertAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        }else{
                            if let resultParams = result as? Dictionary<String,AnyObject>{
                                    if let param = resultParams["user"] as? Dictionary<String,AnyObject>{

                                        PPMyUser.createSharedUserWithParams(param)
                                    
                                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                                    }
                                
                            }else{
                                print("Print Error here")
                                
                                self.nextButton.enabled=true;
                                loadingView.removeFromSuperview()
                            }
                        }

                    })
                    
                }
            })
            
        }else{
            self.nextButton.enabled=true
        }
        
    }
    
    func uploadImageWithHandler(handler:(NSError?,String?)->Void){
        if let image = self.avatarImage{
            ImageUploader.uploadImage(image, handler: { (error, imageurl) -> Void in
                handler(error,imageurl)
            })
        }else{

            handler(nil,nil)
        }
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
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
