//
//  ViewController.swift
//  DivyBike
//
//  Created by Robert D. Brown on 7/14/15.
//  Copyright (c) 2015 MobileMakers. All rights reserved.
//

import UIKit
import MapKit

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.0
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet weak var segementedController: UISegmentedControl!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var myMapView: MKMapView!
    
    var locationMenager = CLLocationManager()
    
    var listOfStations = NSArray()
    var pinArray = [MKPointAnnotation]()
    var pinPoint = NSIndexPath()
    var indexPathSegue = NSIndexPath()
    
    var info = Info()
    
    var tableFlag = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableFlag = 0
        
        myTableView.dataSource = self
        
        locationMenager.delegate = self
        
        getJSONData()
        
        locationMenager.requestWhenInUseAuthorization()
        
        myMapView.showsUserLocation = true
        
        zoomIn()
        
    
    }
    
    func zoomIn()
    {
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let center = CLLocationCoordinate2DMake(41.89373984, -87.63532979)
        let region = MKCoordinateRegion(center: center, span: coordinateSpan)
        myMapView.setRegion(region, animated: true)
    }
    
    func getJSONData()
    {
        let urlString = "http://www.divvybikes.com/stations/json/"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let queue:OperationQueue = OperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response, data, error) in
            
            do {
                let results = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                
                let cur = (results as AnyObject).object(forKey: "stationBeanList") as! NSArray
                self.listOfStations = NSMutableArray()
                self.listOfStations.addingObjects(from: cur as! [Any])
                self.createStations()
                self.getInfo()
                self.myTableView.reloadData()
                
            } catch {
                print("error serializing JSON: \(error)")
            }
            
        }
    }
    
    func createStations()
    {
        
        pinArray = []
        
        for station in listOfStations
        {
            let currentStation = station as! NSDictionary
            let latitude = currentStation.object(forKey: "latitude") as! CLLocationDegrees
            let longitude = currentStation.object(forKey: "longitude") as! CLLocationDegrees
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let myAnnotation = MKPointAnnotation()
            myAnnotation.coordinate = coordinate
            myAnnotation.title = (currentStation.object(forKey: "stationName") as! String)
            pinArray.append(myAnnotation)
        }
        myMapView.addAnnotations(pinArray)
    }
    
    func getInfo()
    {
        info.availableBikes = []
        info.availableDocks = []
        info.communicationTime = []
        info.stationName = []
        info.status = []
        info.totalDocks = []
        
        for station in listOfStations
        {
            let currentStation = station as! NSDictionary
            
            let stationName = currentStation.object(forKey: "stationName") as! String ; info.stationName.append(stationName)
            let status = currentStation.object(forKey: "statusKey") as! Int ; if status == 1 {info.status.append("In Service")} else {info.status.append("Not In Service")}
            let totalDocks = currentStation.object(forKey: "totalDocks") as! Int ; info.totalDocks.append(totalDocks)
            let availableDocks = currentStation.object(forKey: "availableDocks") as! Int ; info.availableDocks.append(availableDocks)
            let availableBikes = currentStation.object(forKey: "availableBikes") as! Int ; info.availableBikes.append(availableBikes)
            let communicationTime = currentStation.object(forKey: "lastCommunicationTime") as! String ; info.communicationTime.append(String(communicationTime.characters.dropFirst(11)))
            
        }
    }
    
    @IBAction func onSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            myMapView.isHidden = true
            myTableView.isHidden = false
            
            
        default:
            myMapView.isHidden = false
            myTableView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
     return listOfStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")! as UITableViewCell
        
        let currentStation = listOfStations[indexPath.row] as! NSDictionary
        
        cell.textLabel?.text = currentStation.object(forKey: "stationName") as? String
            
        return cell
        

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        if pin.annotation!.coordinate.latitude != mapView.userLocation.coordinate.latitude && pin.annotation!.coordinate.longitude != mapView.userLocation.coordinate.longitude
        {
        pin.canShowCallout = true
        return pin
        }
        
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        segementedController.selectedSegmentIndex = 1
        myMapView.isHidden = false
        myTableView.isHidden = true
        
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let center = CLLocationCoordinate2DMake(pinArray[indexPath.row].coordinate.latitude, pinArray[indexPath.row].coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: coordinateSpan)
        myMapView.setRegion(region, animated: true)
        myMapView.selectAnnotation(pinArray[indexPath.row], animated: true)
        pinPoint = indexPath as NSIndexPath
        
    }
    
    @IBAction func longPress(_ sender: Any)
    {
        if (sender as AnyObject).state == UIGestureRecognizerState.began
        {
            
            let location = (sender as AnyObject).location(in: (sender as AnyObject).view)
            
            if let indexPath = myTableView.indexPathForRow(at: location)
            {
                indexPathSegue = indexPath as NSIndexPath
                self.performSegue(withIdentifier: "infoSegue", sender: self)

            }
            
        }
    }
    
    func sortStations()
    {
        let user = myMapView.userLocation.coordinate
        
        let userLatitude = user.latitude 
        let userLongitude = user.longitude 
        
        var stationArray = [String:Double]()
        
        for station in listOfStations
        {
            let currentStation = station as! NSDictionary
            let latitude = currentStation.object(forKey: "latitude") as! Double
            let longitude = currentStation.object(forKey: "longitude") as! Double
            let stationName = currentStation.object(forKey: "stationName") as! String
            let laDistance = (latitude - userLatitude) * (latitude - userLatitude)
            let loDistance = (longitude - userLongitude) * (longitude - userLongitude)
            let distance = sqrt(laDistance+loDistance)
            
            stationArray["\(stationName)"] = distance
            
        }
        
        let sortedKeys = Array(stationArray.values).sorted(by: <)
        
        var stationNameArray = [String]()
        
        for stations in sortedKeys
        {
            
            if let key = stationArray.someKey(forValue: stations)
            {
                stationNameArray.append(key)
            }
        }
        
        let workingStations:NSMutableArray = []
        
        for stationName in stationNameArray
        {
            for station in listOfStations
            {
                let currentStation = station as! NSDictionary
                
                
                
                let currentStationName = currentStation.object(forKey: "stationName") as! String
                
                if currentStationName == stationName
                {
                    workingStations.adding(currentStation)
                    print("added")
                }
            }
        }
        
        listOfStations = []
        listOfStations.addingObjects(from: workingStations as! [Any])
        self.createStations()
        self.getInfo()
        print(info.stationName)
        self.myTableView.reloadData()
       
        
    }
    
    @IBAction func refresh(_ sender: Any) {
        sortStations()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destination = segue.destination as! InfoTableView
        
        destination.infoTable = info
        destination.infoIndex = indexPathSegue

    }
    
}

