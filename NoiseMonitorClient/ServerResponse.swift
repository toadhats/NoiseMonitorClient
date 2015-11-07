//
//  ServerResponse.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 6/11/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import Foundation

/**
 *  Response types: Observe , Result, Error. We use this info to decide what to do with a packet, e.g to help in a situation where we get an observe update while waiting for a seperate query reponse. Error allows us to determine whether a query failed and respond accordingly, else process the response as valid.
 */
enum ResponseType{
    case Observe        /// A single row object
    case RowResponse    /// An array of one or more row objects
    case AggResponse    /// A single value (like a max or an average)
    case Error          /// A single value (An error message string)
}

/**
 *  Pretty simple. I don't know what else we'd want to keep in here but hopefully we can discuss it on saturday??
 */
struct ServerResponse {
    var type: ResponseType
    var value: [String] // I'd like to have more confidence about types but that might not be practical
    var rows: [DataRow]
    
    init(fromDictionary d: NSDictionary) {
        // Provide default values to prevent tears. If we ever see these something broke.
        type = d["type"] as? ResponseType ?? ResponseType.Error
        value = d["value"] as? [String] ?? ["Error: Could not parse value in NSDictionary"]
        rows = dataRowArray(d["rows"]) ?? [] // I think the DataRow init will protect us from this case anyway??
    }
    
}


struct DataRow {
    var timestamp: String
    var data: String
    
    init(fromDictionary d: NSDictionary) {
        timestamp = d["timestamp"] as? String ?? "NO TIMESTAMP"
        data = d["data"] as? String ?? "NO ROW DATA"
    }
    
}

/**
 Takes the data that will be found in ServerResponse.rows and turns it into a [DataRow]
 
 - parameter rowArrayObject: the object corresponding to d["rows"] in a ServerResponse
 
 - returns: an array of DataRows, each initialised according to what we find in the array
 */
func dataRowArray(rowArrayObject: AnyObject?) -> [DataRow] {
    var rows: [DataRow] = []
    if let rowArray: [Dictionary<String,AnyObject>] = rowArrayObject as? NSArray as? [Dictionary<String,AnyObject>] {
        for row in rowArray {
           let dataRow = DataRow(fromDictionary: row)
            rows.append(dataRow)
        }
    }
 return rows
}

/**
 Takes a JSON object (as NSData) and returns a Dictionary<String, AnyObject>
 
 - parameter json: JSON data as NSData, which we get from the payload of a coap response
 
 - returns: A generic Dictionary<String, AnyObject> to be passed into the ServerResponse initialiser.
 */
func dictFromJSON(payload json: NSData?) -> Dictionary<String,AnyObject> {
    do {
        if let dict = try NSJSONSerialization.JSONObjectWithData(json!, options: NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
            return dict
        } else {
            print("Couldn't initialise dictionary from JSON, returning empty dictionary")
            return Dictionary<String,AnyObject>() // Empty dict seems better than just crashing? As long as we print an error message
        }
    } catch _ {
        print("Error parsing JSON")
        return Dictionary<String,AnyObject>() // Empty dict seems better than just crashing? As long as we print an error message
    }
}
