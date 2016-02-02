//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 12/15/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    struct Constants {
        static let BaseURL : String = "https://www.udacity.com/api/"
    }
    
    struct Methods {
        static let Session = "session"
        static let User = "users/"
    }
    
    struct Messages {
        static let loginError = "Udacity Login failed. Incorrect username or password"
        static let networkError = "Error connecting to Udacity."
    }
    
}