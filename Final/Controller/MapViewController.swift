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

class MapViewController: UIViewController, GMSMapViewDelegate {

    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBAction func Add(_ sender: Any) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let camera = GMSCameraPosition.camera(withLatitude: 40.73, longitude: -73.99, zoom: 13.0)
              let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
              self.view.addSubview(mapView)
        self.view.addSubview(topBar)
              let marker = GMSMarker()
              marker.position = CLLocationCoordinate2D(latitude: 40.73, longitude: -73.99)
              marker.map = mapView
       
    }
//    google.maps.event.addListener(marker, 'mousedown', function(event) {
//
//        infowindow.setContent(contentString);
//        infowindow.open(map, marker);
//    });
//    func mapView(_ mapView: GMSMapView, didTapAt location: CLLocationCoordinate2D) {
//
//       let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//         marker.map = mapView
//     }
      


}

