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

let apikey = "AIzaSyAu-KEXCvMeRHXD7LLbjH-IrVIwdezI2vE";

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    var markerArray = [GMSMarker]()
    var mark = GMSMarker()
    var name = ""
    var nameArray = [NSString]()
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
      
        self.view = mapView
        mapView.delegate = self
        search.isHidden = true
        
        // get data from rec
        self.mark.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        self.mark.title = name
        self.name = name
        nameArray.append(name)
        mark.map = mapView
        markArray.append(mark)
        
      
        self.view.addSubview(topBar)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        

//        locationManager.startUpdatingLocation()
  
      
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        for name in nameArray{
            int count = 0
            for marker on markerArray{
                
                if name == marker.title{
                    marker.map = nil
                    markerArray.remove(at: count)
                    nameArray.remove(ar: count)
                    self.searchbar.searchTextField.resignFirstResponder()
                    return true
                }
                count += 1
            }
        }
        // no marker found
        
    }
    func locationManager(_manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          
        let location = locations.last
   
            let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude:(location?.coordinate.longitude)!, zoom:14)
            mapView.animate(to: camera)
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            marker.map = mapView
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
extension MapViewController{
      // 2
      func locationManager(_manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3
        guard status == .authorizedWhenInUse else {
          return
        }
        // 4
        locationManager.startUpdatingLocation()

        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
      }

}




