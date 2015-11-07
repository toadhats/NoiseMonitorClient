//
//  FirstViewController.swift
//  NoiseMonitorClient
//
//  Created by Jonathan Warner on 20/10/2015.
//  Copyright © 2015 Jonathan Warner. All rights reserved.
//

import UIKit
import Charts

class LiveViewController: UIViewController, SCClientDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    var months: [String]! // testing delete
    var client: SCClient? // Nil until we get a reference to it.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Since this is the first view, we're going to just grab the SCClient. I know this is bad. I'm sorry.
        let appDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate // I feel like this is safe to force cast
        client = appDelegate.coapClient
        // Now we have a reference to the coap client we can use to send requests

        // ***testing delete***
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        setChart(months, values: unitsSold)
        // ***end testing***
    }
    
    /**
     Whenever this view appears, lets just send a fresh observe request. It would be nice if I could automatically deregisted on disappear, but I never got that working.
     
     - parameter animated: whether or not the appearance is animated, doesn't concern us here.
     */
    override func viewDidAppear(animated: Bool) {
        
        // Get the server hostname etc from the UserDefaults
        let defaults = NSUserDefaults.standardUserDefaults()
        let hostName = defaults.stringForKey("serverHostName") ?? "localhost"
        let hostPort = defaults.integerForKey("serverPort") ?? 5683
        
        print("Trying to send an observe request")
        let m = SCMessage(code: SCCodeValue(classValue: 0, detailValue: 01)!, type: .Confirmable, payload: "test".dataUsingEncoding(NSUTF8StringEncoding))
        let zeroByte: [UInt8] = [0x0] // this shouldn't be necessary but nothing else worked
        m.addOption(SCOption.Observe.rawValue, data: NSData(bytes: (zeroByte), length: 1)) // Adding the observe option (value of 0) -- This stopped working for some reason. Swift update? I just want to send a value of zero...
        client?.sendCoAPMessage(m, hostName: hostName, port: UInt16(hostPort))
        // Observe request sent, assuming we actually have a reference to the client
    }
    
    // MARK: SCClientDelegate responsibilities
    func swiftCoapClient(client: SCClient, didReceiveMessage message: SCMessage) {
    
    }
    
    // MARK: Chart
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = ";-; No data ;-;"
        barChartView.noDataTextDescription = "Are we connected to a sensor?"
        
        var dataEntries: [BarChartDataEntry] = [] // An array of objects representing individual datapoints
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i) // Make a data entry object
            dataEntries.append(dataEntry) // And insert it into the array
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold") // Pass all these entries into the chart, map to y axis, add axis label
        let chartData = BarChartData(xVals: months, dataSet: chartDataSet) // this is kinda weird, how the x and y axes aren't really connected? Have to be careful with this or it'll cause some aggravating bug no doubt.
        barChartView.data = chartData // We give the chart itself the data now
        
        barChartView.descriptionText = "" // We don't want description text
        chartDataSet.colors = ChartColorTemplates.vordiplom() // [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)] // how to customise colours
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0) // How to animate a chart
        
        let ll = ChartLimitLine(limit: 10.0, label: "Target") // How to create a "limit line"
        barChartView.rightAxis.addLimitLine(ll) // how to draw the limit line on the chart
    }
    
    
}

