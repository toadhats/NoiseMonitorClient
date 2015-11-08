//
//  ServerResponse.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 6/11/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import Foundation
import SwiftyJSON

/**
 *  Response types: Observe , Result, Error. We use this info to decide what to do with a packet, e.g to help in a situation where we get an observe update while waiting for a seperate query reponse. Error allows us to determine whether a query failed and respond accordingly, else process the response as valid.
 */
enum ResponseType: String{
    case Observe = "Observe"        /// A single row object
    case RowResponse = "RowResponse"   /// An array of one or more row objects
    case AggResponse = "AggResponse"    /// A single value (like a max or an average)
    case Error = "Error"          /// A single value (An error message string)
}

/**
 *  Pretty simple. I don't know what else we'd want to keep in here but hopefully we can discuss it on saturday??
 */
struct ServerResponse {
    var type: ResponseType
    var value: [String?] // I'd like to have more confidence about types but that might not be practical
    var rows: [DataRow?]
    
    // This doesn't work and i have no idea why
    init(fromDictionary d: Dictionary<String, AnyObject?>) {
        // Provide default values to prevent tears. If we ever see these something broke.
        type = ResponseType(rawValue: (d["type"] as! String)) ?? ResponseType.Error
        value = d["value"] as? [String?] ?? ["Error: Could not parse value in NSDictionary"]
        if let rowData = d["rows"] {
        rows = dataRowArray(rowData) as [DataRow?] // I think the DataRow init will protect us from this case being totally nil??
        } else {rows = []}
    }
    
    init(fromJSONData jsonData: NSData) {
        let json = JSON(data: jsonData)
        type = ResponseType(rawValue:json["type"].stringValue) ?? ResponseType.Error
        value = []
        for subJSON in json["value"].arrayValue {
            value.append(subJSON.string)
        }
        rows = []
        for subJSON in json["rows"].arrayValue {
            do {
            let row = try DataRow(fromJSONData: subJSON.rawData() as NSData) ?? DataRow(timestamp: "NO TIMESTAMP", data: "NO DATA")
            rows.append(row)
            } catch {
                print("Failed while trying to get data rows out of JSON")
            }
        }
    }
}


struct DataRow {
    var timestamp: String
    var data: String
    
    init(timestamp: String, data: String) {
        self.timestamp = timestamp
        self.data = data
    }
    
    init(fromDictionary d: Dictionary<String, AnyObject?>) {
        timestamp = d["timestamp"] as? String ?? "NO TIMESTAMP"
        data = d["data"] as? String ?? "NO ROW DATA"
    }
    
    init(fromJSONData jsonData: NSData) {
        let json = JSON(data: jsonData)
        timestamp = json["timestamp"].stringValue
        data = json["data"].stringValue
    }
    
}

/**
 Takes the data that will be found in ServerResponse.rows and turns it into a [DataRow]
 
 - parameter rowArrayObject: the object corresponding to d["rows"] in a ServerResponse
 
 - returns: an array of DataRows, each initialised according to what we find in the array
 */
func dataRowArray(rowArrayObject: AnyObject?) -> [DataRow?] {
    var rows: [DataRow?] = []
    if let rowArray: [Dictionary<String,AnyObject>] = rowArrayObject as? NSArray as? [Dictionary<String,AnyObject>] {
        for row in rowArray {
           let dataRow = DataRow(fromDictionary: row)
            rows.append(dataRow)
        }
    }
 return rows
}

/**
 Takes a JSON object (as NSData) and returns a Dictionary<String, AnyObject>. Doesn't work at all, spent 4 hours debugging it, gave up.
 
 - parameter json: JSON data as NSData, which we get from the payload of a coap response
 
 - returns: A generic Dictionary<String, AnyObject> to be passed into the ServerResponse initialiser.
 */
func dictFromJSON(payload json: NSData) -> Dictionary<String,AnyObject?> {
    do {
        if let dict = try NSJSONSerialization.JSONObjectWithData(json, options: NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject?> {
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
