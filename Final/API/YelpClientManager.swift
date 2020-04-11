//
//  YelpClientManager.swift
//  Final
//
//  Created by Di Wang on 4/11/20.
//  Copyright © 2020 william haberkorn. All rights reserved.
//

import UIKit

class YelpClientManager: NSObject {
    
    func fetchYelpBusinesses(latitude: Double, longitude: Double) {
        let apikey = "5wcjSDXbbYobQCuLpyiDDnJF5qq2K5Zb15TtATN4Fuc75Pcr6cuQWIKi-uBUJf4z_pJILtn3URPrP7Hutrp1wW3IZz5d6knTeoeSmXQnrEegzyE4lD079EVb-JeOXnYx"
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)")
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                print(err.localizedDescription)
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
                for item in venues{
                    print(item);
                }
            } catch {
                print("caught")
            }
        }.resume()
    }
}
