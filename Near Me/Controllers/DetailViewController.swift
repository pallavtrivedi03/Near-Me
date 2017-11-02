//
//  DetailViewController.swift
//  Near Me
//
//  Created by Pallav Trivedi on 31/10/17.
//  Copyright © 2017 Pallav Trivedi. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailViewController: UIViewController {

    
    @IBOutlet weak var simulationButton: UIButton!
    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapContainer: GMSMapView!
    var latitude = 0.0
    var longitude = 0.0
    var distance = ""
    var coordinatesCount = 0
    var endLocationsArray = [End_Location.init(latitude: 0.0, longitude: 0.0)]
    var carMarker:GMSMarker?
    var timerForAnimatingMarker:Timer?
    var selectedResult:Results = Results.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        let geometry = selectedResult.geometry
        latitude = (geometry?.location?.lat)!
        longitude = (geometry?.location?.lng)!
        simulationButton.setTitle("Simulate Travel", for: .normal)
        loadMap()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMap()
    {
        let camera = GMSCameraPosition.camera(withLatitude:latitude , longitude: longitude, zoom: 15.0)
        
        self.mapContainer.camera = camera
        self.mapContainer.delegate = self
        self.mapContainer.isMyLocationEnabled = true
        
        let path = GMSMutablePath()
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        marker.title = selectedResult.name!
        marker.snippet = selectedResult.vicinity!
        marker.map = self.mapContainer
        path.add(CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude))

        let userMarker = GMSMarker()
        userMarker.position = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
        userMarker.title = "You are here"
        userMarker.map = self.mapContainer
        userMarker.icon = GMSMarker.markerImage(with: .blue)
        
        let bounds = GMSCoordinateBounds(path: path)
        self.mapContainer.animate(with: GMSCameraUpdate.fit(bounds))
        self.mapContainer.animate(toZoom: 15)
        
        path.add(CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude))
        drawRoute()
        
    }
    
    func drawRoute()
    {
        let origin = "\(userLatitude),\(userLongitude)"
        let destination = "\(self.latitude),\(self.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyDmqp0mfpQ9wedqw_b584OUdOy_LNzg1PE"
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String : AnyObject]
                    let routes = json["routes"] as! NSArray
                    let route = routes[0] as! [String:Any]
                    let legs = route["legs"] as! NSArray
                    let leg = legs[0] as! [String:Any]
                    let distance = leg["distance"] as! [String:Any]
                    
                    
                    let steps = leg["steps"] as! NSArray
                    self.endLocationsArray.remove(at: 0)
                    
                    for step in steps
                    {
                        let stepDict = step as! [String:Any]
                        let endLocationDict = stepDict["end_location"] as! [String:Any]
                        let endLocation = End_Location.init(latitude: endLocationDict["lat"] as! Double, longitude: endLocationDict["lng"] as! Double)
                        self.endLocationsArray.append(endLocation)
                    }
                    self.distance = distance["text"] as! String
                    //mapView.clear()
                    
                    self.initialiseInfoView()
                    
                    OperationQueue.main.addOperation({
                        for route in routes
                        {
                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
                            let points = routeOverviewPolyline.object(forKey: "points")
                            let somePath = GMSPath.init(fromEncodedPath: points! as! String)
                            let polyline = GMSPolyline.init(path: somePath)
                            polyline.strokeWidth = 3
                            polyline.strokeColor = #colorLiteral(red: 0.2068593099, green: 0.4246368585, blue: 0.7947763005, alpha: 1)
                            
                            let bounds = GMSCoordinateBounds(path: somePath!)
                            self.mapContainer.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
                            
                            polyline.map = self.mapContainer
                            
                        }
                    })
                }catch let error as NSError{
                    print("error:\(error)")
                }
            }
        }).resume()
        
    }
    
    func initialiseInfoView()
    {
        DispatchQueue.main.async
            {
            self.nameLabel.text = self.selectedResult.name
            self.ratingLabel.text = (self.selectedResult.rating != nil) ? String(describing: self.selectedResult.rating!) : "NA"
            self.addressLabel.text = (self.selectedResult.vicinity != nil) ? String(describing: self.selectedResult.vicinity!) : "NA"
            self.distanceLabel.text = self.distance
        }
    
        if let photoRef = selectedResult.photos?[0].photo_reference
        {
            let imageUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoRef)&key=AIzaSyDmqp0mfpQ9wedqw_b584OUdOy_LNzg1PE"
            ApplicationController.sharedInstance.webServiceHelper?.downloadImageFromURL(url: imageUrl, completionHandler: { (image) in
                DispatchQueue.main.async
                    {
                        self.siteImageView.image = image
                }
            })
        }
    }
    
   
    @IBAction func didClickOnSimulateButton(_ sender: UIButton)
    {
        if simulationButton.titleLabel?.text == "Simulate Travel"
        {
            simulationButton.setTitle("Stop Simulation", for: .normal)
            carMarker = GMSMarker()
            carMarker?.position = CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude)
            carMarker?.title = "On the way"
            carMarker?.map = self.mapContainer
            carMarker?.icon = #imageLiteral(resourceName: "Car")
             animateMarkerToDestination(destinationLatitude: endLocationsArray[0].lat!,destinationLatitudeLongitude: endLocationsArray[0].long!)
            
        }
        else
        {
            simulationButton.setTitle("Simulate Travel", for: .normal)
            carMarker?.map = nil
            coordinatesCount = 0
        }
    }
    
    func animateMarkerToDestination(destinationLatitude:Double,destinationLatitudeLongitude:Double)
    {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1)
            carMarker?.position = CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLatitudeLongitude)
            CATransaction.commit()
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                print("That took a second")
                self.coordinatesCount += 1
                if self.coordinatesCount < self.endLocationsArray.count
                {
                self.animateMarkerToDestination(destinationLatitude: self.endLocationsArray[self.coordinatesCount].lat!, destinationLatitudeLongitude: self.endLocationsArray[self.coordinatesCount].long!)
                }
                else
                {
                    return
                }
                
            })
            
        }
}

extension DetailViewController:GMSMapViewDelegate
{
    
}

class End_Location
{
    var lat:Double?
    var long:Double?
    
    init(latitude:Double,longitude:Double)
    {
        lat = latitude
        long = longitude
    }
}
