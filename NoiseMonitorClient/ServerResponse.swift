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
    case Observe = "observe"        /// A single row object
    case RowResponse = "rowResponse"   /// An array of one or more row objects
    case AggResponse = "aggResponse"    /// A single value (like a max or an average)
    case Error = "error"          /// A single value (An error message string)
}

/**
 *  A struct representing what is sent by the server in the payload field of each CoAP response
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
    
    /**
     Initialise from an NSData object, e.g. what we get out of the payload of a CoAP packet. The failable version is probably safer in most cases.
     
     - parameter jsonData: NSData containing JSON definitely containing a comprehensible packet from the server or else we crash, again
     
     - returns: a ServerResponse struct
     */
    init(fromJSONData jsonData: NSData) {
        let json = JSON(data: jsonData)
        type = ResponseType(rawValue:json["response"].stringValue) ?? ResponseType.Error
        value = []
        for subJSON in json["value"].arrayValue {
            value.append(subJSON.string)
        }
        results = []
        for subJSON in json["results"].arrayValue {
            do {
                let row = try DataRow(fromJSONData: subJSON.rawData() as NSData) ?? DataRow(sensor: "JSON INIT FAILED", time: "JSON INIT FAILED",  dataMin: -99.0, dataMax: -99.0, dataAvg: -99.0)
                results.append(row)
            } catch {
                print("Init failed while trying to get data rows out of JSON")
            }
        }
    }
    
    /**
     Failable version for when we don't trust our input, which is always
     
     - parameter jsonData: NSData that may or may not be parseable as a ServerResponse struct
     
     - returns: A ServerResponse, maybe.
     */
    init?(failableFromJSONData jsonData: NSData) {
        guard let json = JSON(data: jsonData) as JSON? else {return nil}
        print("Init got JSON: \(json.debugDescription)")
        NSLog("ServerResponse init deserialised JSON ok")
        NSLog("Json contains response string \(json["response"])")
        guard let optType = ResponseType(rawValue:json["response"].stringValue) else {
            type = .Error
            NSLog("ServerResponse init couldn't parse response type field")
            return nil
        }
        type = optType // For some reason the guard wasn't working with the actual instance variable?
        value = []
        for subJSON in json["value"].arrayValue {
            value.append(subJSON.string)
        }
        results = []
        for subJSON: JSON in json["results"].arrayValue {
            do {
                guard let row = try DataRow(failableFromJSONData: subJSON.rawData()) else {
                    NSLog("Failed to init a data row")
                    return nil}
                results.append(row)
            } catch {
                print("Init failed while trying to get data rows out of JSON")
                return nil
            }
        }
    }

}


struct DataRow {
    var sensor: String
    var time: String
    var min: Double
    var max: Double
    var avg: Double
    
    init(sensor: String, time: String, dataMin: Double, dataMax: Double, dataAvg: Double) {
        self.sensor = sensor
        self.time = time
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
        sensor = d["sensors"] as? String ?? "NO SENSOR"
        time = d["timeStart"] as? String ?? "NO TIME"
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
        sensor = json["sensors"].stringValue
        time = json["time"].stringValue
        min = json["min"].doubleValue
        max = json["max"].doubleValue
        avg = json["avg"].doubleValue
        
        
    }
    
    /**
     Failable version of NSData init, used when the NSData is suspect, e.g. always.
     
     - parameter jsonData: an NSData object that probably doesn't contain valid JSON data
     
     - returns: A questionable datarow
     */
    init?(failableFromJSONData jsonData: NSData) {
        let json = JSON(data: jsonData)
        guard let unwrappedSensor = json["sensors"].int else {print(1);return nil}
        sensor = String(unwrappedSensor)
        guard let unwrappedTime = json["time"].string else {print(2);return nil}
        time = unwrappedTime
        guard let unwrappedMin = json["min"].double else {print(3);return nil}
        min = unwrappedMin
        guard let unwrappedMax = json["max"].double else {print(4);return nil}
        max = unwrappedMax
        guard let unwrappedAvg = json["avg"].double else {print(5);return nil}
        avg = unwrappedAvg
        
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


