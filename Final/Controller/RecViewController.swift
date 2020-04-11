//
//  RecViewController.swift
//  Final
//
//  Created by Di Wang on 4/10/20.
//  Copyright © 2020 william haberkorn. All rights reserved.
//

//
// Di Wang
// Todo:
// 1. To get the user location
// 2. There is a bug in collectionview: when scrolling the cells, its background color gets deeper for some reason.
// 3. Transfer information to MapViewController.
// 4. Searchbar functionality

import UIKit

class CustomCell: UICollectionViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    
}

class RecViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var time: UILabel!
      
    var timer = Timer()
    let manager = YelpClientManager()
    var venues: [Business] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = UIColor.clear.withAlphaComponent(0)
        searchbar.searchTextField.layer.cornerRadius = 18
        searchbar.searchTextField.layer.masksToBounds = true
        
        //
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
        
        //
        let regularBlur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: regularBlur)
        blurView.frame = searchbar.searchTextField.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        searchbar.addSubview(blurView)
        searchbar.sendSubviewToBack(blurView)
        
        //
        //fetchYelpBusinesses(latitude: 40.6916002, longitude: -73.9846688)
        retrieveVenues(latitude: 40.6916002, longitude: -73.9846688, category: "cafe", limit: 5, sortBy: "distance", locale: "en_US") { (response, error) in
            if let response = response{
                self.venues = response
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Date and Time
    @objc func tick() {
        time.text = DateFormatter.localizedString(from: Date(),
                                                  dateStyle: .long,
                                                  timeStyle: .short)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMap"){
            if let nextViewController = segue.destination as? MapViewController{
                // transfer info from here
            }
        }
    }
    
    
    
}

extension RecViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.venues.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cells", for: indexPath) as! CustomCell
        // Do something with cell;
        cell.layer.cornerRadius = 16;
        
        // Visual fx
        let regularBlur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: regularBlur)
        blurView.frame = cell.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cell.addSubview(blurView)
        cell.sendSubviewToBack(blurView)
        
        // retrieve data
        cell.name.text = venues[indexPath.row].name
        cell.address.text = venues[indexPath.row].address
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
}

extension RecViewController{
    //retrieve
    func retrieveVenues(latitude: Double,
                        longitude: Double,
                        category: String,
                        limit: Int,
                        sortBy: String,
                        locale: String,
                        completionHandler: @escaping ([Business]?, Error?) -> Void){
        let apikey = "5wcjSDXbbYobQCuLpyiDDnJF5qq2K5Zb15TtATN4Fuc75Pcr6cuQWIKi-uBUJf4z_pJILtn3URPrP7Hutrp1wW3IZz5d6knTeoeSmXQnrEegzyE4lD079EVb-JeOXnYx"
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=\(category)&limit=\(limit)&sort_by=\(sortBy)&locale=\(locale)")
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                completionHandler(nil, err)
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                //print(">>>>>", json, #line, "<<<<<<<<<")
                guard let resp = json as? NSDictionary else {return}
                guard let businesses = resp.value(forKey: "businesses") as? [NSDictionary] else {return}
                var venues: [Business] = []
                
                for business in businesses{
                    var venue = Business()
                    venue.name = business.value(forKey: "name") as? String
                    venue.id = business.value(forKey: "id") as? String
                    venue.rating = business.value(forKey: "rating") as? Float
                    venue.price = business.value(forKey: "price") as? String
                    venue.isClosed = business.value(forKey: "is_closed") as? Bool
                    let address = business.value(forKeyPath: "location.display_address") as? [String]
                    venue.address = address?.joined(separator: "\n")
                    
                    venues.append(venue)
                }
                completionHandler(venues, nil)

            } catch {
                print("caught")
            }
        }.resume()
    }
}
