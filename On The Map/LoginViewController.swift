//
//  LginViewController.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 11/27/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    

    var tapRecognizer: UITapGestureRecognizer? = nil // It releases the keyboard if the user taps outside of the textboxes
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginFunc(sender: AnyObject) {
        startNetworkActivity()

        
        UdacityClient.sharedInstance.loginWithUsername( emailTextField.text!, password: passwordTextField.text!) { (success, error) in
            
            if success {
                //Move to TabBarController
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopNetworkActivity()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                //Display error message
                
                if error == UdacityClient.Messages.loginError {
                    //Incorrect username or password
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.loginSubview.layer.addAnimation( self.shake, forKey:nil )
                        let alert = UIAlertController(title: "", message: "Incorrect username or password!", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)

                    }
                    
                    self.passwordTextField.text = ""
                } else {
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
                    alert.addAction(dismissAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.stopNetworkActivity()
                }
            }
        }
    }
    
    func startNetworkActivity() {
        activityIndicator.startAnimating()
        loginButton.hidden = true
        emailTextField.userInteractionEnabled = false
        passwordTextField.userInteractionEnabled = false
    }
    
    func stopNetworkActivity() {
        activityIndicator.stopAnimating()
        loginButton.hidden = false
        emailTextField.userInteractionEnabled = true
        passwordTextField.userInteractionEnabled = true
    }

}

