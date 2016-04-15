//
//  IntroViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 1/28/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    //Mark: -Properties
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    
    
    @IBAction func cancelBarButtonAction(sender: UIBarButtonItem) {
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
