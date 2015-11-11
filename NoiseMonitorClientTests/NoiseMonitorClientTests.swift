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
    
    
    // MARK: JSON tests
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
        let json: JSON =  ["response": "observe", "value": ["value one", "value two"], "results": [["sensors": 1, "time": "TIME STAMP", "min": 1.1, "max": 3.3, "avg": 2.2]]]
        return json
    }
    
    func testCreateSampleObserveResponseJson() -> JSON {
        // let json: JSON =  ["response": "observe", "results": [["sensors": 1, "time": "2015-11-11 16:26:31", "avg":118.235294117647,"max":321.0,"min":1.0]]]
        let json: JSON = ["response":"observe","results":[["sensors":1,"time":"2015-11-11 17:22:11","avg":118.235294117647,"max":321.0,"min":1.0]]]
        return json
    }
    
    func testCreateGenericServerResponseNSData(json: JSON) -> NSData {
        do {
            return try! json.rawData() }
    }
    
    func testInitialiseServerResponseFromData(){
        let json = testCreateSampleObserveResponseJson()
        let data = testCreateGenericServerResponseNSData(json)
        let serverResponse = ServerResponse(failableFromJSONData: data)!
        assert(serverResponse.type == .Observe)
        for val in serverResponse.value {
            print(val)
        }
        //assert(serverResponse.value[0] == "value one")
        print(serverResponse.results.count)
        assert(serverResponse.results[0]!.time == "2015-11-11 17:22:11")
        assert(serverResponse.results[0]!.avg == 118.235294117647)
        for row in serverResponse.results {
            print("timestamp = \(row!.time), avg = \(row!.avg)")
        }
    
    }
    
    // MARK: CoAP/Networking Tests
    
    func testCreateObservePayload() {
        let testObservePayload = Utilities.createObservePayload(sensor: [1])
        print(testObservePayload)
    }
    

    
    
    
    
    
    
}
