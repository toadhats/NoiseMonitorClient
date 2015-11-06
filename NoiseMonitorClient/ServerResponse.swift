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
    case Observe
    case Response
    case Error
}

/**
 *  Pretty simple. I don't know what else we'd want to keep in here but hopefully we can discuss it on saturday??
 */
struct ServerResponse {
    var type: ResponseType
    var value: [String] // I'd like to have more confidence about types but that might not be practical
}
