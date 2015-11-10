//
//  SecondViewController.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 20/10/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import UIKit
import Eureka

class QueryViewController: UIViewController, SCClientDelegate {
    
    var client: SCClient? // Nil until we get a reference to it.

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        // Take responsibility for incoming CoAP packets
        client?.delegate = self
    }
    
    // MARK: SCClientDelegate responsibilities
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
        print("ping")
    }


}

