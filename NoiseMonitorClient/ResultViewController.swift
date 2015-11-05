//
//  ResultViewController.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 5/11/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//
import UIKit

class ResultViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let resultType: ResultType = .SingleValue // result type based on the query that sent us here, define in segue somehow
        switch resultType {
        case .SingleValue:
            // what we do if we get a single value type query
            print("Draw a single value display")
        case .ChartValues:
            // what we do if we have values over time to chart
            print("Configure a chart view with ios-charts")
        }
        
    }
    


}

enum ResultType {
    // The different types of results.
    // Result type determines how to draw this whole view
    case SingleValue // For queries that can be condensed to a single value
    
    case ChartValues // For a series of values over time that should be charted
}

