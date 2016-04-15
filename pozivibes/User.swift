//
//  User.swift
//  pozivibes
//
//  Created by Jarrett Chen on 1/28/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class User {
    //Mark -properties
    var userId:String?
    var firstName:String?
    var lastName:String?
    var email:String?
    var imageUrl:String?
    var displayName:String?
    
    func retrieveProfileImageWithCompletionHandler(handler:(NSError?,UIImage?,AnyObject?)->Void, key:(AnyObject?)){
        
        
        guard let _ = self.userId, imageUrl = self.imageUrl else{
            let placeholderImage:UIImage = UIImage(named: "pf_placeholder")!

            handler(nil,placeholderImage,key)
            return
        }
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imageUrl), options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, error, cacheType, finished, imageURL) -> Void in
            if let err = error{
                
                let placeholderImage:UIImage = UIImage(named: "pf_placeholder")!
               
                
                handler(err,placeholderImage,key)
                return
            }
            
            handler(nil,image,key)
            
        }
        
    }
    
    init(dict:Dictionary<String,AnyObject>){
        self.userId = dict["id"] as? String
        self.firstName = dict["firstName"] as? String
        self.lastName = dict["lastName"] as? String
        self.email = dict["email"] as? String
        self.displayName = "\(self.firstName) \(self.lastName)"
        self.imageUrl = dict["imageUrl"] as? String
    }
    init(){}
}
