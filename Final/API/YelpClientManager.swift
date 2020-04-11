//
//  YelpClientManager.swift
//  Final
//
//  Created by Di Wang on 4/11/20.
//  Copyright © 2020 william haberkorn. All rights reserved.
//

import UIKit
import Foundation

let apikey = "5wcjSDXbbYobQCuLpyiDDnJF5qq2K5Zb15TtATN4Fuc75Pcr6cuQWIKi-uBUJf4z_pJILtn3URPrP7Hutrp1wW3IZz5d6knTeoeSmXQnrEegzyE4lD079EVb-JeOXnYx"

extension RecViewController{
    //retrieve
    func retrieveVenues(latitude: Double,
                        longitude: Double,
                        category: String,
                        limit: Int,
                        sortBy: String,
                        locale: String,
                        completionHandler: @escaping ([Business]?, Error?) -> Void){
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
                    venue.image_address = business.value(forKey: "image_url") as? String
                    
                    venues.append(venue)
                }
                completionHandler(venues, nil)

            } catch {
                print("caught")
            }
        }.resume()
    }
    
    
    // retrieve reviews
    func retrieveReviews(id: String,
                         completionHandler: @escaping ([Reviews]?, Error?) -> Void){
        let url = URL(string: "https://api.yelp.com/v3/businesses/\(id)/reviews")
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error{
                completionHandler(nil,err)
            }
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                guard let resp = json as? NSDictionary else {return}
                guard let reviews = resp.value(forKey: "reviews") as? [NSDictionary] else {return}
                var results: [Reviews] = []
                
                for review in reviews{
                    var result = Reviews()
                    result.id = review.value(forKey: "id") as? String
                    result.rating = review.value(forKey: "rating") as? Float
                    result.text = review.value(forKey: "text") as? String
                    
                    results.append(result)
                }
                //print(results)
                completionHandler(results, nil)
            }catch{
                print("caught")
            }
            
        }.resume()
    }
}
