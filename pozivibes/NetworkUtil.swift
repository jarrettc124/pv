//
//  NetworkUtil.swift
//  SwiftProj
//
//  Created by Jarrett Chen on 12/21/15.
//  Copyright © 2015 Pixel and Processor. All rights reserved.
//

import Foundation

class NetworkUtil{
    
    static let backendVersion = "1.0"
    static let cloudinary_url = "cloudinary://761295191157382:QnNUKYvRi0RnmSABPrp0IlzOEf0@pixel-and-processor"
    
    static let NetworkErrorStatusCodeKey = "NetworkErrorStatusCodeKey"
    static let NetworkErrorDomain = "NetworkErrorDomain"
    static let NetworkErrorMessageKey = "NetworkErrorMessageKey"
    
    
    static let NETWORK_GENERIC_ERROR_CODE = 1400
    static let NETWORK_FORBIDDEN_ERROR_CODE = 1403
    static let NETWORK_NOT_FOUND_ERROR_CODE = 404
    static let NETWORK_REJECT_ERROR_CODE = 1401
    static let NETWORK_NOT_AUTHORIZED_ERROR_CODE = 401
    static let NETWORK_VALIDATION_ERROR_CODE = 1422
    static let NETWORK_SERVER_ERROR_CODE = 1500
    static let NETWORK_SUCCESS_CODE = 200
    static let NETWORK_UNAUTHORIZED = 401
    static let NETWORK_FACEBOOK_REJECT = 500
    static let NETWORK_NO_INTERNET = -1004
    
    //Properties
    class var serverHost:String {
        #if DEBUG
            return "localhost"
        #else
            return "pozivibes-test.herokuapp.com"
        #endif
    }
    
    class var serverPort:String {
        #if DEBUG
        return "5000"
        #else
        return "443"
        #endif
    }
    
    class var serverIsSecure:Bool{
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    class func serverURLWithPath(path:String) -> NSURL{
        if(NetworkUtil.serverIsSecure){
            return NSURL(string: "https://\(NetworkUtil.serverHost):\(NetworkUtil.serverPort)/v\(backendVersion)/\(path)")!
        }else{
            return NSURL(string: "http://\(NetworkUtil.serverHost):\(NetworkUtil.serverPort)/v\(backendVersion)/\(path)")!
        }
    }
    
    class var serverURL:NSURL{
        
        if(NetworkUtil.serverIsSecure){
            return NSURL(string: "https://\(NetworkUtil.serverHost):\(NetworkUtil.serverPort)/v\(backendVersion)")!
        }else{
            return NSURL(string: "http://\(NetworkUtil.serverHost):\(NetworkUtil.serverPort)/v\(backendVersion)")!
        }
        
        
    }
    
    class func getRoute(route:String, method:String, refresh:Bool, dataHandler:((error: NSError?, data:NSData?)->Void)){
        
        let serverURL:NSURL = NetworkUtil.serverURLWithPath(route)
        print("Server URL: \(serverURL)")
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: serverURL)
        if(refresh){
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        }
        request.HTTPMethod = method
        let task = session.dataTaskWithRequest(request, completionHandler: NetworkUtil.processNSDataWithCompletionHandler(dataHandler))
        
        task.resume()
        
    }
    
    class func getRoute(route:String, method:String, dataHandler:(error:NSError?,data:NSData?)->Void){

        getRoute(route, method: method, refresh: false, dataHandler: dataHandler)
    }
    class func getRoute(route:String, dataHandler:(error:NSError?,data:NSData?)->Void){
        getRoute(route, method: "GET", dataHandler: dataHandler)
    }
    class func getRoute(route:String,refresh:Bool, dataHandler:(error:NSError?,data:NSData?)->Void){
        getRoute(route, method: "GET", refresh: refresh, dataHandler: dataHandler)
    }

