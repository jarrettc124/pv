//
//  Review.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/4/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import Foundation

class Review{
    
    var type:Profile.ProfileType?
    var reviewText:String?
    var className:String?
    var profileId:String?
    var beginner:Bool?
    var crowded:Bool?
    var totalReview:Int = 0
    var fromUser:User?
    
    var r1:Int = 0
    var r2:Int = 0
    var r3:Int = 0
    var r4:Int = 0
    

    
    func postReviewWithHandler(handler:(NSError?,Review?)->Void)->Void{
        
        
        if(r1 == 0 && r2 == 0 && r3 == 0 && r4 == 0){
            print("print error here")
            let error = NSError(domain: "post_error", code: 5000, userInfo: ["Error":"adfsdfas"])
            handler(error,nil)
            return
        }
        
        let rParam = ["r1":r1,"r2":r2,"r3":r3,"r4":r4]
        
        var param:Dictionary<String,AnyObject> = ["type":((self.type?.rawValue)! as NSNumber),"reviews":rParam,"profile":profileId!,"userId": (PPMyUser.sharedUser?.userId)!]
        
        param["beginner"] = beginner
        param["crowded"] = crowded
        param["reviewText"] = reviewText
        param["className"] = className

        
        print("param: \(param)");
        
        NetworkUtil.postToRoute("review/rate", params: nil, json: param) { (error, result) -> Void in
            
            guard let result = result as? Dictionary<String,AnyObject>else{
                handler(error,nil)
                return
            }
            
            print("result: \(result)")
            
            let review = Review(dict: (result["review"] as! [String:AnyObject]))
            handler(error,review)
            
        }
        
    }
    
    class func getFullReviewsWithOffset(offset:Int, profileId:String, handler:(NSError?,[Review]?)->Void){
        NetworkUtil.getRoute("review/\(profileId)/\(offset)", params: nil, JSONResultHandler: { (error, result) -> Void in
            if let error = error{
                print("print error here")
                handler(error,nil)
                
            }else{
                
                guard let result = result as? Dictionary<String,AnyObject>else{
                    handler(error,nil)
                    return
                }
                
                if let reviews = result["reviews"] as? [Dictionary<String,AnyObject>]{
                    var reviewsArray = [Review]()
                    for reviewDict in reviews{
                        reviewsArray.append(Review(dict: reviewDict))
                    }
                    handler(error,reviewsArray)
                }else{
                    handler(error,nil)
                }
            }
        })
        
    }
    init(dict:Dictionary<String,AnyObject>){
        self.reviewText = dict["reviewText"] as? String
        self.profileId = dict["profile"] as? String
        self.beginner = dict["beginner"] as? Bool
        self.crowded = dict["crowded"] as? Bool
        self.totalReview = Int((dict["totalReview"] as? Double)! * 100.0)
        if dict["from"] is Dictionary<String,AnyObject>{
            self.fromUser = User(dict: (dict["from"] as? Dictionary<String,AnyObject>)!)
        }
        
        self.r1 = (dict["reviews"] as? [String:Int])!["r1"]!
        self.r2 = (dict["reviews"] as? [String:Int])!["r2"]!
        self.r3 = (dict["reviews"] as? [String:Int])!["r3"]!
        self.r4 = (dict["reviews"] as? [String:Int])!["r4"]!
        
    }
    
    init(){
    }
    
}