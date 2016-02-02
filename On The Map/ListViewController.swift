//
//  ListViewController.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 12/15/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        ParseUtility.sharedInstance.getStudentLocations() { success, errorMessage in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            } else {
                //Display error message
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func addPin(sender: AnyObject) {
        let pinController = self.storyboard?.instantiateViewControllerWithIdentifier("PinViewController") as! PinViewController
        
        self.presentViewController(pinController, animated: true, completion: nil)
    }
    
    @IBAction func logOut(sender: AnyObject) {
        UdacityClient.sharedInstance.logout() { success, error in
            if success == true {
                dispatch_async(dispatch_get_main_queue()) {
                    let loginController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cellReuseIdentifier = "StudentLocationCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier)
        
        let location = ParseUtility.sharedInstance.locations[indexPath.row]
        
        cell!.textLabel?.text = "\(location.firstName) \(location.lastName)"
        //location.mediaURL
        cell!.detailTextLabel?.text = location.mediaURL
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseUtility.sharedInstance.locations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = ParseUtility.sharedInstance.locations[indexPath.row]
        
        let app = UIApplication.sharedApplication()
        if let url = NSURL(string: location.mediaURL) {
            app.openURL( url )
        } else {
            print("ERROR: Invalid url")
        }
    }
    
}

