//
//  Profile.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/1/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import Foundation

//Instructor Studio

class Profile{
    
    enum ProfileType : Int {
        case Instructor
        case Studio
    }
    
    var id:String?
    var type:ProfileType?
    var profile:Profile?
    var name:String?
    var category:String?
    var location:CLLocationCoordinate2D?
    var address:Dictionary<String,String>?
    var imageUrl:String?
    var distance:Double?
    var totalRating:Int = 0
    var r1:Double = 0.0
    var r2:Double = 0.0
    var r3:Double = 0.0
    var r4:Double = 0.0

    
    func retrieveProfileImageWithCompletionHandler(handler:(NSError?,UIImage?,AnyObject?)->Void, key:(AnyObject?)){
        
        var placeholderImage:UIImage? = nil
        
        if type == ProfileType.Instructor {
            placeholderImage = UIImage(named: "pf_placeholder")!
        }
        else if type == ProfileType.Studio{
            placeholderImage = UIImage(named: "pf_placeholder")!
        }else{
            placeholderImage = UIImage(named: "pf_placeholder")!

        }
        
        
        guard let _ = self.id, imageUrl = self.imageUrl else{
            
            handler(nil,placeholderImage,key)
            return
        }
        
        SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: imageUrl), options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, error, cacheType, finished, imageURL) -> Void in
            if let err = error{
                
                var placeholderImage:UIImage? = nil
                
                if self.type == ProfileType.Instructor {
                    placeholderImage = UIImage(named: "pf_placeholder")!
                }
                else if self.type == ProfileType.Studio{
                    placeholderImage = UIImage(named: "pf_placeholder")!
                }
                
                handler(err,placeholderImage,key)
                return
            }
            
            handler(nil,image,key)
            
        }
        
    }
    
    func postProfileWithHandler(handler:(NSError?,Profile?)->Void)->Void{
        
        guard let location = self.location else{

            return
        }

        let lat:String? = "\((location.latitude))"
        let long:String? = "\((location.longitude))"
        
        var param:Dictionary<String,AnyObject> = ["name":self.name!,"type":((self.type?.rawValue)! as NSNumber),"latitude":lat!,"longitude":long!,"address":self.address!]
        
        if let imageUrl = self.imageUrl{
            param["imageUrl"] = imageUrl
        }
        param["category"] = self.category
        
        print("param: \(param)");
        
        var route:String
        
        //if there is an id edit the post. if no id, create the post
        if self.id != nil{
            route = "profile/edit"
        }else{
            route = "profile/create"
        }
        
        NetworkUtil.postToRoute(route, params: nil, json: param) { (error, result) -> Void in
            
            if let error = error{
                
                handler(error,nil)
                return
            }
            
            guard let result = result as? Dictionary<String,AnyObject>else{
                handler(error,nil)
                return
            }
            
            print("result: \(result)")
            
            let profile = Profile(dict: (result["profile"] as! [String:AnyObject]))
            handler(error,profile)
            
        }
        
    }
    func editProfileWithHandler(handler:(NSError?,Profile?)->Void)->Void{
        
        guard let location = self.location else{

            return
        }
        
        let lat:String? = "\((location.latitude))"
        let long:String? = "\((location.longitude))"
        
        var param:Dictionary<String,AnyObject> = ["profId":self.id!,"name":self.name!,"type":((self.type?.rawValue)! as NSNumber),"latitude":lat!,"longitude":long!,"address":self.address!]
        if let imageUrl = self.imageUrl{
            param["imageUrl"] = imageUrl
        }
        
        print("param: \(param)");
        
        NetworkUtil.postToRoute("profile/edit", params: nil, json: param) { (error, result) -> Void in
            
            guard let result = result as? Dictionary<String,AnyObject>else{
                handler(error,nil)
                return
            }
            
            print("result: \(result)")
            
//            let profile = Profile(dict: (result["profile"] as! [String:AnyObject]))
//            handler(error,profile)
            
        }
        
    }
    class func find(location:CLLocationCoordinate2D,offsetIds:[String]?,type:Profile.ProfileType,minDistance:Double?,term:String?,handler:(NSError?,[Dictionary<String,AnyObject>]?)->Void){
        
        let lat:String? = "\((location.latitude))"
        let long:String? = "\((location.longitude))"
        print("currentType: \(type), raw: \(type.rawValue as NSNumber) ")

        var param:Dictionary<String,AnyObject> = ["type":(type.rawValue as NSNumber),"latitude":lat!,"longitude":long!]
        
        print("offets: \(offsetIds) \(minDistance)");
        
        if let offsetIdsArray = offsetIds{
            param["offsetIds"] = offsetIdsArray
        }

        if let minDistanceNum = minDistance{
            param["minDistance"] = minDistanceNum
        }
        
        if let searchTerm = term{
            param["name"] = searchTerm
        }
        
        print("param: \(param)");
        
        NetworkUtil.postToRoute("profile/find", params: nil, json: param) { (error, result) -> Void in
            
            
            
            guard let result = result as? Dictionary<String,AnyObject> else{
                handler(error,nil)
                return
            }
            
            guard let resultArray = result["profiles"] as? [Dictionary<String,AnyObject>] else{
                handler(error,nil)
                return
            }
            
            handler(error,resultArray)
                
            
        }
        
        
    }
    
    class func setOffsetParamForFind(array:[Profile])->Dictionary<String,AnyObject>{
        
        if(!array.isEmpty){
            var offsetIds = [String]()
            let minDistance = array.last?.distance

            for index in (array.count-1).stride(to: 0, by: -1){
                
                let profile:Profile = array[index]
                
                if(profile.distance! == minDistance!){
                    print("min distance: \(minDistance) \(profile.name)")
                    offsetIds.append(profile.id!)
                }else{
                    break
                }
            }
        
            let param:Dictionary<String,AnyObject> = ["offsetIds":offsetIds,"minDistance":minDistance!]

            
            return param
        }else{
            
            return [String:AnyObject]()
        }
    }
    
    init(dict:Dictionary<String,AnyObject>){
        
        configureProfile(dict)


    }
    
    func configureProfile(dict:Dictionary<String,AnyObject>){
        
        
        self.id = dict["_id"] as? String
        self.name = dict["name"] as? String
        self.imageUrl = dict["imageUrl"] as? String
        self.type = Profile.ProfileType(rawValue: Int((dict["type"] as? Double)!))
        
        var num:Double = 0.0;
        if let r1 = dict["r1"]{
            
            if(Int(r1 as! Double) != 0){
                num = num + 1
                self.r1 = r1 as! Double
            }
        }
        if let r2 = dict["r2"]{
            
            if(Int(r2 as! Double) != 0){
                num = num + 1
                self.r2 = r2 as! Double
            }
        }
        if let r3 = dict["r3"]{
            
            if(Int(r3 as! Double) != 0){
                num = num + 1
                self.r3 = r3 as! Double
            }
        }
        if let r4 = dict["r4"]{
            
            if(Int(r4 as! Double) != 0){
                num = num + 1
                self.r4 = r4 as! Double
            }
        }
        
        if (num != 0){
            
            let average = (self.r1 + self.r2 + self.r3 + self.r4)/(num * 5.0)
            
            self.totalRating = Int( average * 100.0)
            
            print("totalRating: \(self.totalRating)");
        }
        
        if let location = dict["location"] as? [Double]{
            self.location = CLLocationCoordinate2D(latitude: location[1], longitude: location[0])
            if let addressDict = dict["address"]{
                self.address = addressDict as? Dictionary<String, String>
            }
        }
        
    }
    func getReviewFromProfile(handler:(NSError?)->Void){
        if let profile = id{
            
            NetworkUtil.getRoute("review/\(profile)", params: nil, JSONResultHandler: { (error, result) -> Void in

                if let error = error {
                    print("print error here")
                    handler(error)
                    return;
                }
                
                if let result = result{
                    if let pfDict = result["profile"] as? Dictionary<String,AnyObject>{
                        self.configureProfile(pfDict)
                    }
                    
                    if let rDict = result["reviews"] as? [Dictionary<String,AnyObject>]{
                        print("rdict: \(rDict)")
                    }
                    
                    if let reviews = result["r"] as? Dictionary<String,AnyObject>{
                        print("rrr: \(reviews)");
                        if let r1 = reviews["r1"]{
                            self.r1 = r1 as! Double
                        }
                        if let r2 = reviews["r2"]{
                            self.r2 = r2 as! Double
                        }
                        if let r3 = reviews["r3"]{
                            self.r3 = r3 as! Double
                        }
                        if let r4 = reviews["r4"]{
                            self.r4 = r4 as! Double
                        }
                        
                        
                        
                        self.totalRating = Int(((self.r1+self.r2+self.r3+self.r4)/20.0) * 100.0)
                    }
                }
                
                
                handler(nil)

                
            })
        }
    }
    init(){
    }
    
}