    class func getRoute(route:String, JSONResultHandler:(error:NSError?,result:AnyObject?)->Void){
        getRoute(route, dataHandler: NetworkUtil.processJSONWithCompletionHandler(JSONResultHandler))
    }
    class func getRoute(route:String, refresh:Bool, JSONResultHandler:(error:NSError?,result:AnyObject?)->Void){
        getRoute(route, refresh: refresh, dataHandler: NetworkUtil.processJSONWithCompletionHandler(JSONResultHandler))
    }
    class func getRoute(route:String, method:String, JSONResultHandler:(error:NSError?,result:AnyObject?)->Void){
        getRoute(route, method: method, dataHandler: NetworkUtil.processJSONWithCompletionHandler(JSONResultHandler))
    }
    class func getRoute(route:String, method:String, refresh:Bool, JSONResultHandler:(error:NSError?,result:AnyObject?)->Void){
        getRoute(route, method: method, refresh: refresh, dataHandler: NetworkUtil.processJSONWithCompletionHandler(JSONResultHandler))
    }
    
    class func getRoute(route:String, method:String, params:Dictionary<String,AnyObject>, dataHandler:(error:NSError?,data:NSData?)->Void){
        let routeString = NetworkUtil.routeString(route, params: params)
        getRoute(routeString, method: method, dataHandler: dataHandler)
    }
    class func getRoute(route:String, params:Dictionary<String,AnyObject>, dataHandler:(error:NSError?,data:NSData?)->Void){
        
        let routeString = NetworkUtil.routeString(route, params: params)
        
        getRoute(routeString, dataHandler: dataHandler)
        
    }
    class func getRoute(route:String, refresh:Bool, params:Dictionary<String,AnyObject>, dataHandler:(error:NSError?,data:NSData?)->Void){
        let routeString = NetworkUtil.routeString(route, params: params)
        getRoute(routeString, refresh: refresh, dataHandler: dataHandler)
    }
    
    class func getRoute(route:String, params:Dictionary<String,AnyObject>?, JSONResultHandler:(error:NSError?,result:AnyObject?)->Void){
        
        if let param = params{
            let routeString = NetworkUtil.routeString(route, params: param)
            getRoute(routeString, JSONResultHandler: JSONResultHandler)
        }else{
            getRoute(route, JSONResultHandler: JSONResultHandler)

        }

    }
    class func getRoute(route:String, refresh:Bool, params:Dictionary<String,AnyObject>, JSONResultHandler:(error:NSError?,result:AnyObject?)->Void){
        let routeString = NetworkUtil.routeString(route, params: params)
        getRoute(routeString, refresh:refresh, JSONResultHandler: JSONResultHandler)
    }
    class func getRoute(route:String, method:String, refresh:Bool, params:Dictionary<String,AnyObject>, JSONResultHandler:(error:NSError?,result:AnyObject?)->Void){
        let routeString = NetworkUtil.routeString(route, params: params)
        getRoute(routeString, method:method, refresh:refresh, JSONResultHandler: JSONResultHandler)
    }
    
    class func postToRoute(route:String, data:NSData?, completionHandler:(error:NSError?,data:NSData?)->Void){
        
        let serverURL:NSURL = NetworkUtil.serverURLWithPath(route)
        print("Server URL: \(serverURL)")
        
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: serverURL)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
        request.HTTPMethod = "POST"
        if(data != nil){
            request.HTTPBody=data
        }
        
        let task = session.dataTaskWithRequest(request, completionHandler: NetworkUtil.processNSDataWithCompletionHandler(completionHandler))
        
