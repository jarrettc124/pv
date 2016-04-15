//
//  PPMyUser.swift
//  pozivibes
//
//  Created by Jarrett Chen on 12/30/15.
//  Copyright © 2015 pozivibes. All rights reserved.
//

import UIKit
import CoreData

class PPMyUser: User {
    
    //Mark -Properties
    
    static var sharedUser:PPMyUser?
    var universalToken:String?
    var facebookToken:String?
    class var currentType:Profile.ProfileType{
        set{
            
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "currentType")
            
        }
        get{
            
            let type = NSUserDefaults.standardUserDefaults().integerForKey("currentType")
            return Profile.ProfileType(rawValue: type)!

        }
    }
    
    var deviceToken:String?{
        didSet{
            print("did set token")
        }
    }
    
    
    //Mark -Functions
    func recordTokens(){
        
        NSUserDefaults.standardUserDefaults().setObject(self.universalToken!, forKey: "universalToken")
        
        if let facebookToken = self.facebookToken{
            NSUserDefaults.standardUserDefaults().setObject(facebookToken, forKey: "facebookToken")
        }else{
            NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookToken")
        }
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    func refreshDataCoreFromInternet(){
        
        if let jsonparam = PPMyUser.universalTokenInfo(){
            NetworkUtil.postToRoute("user/", params: nil, json: jsonparam) { (error, result) -> Void in
                
                if (error == nil){
                    return
                }
                
                
                if let params:Dictionary<String,AnyObject> = result as? Dictionary<String,AnyObject>{
                    self.configureWithParams(params)
                    self.syncDataCore()
                }
                
            }
        }
        
    }
    func syncDataCore(){
        
        if let token = self.universalToken{
            let context = PPMyUser.managedObjectContext()
            let request:NSFetchRequest = NSFetchRequest(entityName: "UserObject")
            
            do{
                let result = try context.executeFetchRequest(request)
                let foundUser:[NSManagedObject] = result as! [NSManagedObject]
                var currentUser:NSManagedObject?
            
                if(foundUser.count>1){
                    
                    let errorRequest = NSFetchRequest(entityName: "UserObject")
                    let errorUserArray = try context.executeFetchRequest(errorRequest) as! [NSManagedObject]
                    for deleteUser:NSManagedObject in errorUserArray{
                        context.deleteObject(deleteUser)
                    }
                    //Delete all users and create a new one
                    print("Delete all users and create a new one")

                    currentUser = NSEntityDescription.insertNewObjectForEntityForName("UserObject", inManagedObjectContext: context)
                    
                }else if(foundUser.count == 1){
                    print("Found DATA core")

                    currentUser = foundUser.first!
                }else if(foundUser.isEmpty){
                    print("Create the new user for data core")
                    currentUser = NSEntityDescription.insertNewObjectForEntityForName("UserObject", inManagedObjectContext: context)
                }
                
                currentUser?.setValue(self.userId, forKey: "userId")
                currentUser?.setValue(self.firstName, forKey: "firstName")
                currentUser?.setValue(self.lastName, forKey: "lastName")
                currentUser?.setValue(self.email, forKey: "email")
                currentUser?.setValue(self.imageUrl, forKey: "imageUrl")
                currentUser?.setValue(self.universalToken, forKey: "universalToken")
                
                do{
                   try context.save()
                }catch{
                    
                }
                
                self.recordTokens()
            }catch{
                print("ERROR FOUND in MANAGED CONTEXT PPUSER")
            }
            
        }
        
    }
    func configureWithParams(userParam:Dictionary<String,AnyObject>){
    
        print("param: \(userParam)")
        
        self.userId = userParam["_id"] as? String
        self.firstName = userParam["firstName"] as? String
        self.lastName = userParam["lastName"] as? String
        self.email = userParam["email"] as? String
        self.imageUrl = userParam["imageUrl"] as? String
        self.universalToken = userParam["universalToken"] as? String
        self.displayName = "\((self.firstName)!) \((self.lastName)!)"
        
        PPMyUser.addPushNotification()
        
    }
    
    //Mark -Class Functions
    class func loadMyUserFromCoreWithAccessToken(token:String, completionHandler:(NSError?,PPMyUser?)->Void){
        
        let context = PPMyUser.managedObjectContext()
        let request:NSFetchRequest = NSFetchRequest(entityName: "UserObject")
        
        let foundUser:[NSManagedObject]
        
        do{
            let result = try context.executeFetchRequest(request)
            foundUser = result as! [NSManagedObject]
            
            if(foundUser.count>1){
                
                let errorRequest = NSFetchRequest(entityName: "UserObject")
                let errorUserArray = try context.executeFetchRequest(errorRequest) as! [NSManagedObject]
                for deleteUser:NSManagedObject in errorUserArray{
                    context.deleteObject(deleteUser)
                }
                PPMyUser.clearAllTokens()
                completionHandler(nil,nil)
                
            }else if(foundUser.count == 1){
                let currentUser = foundUser.first!
                if let savedToken = currentUser.valueForKey("universalToken") as? String{
                    if savedToken == token{
                        print("found user from core data")
                        sharedUser = PPMyUser()
                        sharedUser!.userId = currentUser.valueForKey("userId") as? String
                        sharedUser!.firstName = currentUser.valueForKey("firstName") as? String
                        sharedUser!.lastName = currentUser.valueForKey("lastName") as? String
                        sharedUser!.universalToken = currentUser.valueForKey("universalToken") as? String
                        sharedUser!.imageUrl = currentUser.valueForKey("imageUrl") as? String
                        sharedUser!.displayName = "\((sharedUser!.firstName)!) \((sharedUser!.lastName)!)"
                        completionHandler(nil,sharedUser)
                    }else{
                        PPMyUser.clearAllTokens()
                        completionHandler(nil,nil)
                    }
                }else{
                    PPMyUser.clearAllTokens()
                    completionHandler(nil,nil)
                }
            }else{
                PPMyUser.clearAllTokens()
                completionHandler(nil,nil)
            }
            
        }catch{
            print("ERROR FOUND in MANAGED CONTEXT PPUSER")
            completionHandler(nil,nil)
        }
        
    }
    class func clearAllTokens(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("universalToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
    }
    class func fbLoginWithCompletionHander(handler:(NSError?,PPMyUser?)->Void){
        
    }

    class func managedObjectContext()->NSManagedObjectContext{
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var context:NSManagedObjectContext? = nil
    
        if((delegate.performSelector("managedObjectContext")) != nil){
           context = delegate.managedObjectContext
        }
        
        return context!
    }
    class func universalTokenInfo()->[String:AnyObject]? {
        if let universalToken = NSUserDefaults.standardUserDefaults().objectForKey("universalToken") as? String{
            
            return ["auth_token":universalToken]
            
        }else{
            return nil
        }
    }
    class func addPushNotification(){

    }
    class func createSharedUserWithParams(userParams:Dictionary<String,AnyObject>){
        PPMyUser.sharedUser=nil
        PPMyUser.sharedUser = PPMyUser()
        PPMyUser.sharedUser?.configureWithParams(userParams)
        
        print("shared user email: \(PPMyUser.sharedUser?.email)")
        
        PPMyUser.sharedUser?.syncDataCore()
    }
    
    class func emailLoginMethod(email:String,password:String,handler:(NSError?,PPMyUser?)->Void){
        
        let hashPassword = self.hashPassword(password)
        let loginParams = ["email":email,"password":hashPassword]
        NetworkUtil.postToRoute("user/emaillogin", params: nil, json: loginParams) { (error, result) -> Void in

            if let loginResult = result{
            
            PPMyUser.sharedUser = nil
            
                if let params = loginResult["user"] as? Dictionary<String,AnyObject>{
                    
                    print("USER: \(params)")
                    
                    PPMyUser.createSharedUserWithParams(params)
                }
            
            }
            handler(error,PPMyUser.sharedUser)
        }
    }
    
    class func isLoggedIn()->Bool {
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("universalToken") != nil){
            return true
        }else{
            return false
        }
        
    }
    class func hashPassword(password:String)->String{
        let s = password.cStringUsingEncoding(NSASCIIStringEncoding)
        let length:Int = Int(strlen(s!))
        let keyData = NSData(bytes:s!, length: length)
        var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
        
        
        CC_SHA256(keyData.bytes, CC_LONG(keyData.length), &hash)
        
        let out1 = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
        
        var hashStr:String = out1.description
        hashStr = hashStr.stringByReplacingOccurrencesOfString(" ", withString:"")
        hashStr = hashStr.stringByReplacingOccurrencesOfString("<", withString:"")
        hashStr = hashStr.stringByReplacingOccurrencesOfString(">", withString:"")
    
        return hashStr
        
    }
    class func logout()->Void{
        
        if let sharedUser = PPMyUser.sharedUser{
            sharedUser.deviceToken = nil
            PPMyUser.clearAllTokens()
            PPMyUser.sharedUser = nil
        }
        
        
    }
    
}
