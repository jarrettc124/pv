//
//  ImageUploader.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/28/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import Foundation

class ImageUploader{
    
    //Mark : properties
    static let appName = "vibes"
    
    //Mark : Functions
    class func uploadImage(image:UIImage, handler:(error:NSError?,imageurl:String?)->Void){
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectory = paths[0] as NSString
        let path = documentDirectory.stringByAppendingPathComponent(".jpg")
        let data = UIImageJPEGRepresentation(image, 1)
        data!.writeToFile(path, atomically: true)
        
        let cloudinary = CLCloudinary(url: NetworkUtil.cloudinary_url)
        let uploader = CLUploader(cloudinary, delegate: nil)
     
        uploader.upload(path, options: ["folder":appName], withCompletion: { (successResult, errorResult, code, context) -> Void in
            
            if(successResult != nil){
                
                guard let imageUrl = successResult["secure_url"] as? String else {
                    dispatch_async(dispatch_get_main_queue()) {

                        handler(error: nil,imageurl: nil)

                    }
                    return
                }
                
                SDImageCache.sharedImageCache().storeImage(image, forKey: imageUrl)
                dispatch_async(dispatch_get_main_queue()) {

                    handler(error: nil,imageurl: imageUrl)
                }
                
            }else{
                dispatch_async(dispatch_get_main_queue()) {

                    let error = NSError(domain: "image-upload", code: 600 , userInfo: nil)
                    
                    handler(error: error,imageurl: nil)
                }
            }
            
            
            }, andProgress: { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite, context) -> Void in
                
        })
        
        
    }
    
}