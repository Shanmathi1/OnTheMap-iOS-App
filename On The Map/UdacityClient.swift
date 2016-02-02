//
//  UdacityClient.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 12/15/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    //Singleton
    static let sharedInstance = UdacityClient()
    
    var userID: String?
    var name: Name?
    
    struct Name {
        var first = ""
        var last = ""
        var fullname: String {
            return "\(first) \(last)"
        }
    }
    
    override init() {
        super.init()
    }
    
    func requestForMethod( method: String ) -> NSMutableURLRequest {
        let urlString = Constants.BaseURL + method
        let URL = NSURL(string: urlString)!
        
        return NSMutableURLRequest(URL: URL)
    }
    
    func taskWithRequest( request: NSURLRequest, completionHandler: (results: AnyObject?, error: NSError?) -> Void ) -> NSURLSessionTask {
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest( request ) { (data, response, error) in
            if error == nil {

                let trimmedData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                UtilityClass.parseJSONWithCompletionHandler(trimmedData, completionHandler: completionHandler)
            } else {
                //Error
                completionHandler(results: nil, error: error)
            }
        }
        task.resume()
        return task
    }
    
    
    func loginWithUsername(username: String, password: String, completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let request = requestForMethod(Methods.Session)
        
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        taskWithRequest( request ) { result, error in
            if error == nil {
                if let account = result!.valueForKey("account") as? NSDictionary {
                    if let userID = account.valueForKey("key") as? String {
                        self.userID = userID
                        self.getUserData( userID ) { success, errorMessage in
                            if( success ) {
                                print( "Name: \(self.name!.fullname)" )
                            } else {
                                print( "Error: \(errorMessage)" )
                            }
                        }
                        
                        completionHandler(success: true, errorMessage: nil)
                    } else {
                        completionHandler(success: false, errorMessage: Messages.loginError)
                    }
                } else {
                    completionHandler(success: false, errorMessage: Messages.loginError)
                }
            } else {
                completionHandler(success: false, errorMessage: Messages.networkError)
            }
        }
    }
    
    func logout( completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let request = requestForMethod(Methods.Session)
        
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies!  {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskWithRequest(request) { result, error in
            if error == nil {
                self.userID = nil
                completionHandler(success: true, errorMessage: nil)
            } else {
                completionHandler(success: false, errorMessage: Messages.networkError)
            }
        }
    }
    
    func getUserData(userID: String, completionHandler: (success: Bool, errorMessage: String?) -> Void ) {
        let request = requestForMethod(Methods.User + userID)
        request.HTTPMethod = "GET"
        
        taskWithRequest(request) { result, error in
            if error == nil {
                if let user = result!.valueForKey("user") as? NSDictionary {
                    self.name = Name()
                    
                    if let last_name = user.valueForKey("last_name") as? String{
                        self.name?.last = last_name
                    }
                    
                    if let first_name = user.valueForKey("first_name") as? String{
                        self.name?.first = first_name
                    }
                    completionHandler(success: true, errorMessage: nil)
                }
            } else {
                completionHandler(success: false, errorMessage: Messages.networkError)
            }
        }
        
    }
    
}

