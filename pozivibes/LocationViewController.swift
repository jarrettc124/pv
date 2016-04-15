//
//  LocationViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/1/16.
//  Copyright © 2016 pozivibes. All rights reserved.pi
//

import UIKit

class LocationViewController: UIViewController, UITableViewDelegate,UITableViewDataSource{

    let locationManager = LocationManager.init()
    var street:String?
    var city:String?
    var state:String?
    var zip:String?
    var unit:String?
    var placemark:CLPlacemark?
    var locationParam:Dictionary<NSObject,AnyObject>?
    
    @IBOutlet weak var streetTextfield: UITextField!
    @IBOutlet weak var secondStreetAddressTextfield: UITextField!
    @IBOutlet weak var cityTextfield: UITextField!
    
    //Mark: Search
    @IBOutlet weak var locationTableHeight: NSLayoutConstraint!
    @IBOutlet weak var locationTextfield: UITextField!
    var currentLocation:CLLocationCoordinate2D?
    var businesses: [Business]!
    @IBOutlet weak var locationTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.observeKeyboard()
        // Do any additional setup after loading the view
    }
    
    
    func observeKeyboard(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        if (self.locationTextfield.isFirstResponder()){
        
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.locationTableHeight.constant = self.view.frame.size.height-keyboardSize.height-64-37
                
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(self.cancelSearchLocation))
                
    //            self.searchView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.height-64-37)
            }
        }
    
    }
    func keyboardWillHide(notification:NSNotification){
        self.locationTableHeight.constant = 0
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
//        self.searchView.frame = CGRectMake(0, 64, self.view.frame.size.width, 0)
    }
    func cancelSearchLocation(){
        self.view.endEditing(true)
                self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem
        self.locationTableHeight.constant = 0
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(LocationManager.checkLocationEnabled()){
            
            self.locationManager.fetchLocationWithCompletionHandler({ (error, location) -> Void in
                if let error = error{
                    print("print error here")
                }else{
                    self.currentLocation = location?.coordinate
                    
                }
            })
        }else{
    
            self.locationManager.getAuthorizationStatus({ (status) -> Void in
            
            }, failHandler: { (status) -> Void in
            
            })
            
        }
        
        
        if let placemark = self.placemark{
            self.setupPlacemark(placemark)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupPlacemark(placemark:CLPlacemark){
        
        
        var dict = [String:String]()
        
        if let streetAddress = placemark.addressDictionary!["Street"] as? String{
            self.streetTextfield.text = streetAddress
            self.street = streetAddress
            dict["street"] = self.street
        }
        
        if let cityAddress = placemark.addressDictionary!["City"] as? String{
            self.cityTextfield.text = cityAddress
            self.city = cityAddress
            dict["city"] = self.city

        }
        
        if let stateAddress = placemark.addressDictionary!["State"] as? String{
            self.cityTextfield.text! += ", \(stateAddress)"
            self.state = stateAddress
            dict["state"] = self.state

        }
        
        if let zipAddress = placemark.addressDictionary!["ZIP"] as? String{
            self.cityTextfield.text! += " \(zipAddress)"
            self.zip = zipAddress
            dict["zip"] = self.zip

        }
        
        if let unit = self.secondStreetAddressTextfield.text{
            self.secondStreetAddressTextfield.text = unit.capitalizedString
            self.unit = unit.capitalizedString
            dict["unit"] = self.unit
        }
        
        self.locationParam = ["placemark":placemark,"address":dict]
        
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {

    }
    
    @IBAction func doneButtonAction(sender: UIBarButtonItem) {
        
        
        let geocoder = CLGeocoder.init()
        var fullAddress = self.streetTextfield.text! + ", "
        
        if let secondAddress = self.secondStreetAddressTextfield.text{
            fullAddress += secondAddress + " "
        }
        
        fullAddress += self.cityTextfield.text!
        
        geocoder.geocodeAddressString(fullAddress) { (placemarks, error) -> Void in
            if let error = error{
                
            }else{
                let placemark = placemarks?.last
      
                self.setupPlacemark(placemark!)
                if let param = self.locationParam{
                    NSNotificationCenter.defaultCenter().postNotificationName("UnwindPreviousState", object: nil, userInfo: param)
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    @IBAction func getCurrentLocationAction(sender: UIButton) {
        if(LocationManager.checkLocationEnabled()){

            self.locationManager.fetchLocationWithCompletionHandler({ (error, location) -> Void in
                if let error = error{
                    print("print error here")
                }else{
                    
                    let geocoder = CLGeocoder.init()
                    geocoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) -> Void in
                        
                        if let error = error{
                            print("print error here")
                        }else{
                            
                            let placemark = placemarks?.last
                            
                            self.setupPlacemark(placemark!)
                            
                        }
                        
                    })
                    
                    
                }
            })
            
        }else{
            
            self.locationManager.getAuthorizationStatus({ (status) -> Void in
                
                }, failHandler: { (status) -> Void in
                    
            })
            
        }

    }
    
    
    @IBAction func queryForLocation(sender: UITextField) {
        
        if let textSearch = sender.text{
            
            if (sender.text?.characters.count > 0){
                
                if let currentlocation = self.currentLocation{
                
                    Business.searchWithTerm(textSearch, location: currentLocation, completion:{ (businesses: [Business]!, error: NSError!) in
                        
                        
                        guard error == nil else {
                            print("Autocomplete error \(error)")
                            return
                        }
                        
                        print(businesses.count)
                        
                        if (businesses.count > 0){
                            
                            self.businesses = businesses
                            self.locationTableview.reloadData()
                            
                        }else{
                            self.businesses = nil
                            self.locationTableview.reloadData()
                                
                        }
                        
                    })
                }else{
                    if(LocationManager.checkLocationEnabled()){
                        
                        self.locationManager.fetchLocationWithCompletionHandler({ (error, location) -> Void in
                            if let error = error{
                                print("print error here")
                            }else{
                                self.currentLocation = location?.coordinate
                                
                            }
                        })
                    }else{
                        
                        self.locationManager.getAuthorizationStatus({ (status) -> Void in
                            
                            }, failHandler: { (status) -> Void in
                                
                        })
                        
                    }
                }
            }else{
                self.businesses = nil
                self.locationTableview.reloadData()
            }
            
        }

        
    }
    
    //MARK: -TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            if let businesses = self.businesses{
                return businesses.count
            }else{
                return 0
            }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("BusinessReusableCell", forIndexPath: indexPath)
        
            
        let result:Business = self.businesses[indexPath.row]
        
        cell.textLabel!.text = result.name
        cell.detailTextLabel?.text = result.address
        
        return cell;
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

                
        let result:Business = self.businesses[indexPath.row]
        
        if let addr = result.address{
        
            let geocoder = CLGeocoder.init()
            
            geocoder.geocodeAddressString(addr) { (placemarks, error) -> Void in
                if let error = error{
                    
                }else{
                    let placemark = placemarks?.last
                    
                    self.setupPlacemark(placemark!)
                    if let param = self.locationParam{
                        NSNotificationCenter.defaultCenter().postNotificationName("UnwindPreviousState", object: nil, userInfo: param)
                    }
                    
                    print(self.locationParam)
                    
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
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
