//
//  RateViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/4/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

protocol RateDelegate {
    func doneRating(didAddItem: Bool)
}

class RateViewController: UIViewController {
    
    //Mark: - Properties

    var rating1Control:AMRatingControl?
    var rating2Control:AMRatingControl?
    var rating3Control:AMRatingControl?
    var rating4Control:AMRatingControl?
    
    @IBOutlet weak var classNameTextfield: UITextField!
    @IBOutlet weak var reviewTextview: UITextView!
    

    var profile:Profile?

    
    var delegate:RateDelegate?
    
    @IBOutlet weak var review1Label: UILabel!
    @IBOutlet weak var review2Label: UILabel!
    @IBOutlet weak var review3Label: UILabel!
    @IBOutlet weak var review4Label: UILabel!
    @IBOutlet weak var scroller: UIView!
    
    //Mark: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
        self.setupRatingControls()
    }
    
    @IBAction func postButtonAction(sender: AnyObject) {
        if(self.validateInput()){
            
            let review = Review()
            review.type=self.profile?.type
            review.profileId = self.profile?.id
            review.className = self.classNameTextfield.text
            review.reviewText = self.reviewTextview.text
            
            review.r1 = rating1Control!.rating
            review.r2 = rating2Control!.rating
            review.r3 = rating3Control!.rating
            review.r4 = rating4Control!.rating
            
            review.postReviewWithHandler({ (error, review) -> Void in
                
                if let err = error{
                    print("print error here")
                }else{
                    if let delegate = self.delegate{
                        delegate.doneRating(true)
                    }
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
            
        }
    }
    
    func setupRatingControls(){

        rating1Control = AMRatingControl(location: CGPointMake(30,self.review1Label.center.y+20), andMaxRating: 5)
        rating1Control!.rating=0
        rating1Control!.starSpacing=10
        self.scroller.addSubview(rating1Control!)
        
        rating2Control = AMRatingControl(location: CGPointMake(30,self.review2Label.center.y+20), andMaxRating: 5)
        rating2Control!.rating=0
        rating2Control!.starSpacing=10
        self.scroller.addSubview(rating2Control!)
        
        rating3Control = AMRatingControl(location: CGPointMake(30,self.review3Label.center.y+20), andMaxRating: 5)
        rating3Control!.rating=0
        rating3Control!.starSpacing=10
        self.scroller.addSubview(rating3Control!)
        
        rating4Control = AMRatingControl(location: CGPointMake(30,self.review4Label.center.y+20), andMaxRating: 5)
        rating4Control!.rating=0
        rating4Control!.starSpacing=10
        self.scroller.addSubview(rating4Control!)
        
    }
    
    func validateInput()->Bool{
        
        if(rating1Control?.rating == 0 && rating2Control?.rating == 0 && rating3Control?.rating == 0 && rating4Control?.rating == 0){
            
            let alert = UIAlertController(title: "Choose at least one rating", message: nil, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    func setupView(){
        
        if let rateType = self.profile?.type{
            
            if(rateType == Profile.ProfileType.Instructor){
                
                review1Label.text = "Instructor Vibes"
                review2Label.text = "Intensity"
                review3Label.text = "Music"
                review4Label.text = "Hotness"
                
            }else if(rateType == Profile.ProfileType.Studio){
                
                review1Label.text = "Equipment Options"
                review2Label.text = "Class Quality"
                review3Label.text = "Cleanliness"
                review4Label.text = "Crowd Vibes"
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
