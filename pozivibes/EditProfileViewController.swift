//
//  EditProfileViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 1/31/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UIGestureRecognizerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLUploaderDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
    
    // MARK: - Properties
    
    var profile:Profile?
    var addressComponents:Dictionary<String,String>?
    var placemark:CLPlacemark?
    var avatarImage:UIImage?
    var typePicker:UIPickerView!
    var type:Profile.ProfileType?
    
    
    @IBOutlet weak var typeSegmented: UISegmentedControl!
    @IBOutlet weak var avatarButton: UIButton!
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var categoryTextfield: UITextField!

    
    @IBOutlet weak var addressButton: UIButton!
    
    var pickerArray:[String]?
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if(self.profile == nil){
            self.profile = Profile()
        }
        
        self.pickerArray = ["Barre","Boxing","Conditioning","Crossfit","Cycling","Dance","Martial Arts","Personal Training","Pilates","Yoga"]
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        gestureRecognizer.delegate=self
        self.view.addGestureRecognizer(gestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveLocation:", name: "UnwindPreviousState", object: nil)
        
        self.setupTypePicker()
        self.setupView()
    }
    
    func setupPreviousEdit(){
        
        if let profile = self.profile{
            
            self.profile?.name = self.nameTextfield.text
            self.profile?.category = self.categoryTextfield.text
            self.profile?.type = self.type
            self.profile?.location = self.placemark?.location?.coordinate
            self.profile?.address = self.addressComponents
            
            
        }
    }
    
    func setupView(){
        if let type = self.type{
            if (type == Profile.ProfileType.Instructor){
                self.typeSegmented.selectedSegmentIndex = 0
            }else if (type == Profile.ProfileType.Studio){
                self.typeSegmented.selectedSegmentIndex = 1
            }
        }
        
    }
    
    func setupTypePicker(){
        
        self.typePicker = UIPickerView()
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: #selector(EditProfileViewController.donePickerAction))
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height-self.typePicker.frame.size.height-44, self.view.frame.size.width, 44))
        toolBar.setItems([doneButton], animated: false)
        
        self.categoryTextfield.inputView = self.typePicker
        self.categoryTextfield.inputAccessoryView = toolBar
    }
    
    func didReceiveLocation(notification:NSNotification){
        
        self.placemark = notification.userInfo!["placemark"] as? CLPlacemark
        self.addressComponents = notification.userInfo!["address"] as? [String:String]
        
        var fullAddress:String = ""
        
        for addressComp:String in (self.placemark?.addressDictionary!["FormattedAddressLines"] as! [String]){
            
            fullAddress += (addressComp+"\n")
            
        }
        
        self.addressButton.setTitle(fullAddress, forState: UIControlState.Normal)

    }
    
    @IBAction func segueToAddAction(sender: AnyObject) {
        
        self.performSegueWithIdentifier("segueAdd", sender: self)
        
    }
    
    
    @IBAction func nextButtonAction(sender: UIButton) {
        sender.enabled = false;

        if(self.validateInput()){
            self.uploadImageWithHandler { (error, imageUrl) -> Void in
                
                if let error = error{
                    sender.enabled = true;
                    print("print error here")
                    return
                }
                
                if let imageUrl = imageUrl{
                    self.profile?.imageUrl = imageUrl
                }
                
                self.profile?.name = self.nameTextfield.text
                self.profile?.category = self.categoryTextfield.text
                self.profile?.type = Profile.ProfileType(rawValue: self.typeSegmented.selectedSegmentIndex)
                self.profile?.location = self.placemark?.location?.coordinate
                self.profile?.address = self.addressComponents
                self.profile?.postProfileWithHandler({ (error, profile) -> Void in
                    sender.enabled = true;

                    if let error = error{
                        
                        print("print error here")
                    }else{
                        self.profile = profile
                        let firstVC = self.navigationController?.viewControllers.first as! SearchViewController

                        self.navigationController?.popToRootViewControllerAnimated(false)
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        
                        let vc = storyboard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as! ProfileTableViewController
                        vc.profile = profile
                        firstVC.navigationController?.pushViewController(vc, animated: true)


                    }
                    
                })
                
            }
        }else{
            sender.enabled = true;
        }
    }
    @IBAction func imageSelectAction(sender: UIButton) {
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
    
    //Mark - UIImagePickerController Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let scaledHeight = 200.0*(chosenImage!.size.height/chosenImage!.size.width)
        self.avatarImage = UIImage.imageWithImage(chosenImage!, newSize: CGSizeMake(200, scaledHeight))
        self.avatarButton.setImage(self.avatarImage, forState: UIControlState.Normal)
        picker.dismissViewControllerAnimated(true) { () -> Void in

        }
        
    }
    func uploadImageWithHandler(handler:(NSError?,String?)->Void){
        if let chosenImage = self.avatarImage{
            ImageUploader.uploadImage(chosenImage, handler: { (error, imageurl) -> Void in
                handler(error,imageurl)
            })
        }
        else{
            handler(nil,nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        self.registerForKeyboardNotification()
    }
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
//    func registerForKeyboardNotification(){
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
//    }
//    func unRegisterForKeyboardNotification(){
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//        
//    }

    

    //MARK: - Textfield Delegate
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "GetLocationSegue"){
            let locationVC = segue.destinationViewController as! LocationViewController
            locationVC.placemark=self.placemark
        }else if(segue.identifier == "newProfileSegue"){
            let profileVC = segue.destinationViewController as! ProfileTableViewController
            profileVC.profile = self.profile
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    //Mark: UIPicker 
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (self.pickerArray?.count)!
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerArray![row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.categoryTextfield.text = self.pickerArray![row]

    }
    func donePickerAction(){
        self.typePicker.removeFromSuperview()
        self.categoryTextfield.resignFirstResponder()
    }
    
    func validateInput()->Bool{
        
        var isEmpty = true
        
        if let _ = self.placemark, _ = self.type{
            isEmpty = false
        }
        
        let str:String! = self.nameTextfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if(str.isEmpty == true){
            isEmpty = true
        }
        
        if(isEmpty == true){
            let alert = UIAlertController(title: "You need to fill out at least the Name and Address", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let defaultAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            })
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    
    
}
