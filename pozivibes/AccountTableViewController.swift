//
//  AccountTableViewController.swift
//  pozivibes
//
//  Created by Jarrett Chen on 2/26/16.
//  Copyright © 2016 pozivibes. All rights reserved.
//

import UIKit

class AccountTableViewController: UITableViewController {
    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var userActionLabel: UILabel!
    @IBOutlet weak var editBarButton: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        accountImageView.image = UIImage(named: "pf_placeholder")

        if let currentUser = PPMyUser.sharedUser{
            accountNameLabel.text = currentUser.displayName
            userActionLabel.text = "Logout"
            self.navigationItem.rightBarButtonItem = editBarButton
            currentUser.retrieveProfileImageWithCompletionHandler({ (error, image, key) -> Void in
                
                if let image = image{
                    self.accountImageView.image = image
                }
                
                
                }, key: nil)
            
            
        }else{
            accountNameLabel.text = " "
            userActionLabel.text = "Sign In"
            self.navigationItem.rightBarButtonItem = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (indexPath.row == 0){
            //Logout
            if let currentUser = PPMyUser.sharedUser{
                PPMyUser.logout()
//                self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController?.popViewControllerAnimated(true)
            }else{

                let storyboard = UIStoryboard(name: "Signup", bundle: nil)
                
                let vc = storyboard.instantiateInitialViewController()!
                
                self.navigationController?.visibleViewController?.presentViewController(vc, animated: true, completion: nil)
            }

        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
