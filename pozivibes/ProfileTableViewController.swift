//
//  ProfileViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/10/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController,RateDelegate {
    var profile:Profile?
    var isNew:Bool?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var overallRatingLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var review1Label: UILabel!
    @IBOutlet weak var review2Label: UILabel!
    @IBOutlet weak var review3Label: UILabel!
    @IBOutlet weak var review4Label: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var rating1Control:AMRatingControl?
    var rating2Control:AMRatingControl?
    var rating3Control:AMRatingControl?
    var rating4Control:AMRatingControl?
    
    var reviewArray = [Review]()
    
    //Mark - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 126.0
        self.tableView.registerNib(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewTableViewCell")
        
        
        //if only id shows
        if let profile = self.profile{
            self.setUpView()
            
            self.getFullRatings()

            
        }else{
            //If only Id shows
        }
        
    }
    
    
    func getFullRatings(){
        if let profile = self.profile{
            Review.getFullReviewsWithOffset(reviewArray.count, profileId: profile.id!, handler: { (error, reviewsArray) -> Void in
                
                if let error = error{
                    print("print error here")
                }else{
                    if let reviews = reviewsArray{
                        self.reviewArray = reviews
                        self.tableView.reloadData()
                    }
                }
                
                
            })
        }
    }
    
    func setupRatingControls(){
    
        
//        rating1Control = AMRatingControl(location: CGPointMake(30, self.review1Label.center.y), andMaxRating: 5)
//        rating1Control!.frame = CGRectMake(self.review1Label.frame.origin.x + self.review1Label.frame.size.width+10,self.review1Label.frame.origin.y,(5 * 10),10)
//        rating1Control!.starSpacing=10
//        rating1Control!.userInteractionEnabled=false;
//        self.headerView.addSubview(rating1Control!)
//        
//        rating2Control = AMRatingControl(location: CGPointMake(30, self.review2Label.center.y), andMaxRating: 5)
//        rating2Control!.frame = CGRectMake(self.review2Label.frame.origin.x + self.review2Label.frame.size.width+10,self.review2Label.frame.origin.y,(5 * 10),10)
//        rating2Control!.starSpacing=10
//        rating2Control!.userInteractionEnabled=false;
//        self.headerView.addSubview(rating2Control!)
//        
//        rating3Control = AMRatingControl(location: CGPointMake(30, self.review3Label.center.y), andMaxRating: 5)
//        rating3Control!.frame = CGRectMake(self.review3Label.frame.origin.x + self.review3Label.frame.size.width+10,self.review3Label.frame.origin.y,(5 * 10),10)
//        rating3Control!.starSpacing=10
//        rating3Control!.userInteractionEnabled=false;
//        self.headerView.addSubview(rating3Control!)
//        
//        rating4Control = AMRatingControl(location: CGPointMake(30, self.review4Label.center.y), andMaxRating: 5)
//        rating4Control!.frame = CGRectMake(self.review4Label.frame.origin.x + self.review4Label.frame.size.width+10,self.review4Label.frame.origin.y,(5 * 10),10)
//        rating4Control!.starSpacing=10
//        rating4Control!.userInteractionEnabled=false;
//        self.headerView.addSubview(rating4Control!)
        
    }
    
    func setUpReviews(){
//        rating1Control!.rating=Int(profile!.r1)
//        rating2Control!.rating=Int(profile!.r2)
//        rating3Control!.rating=Int(profile!.r3)
//        rating4Control!.rating=Int(profile!.r4)
        
    }
    
    func setUpView(){
        if let profile = self.profile{
            
            profile.retrieveProfileImageWithCompletionHandler({ (error, image, key) -> Void in
                
                if let image = image{
                    self.profileImageView.image = image
                }
                
                }, key: nil)
            
            
            self.nameLabel.text = profile.name
            self.nameLabel.hidden = false;
            
            if(profile.type == Profile.ProfileType.Instructor){
                
                review1Label.text = "Instructor Vibes"
                review2Label.text = "Intensity"
                review3Label.text = "Music"
                review4Label.text = "Hotness"
                
            }else if(profile.type == Profile.ProfileType.Studio){
                
                review1Label.text = "Equipment Options"
                review2Label.text = "Class Quality"
                review3Label.text = "Cleanliness"
                review4Label.text = "Crowd Vibes"
                
            }

            self.overallRatingLabel.text = self.outputTotalReview(profile)
            self.overallRatingLabel.hidden = false;
            self.loadingIndicator.stopAnimating()
            
            self.setUpReviews()

            profile.getReviewFromProfile({ (error) -> Void in
                
                if let error = error{
                    print("print error here \(error)");
                }
                
                self.setupRatingControls()
                
                self.overallRatingLabel.text = self.outputTotalReview(profile)
                self.overallRatingLabel.hidden = false;
                self.loadingIndicator.stopAnimating()

                
            })
            
        }
    }
    func outputTotalReview(profile:Profile)->String{
        if (Int(profile.r1) == 0 && Int(profile.r2) == 0 && Int(profile.r3) == 0 && Int(profile.r4) == 0){
            return "No Reviews Yet"
        }else{
            return "\(profile.totalRating)%"
        }
    }
    func displayRateScreen(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("RateViewController") as! RateViewController
        vc.profile = profile
        vc.delegate = self
        self.navigationController?.visibleViewController?.presentViewController(vc, animated: true, completion: nil)
        
    }
    func displaySignupScreen(){
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isFirstTimeUser")
        
        let storyboard = UIStoryboard(name: "Signup", bundle: nil)
        
        let vc = storyboard.instantiateInitialViewController()!
        
        self.navigationController?.visibleViewController?.presentViewController(vc, animated: true, completion: nil)
        
    }
    func doneRating(didAddItem: Bool) {
        reviewArray.removeAll()
        self.getFullRatings()
        if let profile = self.profile{
            profile.getReviewFromProfile({ (error) -> Void in
                
                self.overallRatingLabel.text = self.outputTotalReview(profile)
                self.setUpReviews()
            })
        }
    }
    @IBAction func editBarButtonAction(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
        vc.profile = self.profile
    }
    @IBAction func rateAction(sender: AnyObject) {
        
        if(PPMyUser.isLoggedIn() && PPMyUser.sharedUser != nil){
            self.displayRateScreen()
        }
        else{
            self.displaySignupScreen()
        }
        
    }
    


    //MARK: -TableView

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let review:Review = self.reviewArray[indexPath.row]
        
        let cell:ReviewTableViewCell = tableView.dequeueReusableCellWithIdentifier("ReviewTableViewCell", forIndexPath: indexPath) as! ReviewTableViewCell
        
        cell.tag = indexPath.row
        cell.nameLabel.text = (review.fromUser?.firstName)! + " " + (review.fromUser?.lastName)!
        cell.percentLabel.text = "\(review.totalReview)%"
        
        review.fromUser?.retrieveProfileImageWithCompletionHandler({ (error, image, key) -> Void in
            
            if (key as! Int == cell.tag){
                cell.userImageView.image = image
            }
            
            }, key: cell.tag as Int)
        
        if let message = review.reviewText{
            cell.messageLabel.text = message
        }else{
            cell.messageLabel.text = ""
        }
        
        return cell
        
    }
}
