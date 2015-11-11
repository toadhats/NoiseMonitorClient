//
//  SecondViewController.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 20/10/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import UIKit
import Eureka

class QueryViewController: FormViewController, SCClientDelegate {
    
    var client: SCClient? // Nil until we get a reference to it.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Eureka form setup code
        
        // Begin custom operator bullshit lmao (Eureka dynamic form library)
        form  = // Creates the form
            
            Section()
            
            <<< LabelRow () {
                //$0.cell.backgroundColor = .colorWithWhite(0.1, alpha: 1)
                $0.cell.textLabel!.textAlignment = .Center
                $0.cell.textLabel?.font = UIFont.italicSystemFontOfSize(18)
                //$0.cell.textLabel?.textColor = .yellowColor()
                $0.title = "Configure a custom query"

                
                    
                }.cellSetup({cell, row in
                    cell.backgroundColor = .redColor() })
                .cellUpdate({ (cell, row) -> () in
                        cell.textLabel?.textColor = .yellowColor()
                    })
            
            +++ Section("Detail Level")
            
            <<< ActionSheetRow<String>() { // Pushes a row into the form
                //$0.title = "Detail"
                $0.selectorTitle = "Return all the data, or a summary?"
                $0.options = ["All", "Summary"]
                $0.value = "Summary"
            }

            
            +++ Section("What do you want to know?") // Adds a section to the form
            
            <<< ActionSheetRow<String>() { // Pushes a row into the form
                //$0.title = "Query"
                $0.selectorTitle = "Specify the type of query"
                $0.options = ["Average", "Max", "Min"] // I should really be able to dynamically build and store this array by asking the server what is available
                $0.value = "Average"
                }
    
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



