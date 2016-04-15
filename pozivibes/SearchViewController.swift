//
//  SearchViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 1/27/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit
import GoogleMaps

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITableViewNXEmptyViewDataSource {
    
    @IBOutlet weak var searchTableview: UITableView!
    var searchArray:[Profile]! = [Profile]()
    var instructorArray:[Profile]! = [Profile]()
    var studioArray:[Profile]! = [Profile]()

    let locationManager = LocationManager.init()
    var currentLocation:CLLocationCoordinate2D?
    
    let refreshControl:UIRefreshControl = UIRefreshControl()
    @IBOutlet weak var lastView: UIView!
    
    @IBOutlet var loadingView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var searchButton: UIButton!
    
    
    //Search View
    @IBOutlet var searchView: UIView!
    @IBOutlet weak var searchTermTextfield: UITextField!
    @IBOutlet weak var searchLocationTableView: UITableView!
    @IBOutlet weak var searchLocationTextfield: UITextField!
    @IBOutlet weak var searchTypeSegmentedControl: UISegmentedControl!
    
    //Google Autocomplete
    var placesClient: GMSPlacesClient?
    var autoCompleteFilter: GMSAutocompleteFilter?
    var locationArray:[AnyObject]?
//    var selectedLocation:[String:AnyObject]?
    var selectedLocation:CLLocationCoordinate2D?
    var isSearchingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.placesClient = GMSPlacesClient()
        self.autoCompleteFilter = GMSAutocompleteFilter()
        
        self.searchTableview.delegate=self
        self.searchTableview.dataSource=self

        self.observeKeyboard()
//        self.searchTableview.nxEV_emptyView = self.lastView
        // Do any additional setup after loading the view.
        self.searchTableview.rowHeight = UITableViewAutomaticDimension
        self.searchTableview.estimatedRowHeight = 100
        self.lastView.hidden=true
        
//        self.refreshControls = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(SearchViewController.getNearProfiles), forControlEvents: UIControlEvents.ValueChanged)
        self.searchTableview.addSubview(self.refreshControl)
        
        if(PPMyUser.currentType == Profile.ProfileType.Instructor){
            self.segmentedControl.selectedSegmentIndex = 0;
        }else{
            self.segmentedControl.selectedSegmentIndex = 1;

        }
        print("currentType: \(PPMyUser.currentType), raw: \(PPMyUser.currentType.rawValue)")

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupSearchView()

        if let selectedIndex = self.searchTableview.indexPathForSelectedRow{
            self.searchTableview.deselectRowAtIndexPath(selectedIndex, animated: animated)
        }
        
//        self.getNearProfiles()

    }
    func setupSearchView(){
        self.searchView.frame = CGRectMake(0, 64, self.view.frame.size.width, 0)
        self.view.addSubview(self.searchView)
    }
    func observeKeyboard(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.keyboardWillHide(_:)), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.searchView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-keyboardSize.height-64-37)
        }
        
    }
    func keyboardWillHide(notification:NSNotification){
        
        self.searchView.frame = CGRectMake(0, 64, self.view.frame.size.width, 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        self.displaySignupScreen()

        if let isFirstTimeUser = NSUserDefaults.standardUserDefaults().objectForKey("isFirstTimeUser") as? Bool{
            
            if(isFirstTimeUser == true){
                self.displaySignupScreen()
            }
        
        }else{
            self.displaySignupScreen()
        }
        
    }
    
    
    @IBAction func searchTypeChanged(sender: UISegmentedControl) {
        
    }
    
    
    @IBAction func typeChanged(sender: UISegmentedControl) {
        
        PPMyUser.currentType = Profile.ProfileType(rawValue: sender.selectedSegmentIndex)!

        if(PPMyUser.currentType == Profile.ProfileType.Instructor){
            self.searchArray = self.instructorArray

        }else if(PPMyUser.currentType == Profile.ProfileType.Studio) {

            self.searchArray = self.studioArray

        }

        if(self.searchArray.count == 0){
            self.lastView.hidden=true
        }else{
            self.lastView.hidden=false
        }

        self.searchTableview.reloadData()
        
    }

    
    func displaySignupScreen(){
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "isFirstTimeUser")
        
        let storyboard = UIStoryboard(name: "Signup", bundle: nil)
        
        let vc = storyboard.instantiateInitialViewController()!
        
        self.navigationController?.visibleViewController?.presentViewController(vc, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNearProfiles(){
        
        if(LocationManager.checkLocationEnabled()){
            
            self.locationManager.fetchLocationWithCompletionHandler({ (error, location) -> Void in
                
                
                self.refreshControl.endRefreshing()

                
                if let error = error{
                    print("print error here")
                    self.lastView.hidden=false
                    self.searchTableview.reloadData()

                }else{
                    self.currentLocation = location?.coordinate
//                    let offsetParam = Profile.setOffsetParamForFind(self.searchArray!)
                    

                    Profile.find((location?.coordinate)!, offsetIds: nil, type: PPMyUser.currentType, minDistance: nil,term:nil,handler: { (error, result) -> Void in

                        if let error = error{
                            
                        }else{
                            
                            if let result = result{
                                print("\(result)")
                                self.searchArray.removeAll()
                                
                                for dict in result{
                                    let profile = Profile(dict: dict["obj"] as! [String:AnyObject])
                                    profile.distance = dict["dis"] as? Double;
                                    self.searchArray.append(profile)
                                }
                                
                            
                                if(PPMyUser.currentType == Profile.ProfileType.Instructor){
                                    self.instructorArray = self.searchArray
                                }else if(PPMyUser.currentType == Profile.ProfileType.Studio) {
                                    self.studioArray = self.searchArray
                                }
                                self.lastView.hidden=false

                                self.searchTableview.reloadData()
                                
                            }
                            
                        }
                        

                    
                    })

                    
                    
                }
            })
            
        }else{
            print("Don't get profile")
            self.refreshControl.endRefreshing()
            self.locationManager.getAuthorizationStatus({ (status) -> Void in
                
                }, failHandler: { (status) -> Void in
                    
            })

        }
        
        self.searchTableview.reloadData()
        
    }
    @IBAction func loadMoreAction(sender: AnyObject) {
        if let currentLocation = self.currentLocation{
            
            let offsetParam = Profile.setOffsetParamForFind(self.searchArray)
            
            let offsetIds = offsetParam["offsetIds"] as? [String]
            let minDistance = offsetParam["minDistance"] as! Double
            
            print("\(offsetIds) \(minDistance)");
            
            var searchTerm:String? = nil
            if self.searchTermTextfield.text!.characters.count > 0 {
                searchTerm = self.searchTermTextfield.text
            }
            
            Profile.find(currentLocation, offsetIds: offsetIds, type: PPMyUser.currentType, minDistance: minDistance,term:searchTerm,handler: { (error, result) -> Void in
                
                if let error = error{
                    print("print error here")
                }else{
                    
                    if let result = result{
                        print("\(result)")
                    
                        
                        for dict in result{
                            let profile = Profile(dict: dict["obj"] as! [String:AnyObject])
                            profile.distance = dict["dis"] as? Double;
                            self.searchArray.append(profile)
                        }
                        
                        if(PPMyUser.currentType == Profile.ProfileType.Instructor){
                            self.instructorArray = self.searchArray
                        }else if(PPMyUser.currentType == Profile.ProfileType.Studio) {
                            self.studioArray = self.searchArray
                        }
                        
                        
                        self.searchTableview.reloadData()
                        
                    }
                    
                }
                
                
            })
        }
        
    }
    
    
    
    @IBAction func createNewProfile(sender: UIButton) {
        self.performSegueWithIdentifier("createProfileSegue", sender: self)
    }
    //MARK: -TableView

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.searchTableview){
            return searchArray!.count
        }
        else if (tableView == self.searchLocationTableView){
            if let locationArray = locationArray{
                return locationArray.count+1
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    func outputTotalReview(profile:Profile)->String{
        if (Int(profile.r1) == 0 && Int(profile.r2) == 0 && Int(profile.r3) == 0 && Int(profile.r4) == 0){
            return "No Reviews Yet"
        }else{
            return "\(profile.totalRating)%"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        if (tableView == self.searchTableview){

            let profile:Profile = self.searchArray![indexPath.row]
            
            let cell:SearchTableViewCell = tableView.dequeueReusableCellWithIdentifier("SearchProfileTableCell", forIndexPath: indexPath) as! SearchTableViewCell
            
            cell.tag = indexPath.row
            cell.nameLabel.text = profile.name;
            cell.ratingLabel.text = self.outputTotalReview(profile)
            
            if let address = profile.address{
                if let city = address["city"], state = address["state"]{
                    cell.cityLabel.text = city + ", " + state
                }else{
                    cell.cityLabel.text = ""
                }
            }else{
                cell.cityLabel.text = ""
            }
            
            profile.retrieveProfileImageWithCompletionHandler({ (error, image, key) -> Void in
                
                cell.profileImageView.image = image

                if(cell.tag == key as! Int){
                    cell.profileImageView.image = image
                }
                
                }, key: indexPath.row as Int)
            
            
            return cell
        }else{
            let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("LocationReusableCell", forIndexPath: indexPath)
            
            if (indexPath.row==0) {
                cell.textLabel?.textColor = UIColor.blueColor()
                cell.textLabel?.text = "Current Location";
            }
            else{
                
                let result:GMSAutocompletePrediction = self.locationArray![indexPath.row - 1] as! GMSAutocompletePrediction
                
                let regularFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
                let boldFont = UIFont.boldSystemFontOfSize(UIFont.labelFontSize())
                
                let bolded = result.attributedFullText.mutableCopy() as! NSMutableAttributedString
                bolded.enumerateAttribute(kGMSAutocompleteMatchAttribute, inRange: NSMakeRange(0, bolded.length), options: []) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    let font = (value == nil) ? regularFont : boldFont
                    bolded.addAttribute(NSFontAttributeName, value: font, range: range)
                }
                
                
                cell.textLabel!.attributedText = bolded
                
            }
            
            return cell;
            
            
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (tableView == self.searchLocationTableView){
            isSearchingLocation = true
            
            if (indexPath.row == 0) {
                
                self.refreshLocation()
                isSearchingLocation=false;
                
            }
            else{

                
                let result:GMSAutocompletePrediction = self.locationArray![indexPath.row - 1] as! GMSAutocompletePrediction
                
                
                let googlePlaceClient = GMSPlacesClient()
                
                googlePlaceClient.lookUpPlaceID(result.placeID, callback: { (place, error) in
                    
                    self.isSearchingLocation = false
                    
                    self.locationArray?.removeAll()
                    self.searchLocationTableView.reloadData()
                    
                    if let error = error{
                        print("Place Details error \(error.localizedDescription)")
                        return
                    }
                    
                    if let place = place{
                        let businessLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
                        
                        self.currentLocation = businessLocation.coordinate
                        
                        self.searchLocationTextfield.text = result.attributedFullText.string
                        

                        
                    }else{
                        
                    }
                    
                })
                
            }

        }
    }
    
    func refreshLocation(){
//        
//        self.loadingIndicator.hidden=NO;
//        self.loadingLabel.hidden=NO;
//        self.cityTitle.hidden=YES;
        
        if(LocationManager.checkLocationEnabled()){
            self.locationManager.fetchLocationWithCompletionHandler({ (error, location) -> Void in

                if let error = error{
                    print("print error here")
                    
//                    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Could not find your location!" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6] }];
                    //self.cityTitle.attributedPlaceholder = str;

                    self.currentLocation = nil;
                    self.selectedLocation = nil;
                    
                }else{
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) in
                        
                        if let error = error{
                            print(error.description)
                        }else{
                            
                            self.selectedLocation = location?.coordinate
                            self.currentLocation = location?.coordinate
                            
                            //Update UI
                            self.searchLocationTextfield.text = "Current Location"
                        self.searchButton.setTitle("Current Location", forState: .Normal)
                            
                        }
                        
                        
                    })
                }
                
                
            })
        }
        else{
            self.searchLocationTextfield.text = "Couldn't Find Your Location!"
            self.searchButton.setTitle(self.searchLocationTextfield.text, forState: .Normal)
        }
    }
    
    @IBAction func searchButtonAction(sender: UIButton) {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(self.hideSearchView))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .Plain, target: self, action: #selector(self.searchTermAction))

        self.showSearchView()
        
        self.searchTermTextfield.becomeFirstResponder()
        
    }
    
    func showSearchView(){
        
        self.searchTypeSegmentedControl.hidden = false;
        self.searchTypeSegmentedControl.selectedSegmentIndex = PPMyUser.currentType.rawValue
        
        if PPMyUser.currentType == Profile.ProfileType.Instructor {
            
            self.searchTermTextfield.placeholder = "Instructor"
            
            
            
        }else if PPMyUser.currentType == Profile.ProfileType.Studio{
            
        }
        
    }
    
    //Mark - bar button
    
    func searchTermAction(){
        
        if let searchLocation = self.currentLocation, searchTerm = self.searchTermTextfield.text{
            
            if searchTerm.characters.count > 0 {
            
                let resultAttr = NSMutableAttributedString(string: self.searchTermTextfield.text!, attributes: [NSForegroundColorAttributeName:UIColor.blackColor()])
                
                
                let locationAttr = NSAttributedString(string: " :\(self.searchLocationTextfield.text!)", attributes: [NSForegroundColorAttributeName:UIColor.grayColor()])
                
                resultAttr.appendAttributedString(locationAttr)
                
                self.searchButton.setAttributedTitle(resultAttr, forState: .Normal)

                
                let searchTermType = Profile.ProfileType(rawValue: self.searchTypeSegmentedControl.selectedSegmentIndex)!
                
                Profile.find(searchLocation, offsetIds: nil, type: searchTermType, minDistance: nil,term:searchTerm,handler: { (error, result) -> Void in
                    
                    self.hideSearchView()
                    self.searchTermTextfield.text = ""
                    self.searchLocationTextfield.text = ""
                    
                    self.searchArray.removeAll()
                    self.searchTableview.reloadData()

            
                    if let error = error{
                        print("print error here: can't find profile")

                    }else{
                        
                        if let result = result{
                            print("\(result)")
                            
                            
                            
                            for dict in result{
                                let profile = Profile(dict: dict["obj"] as! [String:AnyObject])
                                profile.distance = dict["dis"] as? Double;
                                self.searchArray.append(profile)
                            }
                            
                            
                            if(PPMyUser.currentType == Profile.ProfileType.Instructor){
                                self.instructorArray = self.searchArray
                            }else if(PPMyUser.currentType == Profile.ProfileType.Studio) {
                                self.studioArray = self.searchArray
                            }
                            self.lastView.hidden=false
                            
                            self.searchTableview.reloadData()
                            
                        }
                        
                    }
                    
                    
                    
                })
                
            }
            else{
                print("print error here: didn't put in term")
            }
            
            
        }
        
    }
    func showUserAccount(){
        
    }
    
    func hideSearchView(){
        self.searchTypeSegmentedControl.hidden = true;

        self.view.endEditing(true)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        
//        self.searchView.frame = CGRectMake(0, 64, self.view.frame.size.width, 0)

    }
    @IBAction func queryForCity(sender: UITextField) {
        
        if let textSearch = sender.text{
            
            if (sender.text?.characters.count > 0){
                
                self.autoCompleteFilter?.type = .Region
                
                placesClient?.autocompleteQuery(textSearch, bounds: nil, filter: self.autoCompleteFilter, callback: { (results, error:NSError?) in
                    
                    guard error == nil else {
                        print("Autocomplete error \(error)")
                        return
                    }
                    
                    if let results = results{
                        
                        if (results.count > 0){
                            self.locationArray = results
                            self.searchLocationTableView.reloadData()
                        }else{
                            self.autoCompleteFilter?.type = .Address
                            
                            self.placesClient?.autocompleteQuery(textSearch, bounds: nil, filter: self.autoCompleteFilter, callback: { (results, error:NSError?) in

                                self.locationArray = results;
                                self.searchLocationTableView.reloadData()
                                
                            })

                            
                        }
                    }
                })
            }else{
                self.locationArray = nil
                self.searchLocationTableView.reloadData()
            }
            
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "createProfileSegue"){
            let vc = segue.destinationViewController as? EditProfileViewController
            
            vc?.type = PPMyUser.currentType
        }else if(segue.identifier == "searchToProfile"){
            let pvc = segue.destinationViewController as? ProfileTableViewController
            
            pvc?.profile = self.searchArray![(self.searchTableview.indexPathForSelectedRow?.row)!]
            
        
            
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
