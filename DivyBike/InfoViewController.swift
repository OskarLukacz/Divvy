//
//  InfoViewController.swift
//  DivyBike
//
//  Created by Oskar Lukacz on 1/31/17.
//  Copyright © 2017 MobileMakers. All rights reserved.
//

import Foundation
import UIKit

class InfoTableView: UITableViewController

{
    
    var infoTable = Info()
    var infoIndex = NSIndexPath()
    
    var infoArray = [String]()
    var textArray = [String]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = infoTable.stationName[infoIndex.row]
        
        infoArray = [infoTable.status[infoIndex.row], String(infoTable.availableBikes[infoIndex.row]), String(infoTable.availableDocks[infoIndex.row]), String(infoTable.totalDocks[infoIndex.row]), infoTable.communicationTime[infoIndex.row]]
        
        textArray = ["Status", "Bikes Available", "Docks Available", "Total Docks", "Communication Time"]
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return infoArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell")!
        
        cell.textLabel?.text = textArray[indexPath.row]
        cell.detailTextLabel?.text = infoArray[indexPath.row]

        return cell
    }
}
