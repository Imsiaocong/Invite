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
var eventOrNot = [Int]()
class MapViewController: UIViewController, GMSMapViewDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
//    var markerArray = [GMSMarker]()
    var tappedMarker : GMSMarker?
    var customInfoWindow : CustomInfoWindow?
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
            // for future permanent data storage
        }
        search.showsCancelButton = false
        search.delegate = self
        locationManager.delegate = self
        
        // set up map
        if CLLocationManager.locationServicesEnabled() {
            
          locationManager.requestLocation()
          mapView.isMyLocationEnabled = true
          mapView.settings.myLocationButton = true
            
        } else {
          // ask user for location
          locationManager.requestWhenInUseAuthorization()
            
        }
       
        
        // set up buttons and views
        DateDisplay.isHidden = true
        SelectDate.isHidden = true
        EnterDate.isHidden = true
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
        
        // set date picker min to today
        let curr = Date()
        self.SelectDate.minimumDate = curr
        
        // hard coded to immitate user data
        let latitude = [40.73,40.74,40.734,40.727,40.75]
        let longitude = [-73.95,-73.99,-73.994,-73.9918,-73.9968]
        let title = ["Steak House", "Ribalta","Vapiano","Katz Delicatessen","Westville"]
        
        // place restaurants onto map
        var i = 0
        for lati in latitude{
            
            placeMark(latitude: lati, longitude: longitude[i], title: title[i])
            i += 1
            
        }
          

        // if there is data from the segue of rec controller, add this to map
        if (lat != nil) && ( lon != nil) && (name != ""){
            
            // ask user if they want to make a general pin or an event
            mapView.addSubview(HowToSetPin)
            SetPinInstruction.isHidden = false
            HowToSetPin.isHidden = false
            IfEventButton.isHidden = false
            IfGeneralButton.isHidden = false
            
        }
        
        self.tappedMarker = GMSMarker()
       
        self.locationManager.delegate = self
        //self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()

    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
     let position = tappedMarker?.position
     customInfoWindow?.center = mapView.projection.point(for: position!)
     customInfoWindow?.center.y -= 140
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
     customInfoWindow?.removeFromSuperview()
    }
    
    func mapView( _ mapView: GMSMapView, didTap marker: GMSMarker)->Bool{
        tappedMarker = marker
        
        let position = marker.position
        mapView.animate(toLocation: position)
        let point = mapView.projection.point(for: position)
        let newPoint = mapView.projection.coordinate(for: point)
        let camera = GMSCameraUpdate.setTarget(newPoint)
        mapView.animate(with: camera)
        
        let idx = nameArray.firstIndex(of: marker.title!)!
        var event : Bool
        
        if (eventOrNot[idx]==0){
            event = false
        }
        else{
            event = true
        }
        
        self.customInfoWindow = CustomInfoWindow().loadView(text: marker.title! + "\n\n" + (marker.snippet!), event: event)
        self.customInfoWindow?.layer.cornerRadius = 10
        customInfoWindow?.center = mapView.projection.point(for: position)
        if ( !event ){
            customInfoWindow?.Accept.isHidden = true
            customInfoWindow?.Chat.isHidden = true
        }
        else{
            customInfoWindow?.Accept.isHidden = false
            customInfoWindow?.Chat.isHidden = false
        }
        self.mapView.addSubview(customInfoWindow!)
        
        return false
    }
    
    // if user wants marker to be an event
    @IBAction func SetAsEvent(_ sender: Any) {
        
        // let user pick a date from date picker
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
    
    // when user finished with date selector
    @IBAction func DateEntered(_ sender: Any) {
        
        // add the selected date to the marker to be displayed on map
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let Date = dateFormatter.string(from: SelectDate.date)
        SelectDate.isHidden = true
        EnterDate.isHidden = true
        DateDisplay.isHidden = true
        
        // add to the map
        placeEvent(latitude: lat!, longitude: lon!, title: name!, date: Date)
        
    }
    
    // normal pin was selected
    @IBAction func SetAsGeneral(_ sender: Any) {
        
        // place general pin with no time data
        placeMark(latitude: lat!, longitude: lon!, title: name!)
        IfEventButton.isHidden = true
        IfGeneralButton.isHidden = true
        SetPinInstruction.isHidden = true
        HowToSetPin.isHidden = true
        
    }
    
    // place normal pin
    func placeMark(latitude: Double, longitude: Double, title: String){
          
             let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
             let marker = GMSMarker(position: location)
             marker.title = title
             marker.map = mapView
             marker.snippet = ""
             markerArray.append(marker)
            
             // retrieve address and include to marker info window
             reverseGeocode(coordinate: location, markIDX: markerArray.count)
             nameArray.append(marker.title!)
        eventOrNot.append(0)
    }
    
    // place event pin
    func placeEvent(latitude: Double, longitude: Double, title: String, date: String){
                
                // make marker with time data in info window
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let marker = GMSMarker(position: location)
                marker.icon = GMSMarker.markerImage(with: .blue)
                marker.snippet = date
                marker.title = title
                marker.map = mapView
                markerArray.append(marker)
                reverseGeocode(coordinate: location, markIDX: markerArray.count)
                nameArray.append(marker.title!)
                eventOrNot.append(1)
        
    }
    
    // get address of the marker
    func reverseGeocode(coordinate: CLLocationCoordinate2D, markIDX: Int) {
        
      let geocoder = GMSGeocoder()
      geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
        guard
          let address = response?.firstResult(),
          let lines = address.lines
          else {
            return
        }
        
        // add the address to info window on marker
        markerArray[markIDX-1].snippet! += ("\n" + lines.joined(separator: "\n"))

      }
        
    }
    
    // if user finishes search for their markers
    @IBAction func doneWithSearch(_ sender: Any) {
        
        addButton.setTitle("Edit", for: .normal)
        search(searchText: self.search.searchTextField.text!)
        
    }
    
    // remove marker that user chooses, else tell user cant be found
    func search(searchText: String) {
        
        var temp = searchText
        self.searchActive = true;
        self.search.showsCancelButton = true
        let key = searchText
        var count = 0
        
        for marker in markerArray{
            
            // if the marker is found
            if (marker.title!.caseInsensitiveCompare(key) == .orderedSame) {
                
                // remove the information from the map and inform the user
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
    
    // if the marker was not found, let the user know
    search.isHidden = true
    enter.isHidden = true
    search.showsCancelButton = false
    let alert = UIAlertController(title: "", message: temp + " could not be found.", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    self.search.searchTextField.resignFirstResponder()
        
    }

    // for future functionalities
    // is not used currently
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

// controlls initial set up of the map view
// map view is centered on current location
extension MapViewController: CLLocationManagerDelegate {
   
  // if user allows location services
  func locationManager(
    
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
   
    guard status == .authorizedWhenInUse else {
      return
    }

    locationManager.requestLocation()
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    
  }
    
  // orient map around current location at initial load
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
    
  // if cant find location
  func locationManager(
    
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    print(error)
  }
    
}
