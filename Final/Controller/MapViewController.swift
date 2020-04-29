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


class MapViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate, UISearchBarDelegate {
    var markerArray = [GMSMarker]()
    var searchActive = true
    var name = String()
    var lat = Double()
    var lon = Double()
    var nameArray = [String]()
    var didFindMyLocation = false
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var enter: UIButton!
    
    // this function actually removes things !!
    // i just dont wanna relink it ;)
    @IBAction func Add(_sender: Any) {

        
        // search bar appears and user can query
        if ( search.isHidden ){
            search.searchTextField.text?.removeAll()
            search.isHidden = false
            enter.isHidden = false
            addButton.setTitle("Cancel", for: .normal)
        }
        else{
            search.isHidden = true
            enter.isHidden = true
            addButton.setTitle("Edit", for: .normal)
        }
        
    }
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.showsCancelButton = false
        search.delegate = self
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
          locationManager.requestLocation()
          mapView.isMyLocationEnabled = true
          mapView.settings.myLocationButton = true
        } else {
          locationManager.requestWhenInUseAuthorization()
        }
        mapView.delegate = self
        search.searchTextField.delegate = self
        search.isHidden = true
        enter.isHidden = true
        mapView.addSubview(search)
        mapView.addSubview(enter)
        search.becomeFirstResponder()
        self.view.addSubview(mapView)
        self.view.addSubview(topBar)
        // hard coded until rec view passes data
        let lat = 40.73
        let lon = -73.95
        let name = "john"

        placeMark(latitude: lat, longitude: lon, title: name)
      
     
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()

    }
    func placeMark(latitude: Double, longitude: Double, title: String){
          
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
             let marker = GMSMarker(position: location)
             marker.title = title
             marker.map = mapView
             markerArray.append(marker)
             nameArray.append(marker.title!)
     }
    @IBAction func doneWithSearch(_ sender: Any) {
        addButton.setTitle("Edit", for: .normal)
        search(searchText: self.search.searchTextField.text!)
    }
    func search(searchText: String) {
        var temp = searchText
        self.searchActive = true;
        self.search.showsCancelButton = true
        let key = searchText
        var count = 0
        for marker in markerArray{
            
            if (marker.title!.caseInsensitiveCompare(key) == .orderedSame) {
                temp = marker.title!
                marker.map = nil
                markerArray.remove(at: count)
                nameArray.remove(at: count)
                search.isHidden = true
                enter.isHidden = true
            search.showsCancelButton = false
            self.search.searchTextField.resignFirstResponder()
            let alert = UIAlertController(title: "", message: temp + " was removed from the map", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
            }
            count += 1
        }
    search.isHidden = true
    enter.isHidden = true
    search.showsCancelButton = false
    let alert = UIAlertController(title: "", message: temp + " could not be found.", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    self.search.searchTextField.resignFirstResponder()
    }

    // for future functionalities
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
extension MapViewController: CLLocationManagerDelegate {
   
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    // 3
    guard status == .authorizedWhenInUse else {
      return
    }

    locationManager.requestLocation()
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }
    mapView.camera = GMSCameraPosition(
      target: location.coordinate,
      zoom: 12,
      bearing: 0,
      viewingAngle: 0)
  }

  // 8
  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    print(error)
  }
}
