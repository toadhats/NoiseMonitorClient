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
    var results: [DataRow?]
    
    // This doesn't work and i have no idea why
    init(fromDictionary d: Dictionary<String, AnyObject?>) {
        // Provide default values to prevent tears. If we ever see these something broke.
        type = ResponseType(rawValue: (d["type"] as! String)) ?? ResponseType.Error
        value = d["value"] as? [String?] ?? ["Error: Could not parse value in NSDictionary"]
        if let rowData = d["results"] {
            results = dataRowArray(rowData) as [DataRow?] // I think the DataRow init will protect us from this case being totally nil??
        } else {
            results = []
        }
    }
    
    init(fromJSONData jsonData: NSData) {
        let json = JSON(data: jsonData)
        type = ResponseType(rawValue:json["type"].stringValue) ?? ResponseType.Error
        value = []
        for subJSON in json["value"].arrayValue {
            value.append(subJSON.string)
        }
        results = []
        for subJSON in json["results"].arrayValue {
            do {
                let row = try DataRow(fromJSONData: subJSON.rawData() as NSData) ?? DataRow(sensor: "JSON INIT FAILED", timeStart: "JSON INIT FAILED", timeEnd: "JSON INIT FAILED", dataMin: -99.0, dataMax: -99.0, dataAvg: -99.0)
                results.append(row)
            } catch {
                print("Init failed while trying to get data rows out of JSON")
            }
        }
    }
}


struct DataRow {
    var sensor: String
    var timeStart: String
    var timeEnd: String
    var min: Double
    var max: Double
    var avg: Double
    
    init(sensor: String, timeStart: String, timeEnd: String, dataMin: Double, dataMax: Double, dataAvg: Double) {
        self.sensor = sensor
        self.timeStart = timeStart
        self.timeEnd = timeEnd
        self.min = dataMin
        self.max = dataMax
        self.avg = dataAvg
    }
    
    /**
     Initialises a DataRow from a Swift dictionary.
     
     I can turn the date strings into swift date objects using the following:
     let timeStartDate = NSDate.date(fromString: timeStart, format: DateFormat.Custom("yyyy/M/d HH:MM.SS"))

     
     - parameter d: a dictionary with elements corresponding to DataRow properties
     
     - returns: a DataRow
     */
    init(fromDictionary d: Dictionary<String, AnyObject?>) {
        sensor = d["sensor"] as? String ?? "NO SENSOR"
        timeStart = d["timeStart"] as? String ?? "NO START TIME"
        timeEnd = d["timeEnd"] as? String ?? "NO END TIME"
        min = d["min"] as? Double ?? -1.0
        max = d["max"] as? Double ?? -1.0
        avg = d["avg"] as? Double ?? -1.0
    }
    
    /**
     Initialises a DataRow from raw NSData (Assuming that raw data happens to be UTF-8 formatted JSON). 
     Note that it takes the data straight from the payload, NOT an already deserialised JSON object
     
     - parameter jsonData: an NSData object from a CoAP payload, ideally containing UTF-8 formatted JSON
     
     - returns: a DataRow object ready for handling
     */
    init(fromJSONData jsonData: NSData) {
        let json = JSON(data: jsonData)
        sensor = json["sensor"].stringValue
        timeStart = json["timeStart"].stringValue
        timeEnd = json["timeEnd"].stringValue
        min = json["min"].doubleValue
        max = json["max"].doubleValue
        avg = json["avg"].doubleValue
        
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


