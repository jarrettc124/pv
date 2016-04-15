//
//  AddTokenViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 4/13/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class AddTokenViewController: UIViewController, ZFTokenFieldDelegate,ZFTokenFieldDataSource {

    @IBOutlet weak var tokenField: ZFTokenField!
    var tokenFieldArray = [Profile]()
    var searchArray:[Profile]?
    @IBOutlet weak var searchLoadingIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var searchProfileTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tokenField.dataSource = self
        self.tokenField.delegate = self
        self.tokenField.textField.autocorrectionType = UITextAutocorrectionType.No
        self.tokenField.textField.placeholder = "Enter a name"
        self.tokenField.reloadData()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tokenField(tokenField: ZFTokenField!, didTextChanged text: String!) {
        
        if (self.tokenField.textField.text!.characters.count > 0){
            self.searchAutocompleteQuery(self.tokenField.textField.text!)
        }else{
            self.searchArray = nil
            self.searchProfileTableview.reloadData()
        }
        
        
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        
            return UInt(self.tokenFieldArray.count)
        
    }
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 30.0
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        let nibContents = NSBundle.mainBundle().loadNibNamed("TokenView", owner: nil, options: nil)
        let view:UIView = nibContents[0] as! UIView
        let label:UILabel = (view.viewWithTag(2) as? UILabel)!
        let button:UIButton = (view.viewWithTag(3) as? UIButton)!
        
        button.addTarget(self, action: #selector(self.tokenDeleteButtonPressed(_:)), forControlEvents: .TouchUpInside)
        
        let profile = self.tokenFieldArray[Int(index)]
        label.text = profile.name
        let size = label.sizeThatFits(CGSizeMake(1000, 30))
        view.frame = CGRectMake(0, 0, size.width+50, 30)
        return view
    }
    
    func tokenDeleteButtonPressed(tokenButton:UIButton){
        let index = Int(self.tokenField.indexOfTokenView(tokenButton.superview))
        
        if (index != NSNotFound) {
            self.tokenFieldArray.removeAtIndex(index)
            self.tokenField.reloadData()
        }
    }
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 5
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        
    }
    
    func searchAutocompleteQuery(query:String){
        if (query.characters.count > 0){
            self.searchLoadingIndicator.startAnimating()
            self.searchProfileTableview.reloadData()
            let q = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            NetworkUtil.getRoute("auto", params: ["q":q!,"t":"0"], JSONResultHandler: { (error, result) in
                
                print(result)
                
                self.searchLoadingIndicator.startAnimating()
                if let resultArray = result as? [Dictionary<String,AnyObject>]{
                    var arr = [Profile]()
                    for dict in resultArray{
                        let profile = Profile(dict: dict )
                        arr.append(profile)
                    }
                    self.searchArray = arr
                }
                
            })
            
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
