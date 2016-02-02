//
//  PinViewController.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 12/15/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import UIKit
import MapKit

class PinViewController: UIViewController, UITextFieldDelegate {
    
    let geocoder: CLGeocoder = CLGeocoder()
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var entryField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var objectId: String?
    var oldMapString: String?
    var oldMediaURL: String?
    
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)

    
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        submit(self)
        return false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
       adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let changeInHeight = (CGRectGetHeight(keyboardFrame) + 40) * (show ? 1 : -1)
        UIView.animateWithDuration(animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
        })
        
    }


    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.hidden = true
        ParseUtility.sharedInstance.queryStudentLocation(UdacityClient.sharedInstance.userID!) { results, error in
            if let locations = results {
                if locations.count > 0 {
                    self.objectId = locations[0].objectId
                    self.oldMapString = locations[0].mapString
                    self.oldMediaURL = locations[0].mediaURL
                    
                    let alert = UIAlertController(title: "Update?", message: "You already have a pin on the map do you want to update it?", preferredStyle: .Alert)
                    let updateAction = UIAlertAction(title: "Update", style: .Default) { (action) in
                        self.entryField.text = self.oldMapString
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    alert.addAction(updateAction)
                    alert.addAction(cancelAction)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    
                }
            } else {
                print(error)
            }
            
        }
    }
    
    @IBAction func submit(sender: AnyObject) {
        entryField.endEditing(false)
        
        if mapString == nil {
            findOnMap(entryField.text!)
        } else {
            submitLocation()
        }
        
    }
    
    func submitLocation() {
        if let url = NSURL(string: entryField.text!) {
            mediaURL = entryField.text
            
            let locationData: [String: AnyObject] = [
                ParseUtility.JSONResponseKeys.uniqueKey: UdacityClient.sharedInstance.userID!,
                ParseUtility.JSONResponseKeys.firstName: UdacityClient.sharedInstance.name!.first,
                ParseUtility.JSONResponseKeys.lastName: UdacityClient.sharedInstance.name!.last,
                ParseUtility.JSONResponseKeys.mapString: mapString!,
                ParseUtility.JSONResponseKeys.mediaURL: mediaURL!,
                ParseUtility.JSONResponseKeys.latitude: latitude!,
                ParseUtility.JSONResponseKeys.longitude: longitude!
            ]
            
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            mapView.alpha = 0.5
            
            if let id = objectId{
                ParseUtility.sharedInstance.putStudentLocation(id, data: locationData) { success, errorMessage in
                    self.postComplete( success, errorMessage: errorMessage )
                }
            } else {
                ParseUtility.sharedInstance.postStudentLocation(locationData) { success, errorMessage in
                    self.postComplete( success, errorMessage: errorMessage )
                }
            }
            
        } else {
            print("Please enter a valid URL")
        }
    }
    
    func findOnMap(location: String) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        geocoder.geocodeAddressString(location) { placemarks, error in
            if error == nil {
                if let placemark = placemarks![0] as? CLPlacemark {
                    let coordinates = placemark.location!.coordinate
                    
                    //Setup data for submission
                    self.latitude = coordinates.latitude as Double
                    self.longitude = coordinates.longitude as Double
                    self.mapString = location
                    
                    let region = MKCoordinateRegionMake(coordinates, MKCoordinateSpanMake(0.5, 0.5))
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinates
                    self.mapView.addAnnotation(annotation)
                    
                    //Reconfigure display
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        
                        
                        self.topLabel.text = "What is your link?"
                        
                        if self.oldMediaURL != nil {
                            self.entryField.text = self.oldMediaURL
                        } else {
                            self.entryField.text = "Enter URL"
                        }
                        self.submitButton.setTitle("Submit", forState: .Normal)
                        
                        self.mapView.alpha = 1.0
                        self.mapView.setRegion(region, animated: true)
                    }
                }
            } else {
                let alert = UIAlertController(title: "Can't get there from here.", message: "Sorry we couldn't find that location.", preferredStyle: .Alert)
                let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.entryField.text = ""
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                }
                alert.addAction(dismissAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    //Handle location post and put completion
    func postComplete( success: Bool, errorMessage: String? ) {
        if success {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)
            let dismissAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
            alert.addAction(dismissAction)
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.alpha = 1.0
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }
    }
    
    @IBAction func cancelSubmission(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    }

