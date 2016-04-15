//
//  LoginViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 1/28/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    //Mark: Properties
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginWithFBButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Mark: -Function
    @IBAction func loginButtonAction(sender: UIButton) {
        self.signIn()
        
    }
    
    
    
    func validateTextfieldInput()->Bool{
        let tfArray = [self.emailTextfield,self.passwordTextfield]
        
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
    
    func signIn(){
        self.loginButton.enabled=false
        
        self.activityIndicator.startAnimating()
        
        if(self.validateTextfieldInput() == true){
            
            let emailParam = self.emailTextfield.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
            let passwordParam = self.passwordTextfield.text
            
            PPMyUser.emailLoginMethod(emailParam!, password: passwordParam!, handler: { (error, sharedUser) -> Void in
                
                self.activityIndicator.stopAnimating()
                self.loginButton.enabled=true

                if let error = error{
                    print("Print error here")
                }else{
                    
                    print("shared \(PPMyUser.sharedUser?.email)")
                    
                    self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                }
                
            })
            
        }else{
            self.activityIndicator.stopAnimating()
            self.loginButton.enabled=true
        }
        
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
