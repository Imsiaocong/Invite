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

var markerArray = [GMSMarker]()
var nameArray = [String]()

class MapViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate, UISearchBarDelegate {
//    var markerArray = [GMSMarker]()
    var searchActive = true
    var name : String? = nil
    var lat : Double? = nil
    var lon : Double? = nil
//    var nameArray = [String]()
    var didFindMyLocation = false
    @IBOutlet weak var HowToSetPin: UIView!
    @IBOutlet weak var SetPinInstruction: UILabel!
    @IBOutlet weak var IfEventButton: UIButton!
    @IBOutlet weak var IfGeneralButton: UIButton!
    @IBOutlet weak var SelectDate: UIDatePicker!
    @IBOutlet weak var EnterDate: UIButton!
    @IBOutlet weak var DateDisplay: UIView!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var enter: UIButton!
    
    // this function actually removes things !!
    // i just dont wanna relink it ;)
    @IBAction func Add(_sender: Any) {

        
        // search bar appears and user can query
        if ( search.isHidden ){
            search.becomeFirstResponder()
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
        
        if ( markerArray.count == 0){
            
        }
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
        DateDisplay.isHidden = true
        SelectDate.isHidden = true
        EnterDate.isHidden = true
        let curr = Date()
        self.SelectDate.minimumDate = curr
        IfEventButton.isHidden = true
        IfGeneralButton.isHidden = true
        SetPinInstruction.isHidden = true
        HowToSetPin.addSubview(SetPinInstruction)
        HowToSetPin.isHidden = true
        HowToSetPin.layer.cornerRadius = 10
        mapView.delegate = self
        search.searchTextField.delegate = self
        search.isHidden = true
        enter.isHidden = true
        mapView.addSubview(search)
        mapView.addSubview(enter)
        search.becomeFirstResponder()
        self.view.addSubview(mapView)
        self.view.addSubview(topBar)
        
        let latitude = [40.73,40.74,40.734,40.727,40.75]
        let longitude = [-73.95,-73.99,-73.994,-73.9918,-73.9968]
        let title = ["Steak House", "Ribalta","Vapiano","Katz Delicatessen","Westville"]
        
        // hard coded to immitate user data
        var i = 0
        for lati in latitude{
            placeMark(latitude: lati, longitude: longitude[i], title: title[i])
            i += 1
        }
      
        if (lat != nil) && ( lon != nil) && (name != ""){
            mapView.addSubview(HowToSetPin)
            SetPinInstruction.isHidden = false
            HowToSetPin.isHidden = false
            IfEventButton.isHidden = false
            IfGeneralButton.isHidden = false
        }
       
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

    }
    @IBAction func SetAsEvent(_ sender: Any) {
        mapView.addSubview(DateDisplay)
        DateDisplay.isHidden = false
        DateDisplay.layer.cornerRadius = 10
        DateDisplay.addSubview(SelectDate)
        DateDisplay.addSubview(EnterDate)
        DateDisplay.center = CGPoint(x: mapView.frame.size.width / 2, y: (mapView.frame.size.height / 2))
        SelectDate.center = CGPoint(x: DateDisplay.frame.size.width / 2, y: (DateDisplay.frame.size.height / 2))
        SelectDate.isHidden = false
        EnterDate.isHidden = false
        IfEventButton.isHidden = true
        IfGeneralButton.isHidden = true
        SetPinInstruction.isHidden = true
        HowToSetPin.isHidden = true
        
        // wait for time to be selected

    }
    @IBAction func DateEntered(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let Date = dateFormatter.string(from: SelectDate.date)
        SelectDate.isHidden = true
        EnterDate.isHidden = true
        DateDisplay.isHidden = true
        placeEvent(latitude: lat!, longitude: lon!, title: name!, date: Date)
    }
    @IBAction func SetAsGeneral(_ sender: Any) {
         placeMark(latitude: lat!, longitude: lon!, title: name!)
        IfEventButton.isHidden = true
        IfGeneralButton.isHidden = true
        SetPinInstruction.isHidden = true
        HowToSetPin.isHidden = true
    }
    func placeMark(latitude: Double, longitude: Double, title: String){
          
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
             let marker = GMSMarker(position: location)
             marker.title = title
             marker.map = mapView
             marker.snippet = ""
             markerArray.append(marker)
             reverseGeocode(coordinate: location, markIDX: markerArray.count)
             nameArray.append(marker.title!)
    }
    func placeEvent(latitude: Double, longitude: Double, title: String, date: String){
              
               let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let marker = GMSMarker(position: location)
                marker.icon = GMSMarker.markerImage(with: .blue)
                marker.snippet = date
                marker.title = title
                marker.map = mapView
                markerArray.append(marker)
                reverseGeocode(coordinate: location, markIDX: markerArray.count)
                nameArray.append(marker.title!)
    }
    func reverseGeocode(coordinate: CLLocationCoordinate2D, markIDX: Int) {
      let geocoder = GMSGeocoder()
        
      geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
        guard
          let address = response?.firstResult(),
          let lines = address.lines
          else {
            return
        }
        markerArray[markIDX-1].snippet! += ("\n" + lines.joined(separator: "\n"))

      }
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
      zoom: 13,
      bearing: 0,
      viewingAngle: 0)
  }
  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    print(error)
  }
}
