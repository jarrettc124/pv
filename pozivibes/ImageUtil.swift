//
//  ImageUtil.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/2/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import Foundation

extension UIImage{
    
    class func imageWithImage(image:UIImage,newSize:CGSize)->UIImage{
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
}