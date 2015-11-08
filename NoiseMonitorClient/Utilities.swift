//
//  Utilities.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 9/11/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import Foundation
import SwiftyJSON


/// I don't know if this design pattern is frowned upon, but because I'm doing unit testing I think I need to organise all my pure functions in here.
class Utilities {
    
    /**
     Creates an observe request for a given sensor ID
     
     - parameter sensor: sensor ID number
     */
    static func createObservePacket(sensor sensor: [String]) -> NSData {
        let json: JSON = ["request": "Observe", "sensors": "\(sensor)", "parameters": ""]
        return try! json.rawData()
    }
    
}