        task.resume()
    }
    
    class func postToRoute(route:String?, params:Dictionary<String,AnyObject>?, data:NSData?, completionHandler:(error:NSError?,data:NSData?)->Void){
        
        let newRouteString = NetworkUtil.routeString(route!, params: params!)
        
        NetworkUtil.postToRoute(newRouteString, data: data, completionHandler: completionHandler)
    }

    class func postToRoute(route:String,params:Dictionary<String,AnyObject>?,json:AnyObject?,completionHandler:(NSError?,AnyObject?)->Void){
        
        guard let json = json else{
            NetworkUtil.postToRoute(route, params: params, data: nil, completionHandler: NetworkUtil.processJSONWithCompletionHandler(completionHandler))
            return
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            do {

                let jsonData = try NSJSONSerialization.dataWithJSONObject(json, options: [])
                let serverURL = NetworkUtil.serverURLWithPath(route)
                print("Server URL: \(serverURL)")

                let request = NSMutableURLRequest(URL: serverURL)
                request.HTTPMethod="POST"
                request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("\(jsonData.length)", forHTTPHeaderField: "Content-Length")
                request.HTTPBody=jsonData
                
                let session = NSURLSession.sharedSession()
                let task = session.dataTaskWithRequest(request, completionHandler: NetworkUtil.processNSDataWithCompletionHandler(NetworkUtil.processJSONWithCompletionHandler(completionHandler)))
                task.resume()
                
            }
            catch let JSONError as NSError{
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(JSONError,nil)
                }
                
            }
            
        }
    }
    
    class func routeString(route:String, params:Dictionary<String,AnyObject>)->String{
        var first = true
        var routeString:String = "\(route)?"
        
        for (paramKey,paramObject) in params{
            if(!first){
                routeString+="&"
            }
            routeString += "\(paramKey)=\(paramObject)"
            first=false
        }
        return routeString
    }
    
    
    
    class func processJSONWithCompletionHandler(completionHandler:((NSError?,AnyObject?)->Void)?)->(NSError?,NSData?)->Void{
        
        func returnFunc(error:NSError?,data:NSData?)->Void{

            
            if (data == nil){
                if let handler = completionHandler{
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        handler(error,nil)
                    }
                }
                return
            }
            

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                do {
                    let result = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers)
                    
                    
                    if let handler = completionHandler{
                        
                        var parsedError:NSError?
                        
                        if(error != nil){
                            var userDict:Dictionary = error!.userInfo
                            let result = result as! [String:AnyObject]
                            var statusCode:Int?=nil
                            
                            if var statusCode = result["statusCode"] as? Int{
                                if(statusCode != NetworkUtil.NETWORK_SUCCESS_CODE){
                                    statusCode = statusCode+1000
                                }
                            }else{
                                statusCode = error!.code
                            }
                            
                            userDict[NetworkUtil.NetworkErrorStatusCodeKey] = statusCode!

                            if let resultError = result["result"]!["error"]{
                                userDict[NetworkUtil.NetworkErrorMessageKey] = resultError
                            }
                            
                            parsedError = NSError(domain: NetworkUtil.NetworkErrorDomain, code: statusCode!, userInfo: userDict)
                            
                        }else{
                            parsedError = error;
                        }
                        dispatch_async(dispatch_get_main_queue()){
                            handler(parsedError,result)
                        }
                        
                    }
                    
                }
                catch let JSONError as NSError{
                    if let handler = completionHandler{
                        dispatch_async(dispatch_get_main_queue()) {
                            handler(JSONError,nil)
                        }
                    }
                }
                
            }
        }
        
        return returnFunc
    }
    
    class func processNSDataWithCompletionHandler(completionHandler:((NSError?,NSData?)->Void)?)->(NSData?,NSURLResponse?,NSError?)->Void{
        func returnFunc(data:NSData?,response:NSURLResponse?,error:NSError?)->Void{
            
            
            if let responseError = error{
                if let handler = completionHandler{
                    handler(responseError,data)
                }
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            if(statusCode != 200){
                let error = NSError(domain: NetworkErrorDomain, code: statusCode, userInfo: [NetworkErrorStatusCodeKey:statusCode])
                if let handler = completionHandler{
                    handler(error,data)
                }
                return
            }
            if let completionHandler = completionHandler{
                completionHandler(nil,data)
            }
        }
        return returnFunc
        
    }
}