//
//  ViewController.swift
//  Final
//
//  Created by william haberkorn on 4/8/20.
//  Copyright © 2020 william haberkorn. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation


class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    var markerArray = [GMSMarker]()
    var name = String()
    var lat = Double()
    var lon = Double()
    var camera = GMSCameraPosition()
    var nameArray = [String]()
    @IBOutlet weak var search: UISearchBar! // link later
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    
    
    // this function actually removes things !!
    // i just dont wanna relink it ;)
    @IBAction func Add(_sender: Any) {

        
        // search bar appears and user can query
        if ( search.isHidden ){
            search.isHidden = false
        }
        else{
            search.isHidden = true
        }
        
    }
    @IBOutlet weak var mapView: GMSMapView!

    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        let camera = GMSCameraPosition.camera(withLatitude: 40.0, longitude: -73.99, zoom: 13.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.mapView = mapView
        self.view = mapView
        search.isHidden = true
        self.mapView?.isMyLocationEnabled = true
        self.mapView?.settings.myLocationButton = true;
        self.view.addSubview(topBar)
        
        // hard coded until rec view passes data
        let lat = 40.00
        let lon = -73.99
        let name = "john"
        let mark = GMSMarker()
        
        // get data from rec
        mark.position = CLLocationCoordinate2D(latitude: 40.00, longitude: -73.90)
//      self.mark.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        mark.title = name
        nameArray.append(name)
        mark.map = mapView
        markerArray.append(mark)
     
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
//
        self.locationManager.startUpdatingLocation()
//
      
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        for name in nameArray{
            var count = 0
            for marker in markerArray{
                
                if marker.title == name{
                    marker.map = nil
                    markerArray.remove(at: count)
                    nameArray.remove(at: count)
                    self.search.searchTextField.resignFirstResponder()
                    return true
                }
                count += 1
            }
        }
        // no marker found
        return false
    }
    func locationManager(_manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("Here")
        let location = locations.last

        let Marker = GMSMarker(position: (location?.coordinate)!)
        Marker.map = mapView
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
        self.mapView.animate(to: camera)
//            let marker = GMSMarker()
//            marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
//            marker.map = mapView
          self.locationManager.stopUpdatingLocation()
      
    }
    func fetchPlace(coordinate: CLLocationCoordinate2D, radius: Double, name : String){
        let  url = URL( string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apikey)&location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&rankby=prominence&sensor=true")
        let request = URLRequest(url: url!)
       URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data else {
            print("Session Error:", error ?? "nil")
            return
        }
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? NSDictionary {
            let results = jsonObject["results"] as? NSArray
            if results != nil {

                for index in 0..<results!.count {
                    if let results = results?[index] as? NSDictionary {
                        var placeName = ""
                        var latitude = 0.0
                        var longitude = 0.0
                        if let name = results["name"] as? NSString {
                        placeName = name as String
                        }
                        if let geometry = results["geometry"] as? NSDictionary {
                            if let location = geometry["location"] as? NSDictionary {
                                if let lat = location["lat"] as? Double {
                                    latitude = lat
                                }
                                if let lng = location["lng"] as? Double {
                                    longitude = lng
                                }
                            }
                        }
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
                        marker.title = placeName
                        marker.map = self.mapView
                        }
                }
            }
            }
        }catch {
            print("JSONSerialization error:", error)
        }
        }.resume()
                  
}

    
}
//extension MapViewController{
//      // 2
//      func locationManager(_manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        // 3
//        guard status == .authorizedWhenInUse else {
//          return
//        }
//        // 4
//        locationManager.startUpdatingLocation()
//
//        //5
//        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
//          NSLog("Here")
//      }
//
//}
