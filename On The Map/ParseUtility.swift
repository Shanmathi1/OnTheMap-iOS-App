//
//  ParseUtility.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 12/15/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import Foundation

class ParseUtility: NSObject {

    static let sharedInstance = ParseUtility()
    

    var locations: [ParseStudentLocation]
    
    override init() {
        locations = [ParseStudentLocation]()
        super.init()
    }

    
    func requestForMethod( method: String ) -> NSMutableURLRequest {
        let urlString = Constants.BaseURL
        let URL = NSURL(string: urlString)!
        
        return NSMutableURLRequest(URL: URL)
    }
    
    func taskWithRequest( request: NSMutableURLRequest, completionHandler: (results: AnyObject?, error: NSError?) -> Void ) -> NSURLSessionTask {
        
        request.addValue(Constants.AppID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.APIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest( request ) { (data, response, error) in
            if error == nil {

                UtilityClass.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            } else {
                //Error
                completionHandler(results: nil, error: error)
            }
        }
        task.resume()
        return task
    }
    
    func getStudentLocations( completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL + "?order=-updatedAt")!)
        
        taskWithRequest(request) { JSONresults, error in
            
            if error == nil {
                if let results = JSONresults?.valueForKey(JSONResponseKeys.results) as? [[String : AnyObject]] {
                    self.locations = ParseStudentLocation.locationsFromResults(results)
                    completionHandler( success: true, errorMessage: nil )
                } else {
                    completionHandler( success: false, errorMessage: Messages.downloadError )
                }
            } else {
                completionHandler( success: false, errorMessage: Messages.networkError )
            }
        }
    }
    
    func queryStudentLocation( uniqueKey: String, completionHandler: (results: [ParseStudentLocation]?, errorMessage: String?) -> Void ) {
        
        let urlString = "\(Constants.BaseURL)?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                if let results = JSONresults?.valueForKey(JSONResponseKeys.results) as? [[String : AnyObject]] {
                    let locations = ParseStudentLocation.locationsFromResults(results)
                    completionHandler( results: locations, errorMessage: nil )
                }
            } else {
                completionHandler( results: nil, errorMessage: Messages.downloadError )
            }
        }
    }
    
    func postStudentLocation( data: [String : AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.BaseURL)!)
        
        request.HTTPMethod = "POST"
        var jsonifyError: NSError? = nil
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.HTTPBody = nil
        }
        
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                completionHandler(success: true, errorMessage: nil)
            } else {
                completionHandler(success: false, errorMessage: Messages.postError)
            }
        }
    }
    
    func putStudentLocation( objectId: String, data: [String: AnyObject], completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        
        let urlString = "\(Constants.BaseURL)/\(objectId)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = "PUT"
        var jsonifyError: NSError? = nil
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(data, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.HTTPBody = nil
        }
        
        taskWithRequest(request) { JSONresults, error in
            if error == nil {
                completionHandler(success: true, errorMessage: nil)
            } else {
                completionHandler(success: false, errorMessage: Messages.postError)
            }
        }
    }
    
}
