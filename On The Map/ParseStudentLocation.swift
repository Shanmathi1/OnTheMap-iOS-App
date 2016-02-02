//
//  ParseStudentLocation.swift
//  On The Map
//
//  Created by Shanmathi Mayuram Krithivasan on 12/15/15.
//  Copyright © 2015 Shanmathi Mayuram Krithivasan. All rights reserved.
//

import Foundation

struct ParseStudentLocation: CustomStringConvertible {
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Float
    var longitude: Float
    
    var description: String {
        return "ParseStudentLocation: \(objectId)-\(uniqueKey)"
    }
    
    init( dictionary: [String : AnyObject] ) {
        objectId = dictionary[ParseUtility.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[ParseUtility.JSONResponseKeys.uniqueKey] as! String
        firstName = dictionary[ParseUtility.JSONResponseKeys.firstName] as! String
        lastName = dictionary[ParseUtility.JSONResponseKeys.lastName] as! String
        mapString = dictionary[ParseUtility.JSONResponseKeys.mapString] as! String
        mediaURL = dictionary[ParseUtility.JSONResponseKeys.mediaURL] as! String
        latitude = dictionary[ParseUtility.JSONResponseKeys.latitude] as! Float
        longitude = dictionary[ParseUtility.JSONResponseKeys.longitude] as! Float
    }
    
    static func locationsFromResults(results: [[String : AnyObject]]) -> [ParseStudentLocation] {
        var locations = [ParseStudentLocation]()
        
        for result in results {
            locations.append( ParseStudentLocation(dictionary: result) )
        }
        
        return locations
    }
    
}
