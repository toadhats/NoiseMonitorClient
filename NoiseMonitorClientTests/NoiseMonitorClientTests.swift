//
//  NoiseMonitorClientTests.swift
//  NoiseMonitorClientTests
//
//  Created by Jonathan Warner on 8/11/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import NoiseMonitorClient

class NoiseMonitorClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateGenericJson() {
        var json: JSON =  ["name": "Jack", "age": 25, "list": ["a", "b", "c", ["what": "this"]]]
        assert(json["name"].stringValue == "Jack")
        assert(json["age"].int! == 25)
        assert(json["age"].double! == 25)
        assert(json["list"][0].stringValue == "a")
        assert(json["list"][1].stringValue == "b")
        assert(json["list"][2].stringValue == "c")
        assert(json["list"][3]["what"] == "this")
    }
    
    func testCreateGenericServerResponseJson() -> JSON {
        let json: JSON =  ["type": "Error", "value": ["value one", "value two"], "rows": [["timestamp": "TIMESTAMP", "data": "ROW DATA"]]]
        return json
    }
    
    func testCreateGenericServerResponseNSData(json: JSON) -> NSData {
        do {
            return try! json.rawData() }
    }
    
    func testInitialiseServerResponseFromData(){
        let json = testCreateGenericServerResponseJson()
        let data = testCreateGenericServerResponseNSData(json)
        let serverResponse = ServerResponse(fromJSONData: data)
        assert(serverResponse.type == .Error)
        for val in serverResponse.value {
            print(val)
        }
        assert(serverResponse.value[0] == "value one")
        print(serverResponse.rows.count)
        assert(serverResponse.rows[0]!.timestamp == "TIMESTAMP")
        assert(serverResponse.rows[0]!.data == "ROW DATA")
        for row in serverResponse.rows {
            print("timestamp = \(row!.timestamp), data = \(row!.data)")
        }
        
        

        
    }
    
    
    
    
}
