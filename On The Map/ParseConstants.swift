//
//  ParseConstants.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 12/15/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import Foundation

extension ParseUtility {
    struct Constants {
        static let BaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
        static let AppID: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let APIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    struct Messages {
        static let downloadError = "Error downloading student data"
        static let networkError = "Error connecting to server"
        static let postError = "Error posting student location data."
    }
    
    struct JSONResponseKeys {
        //GET and QUERY
        static let results: String = "results"
        static let error: String = "error"
        
        static let objectId: String = "objectId"
        static let uniqueKey: String = "uniqueKey"
        static let firstName: String = "firstName"
        static let lastName: String = "lastName"
        static let mapString: String = "mapString"
        static let mediaURL: String = "mediaURL"
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        
        //POST
        static let createdAt: String = "createdAt"
        
        //PUT
        static let updatedAt: String = "updatedAt"
    }
}
