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
// 4. Searchbar functionality - Implement table of valid categories so that users can select.

import UIKit

class CustomCell: UICollectionViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var rating: UILabel!
    
}

class RecViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var user_review: UILabel!
    @IBOutlet weak var background: UIImageView!
    
    var timer = Timer()
    var venues: [Business] = []
    var reviews_: [Reviews] = []
    var ids: [Reviews] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self;
        collectionView.delegate = self;
        self.searchbar.searchTextField.delegate = self;
        //searchbar.searchTextField.addTarget(self, action: #selector(updateVenues), for: .editingDidEndOnExit)
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
        // fetchYelpBusinesses(latitude: 40.6916002, longitude: -73.9846688)
        retrieveVenues(latitude: 40.6916002, longitude: -73.9846688, category: "newamerican", limit: 8, sortBy: "rating", locale: "en_US") { (response, error) in
            if let response = response{
                self.venues = response
                
                //
                // retrieve reviews
                //
                self.retrieveReviews(id: self.venues[0].id! ) { (response_, error) in
                    //print(self.ids[0])
                    if let response = response_{
                        self.reviews_ = response
                        //print(response)
                        DispatchQueue.main.async {
                            self.user_review.text = self.reviews_[0].text
                        }
                    }
                }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        retrieveVenues(latitude: 40.6916002, longitude: -73.9846688, category: "\(self.searchbar.searchTextField.text ?? "bars")", limit: 8, sortBy: "rating", locale: "en_US") { (response, error) in
            if let response = response{
                self.venues = response
                
                //
                // retrieve reviews
                //
                self.retrieveReviews(id: self.venues[0].id! ) { (response_, error) in
                    if let response = response_{
                        self.reviews_ = response
                        //print(response)
                        self.saveData(info: self.reviews_)
                        DispatchQueue.main.async {
                            self.user_review.text = self.reviews_[0].text
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        self.searchbar.searchTextField.resignFirstResponder()
        return true
    }
    
    
    // for paging
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = collectionView.contentOffset.x
        let w = collectionView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        // Do whatever with currentPage.
        //
        retrieveVenues(latitude: 40.6916002, longitude: -73.9846688, category: "\(self.searchbar.searchTextField.text ?? "bars")", limit: 8, sortBy: "rating", locale: "en_US") { (response, error) in
            if let response = response{
                self.venues = response
                
                //
                // retrieve reviews
                //
                self.retrieveReviews(id: self.venues[currentPage].id! ) { (response_, error) in
                    //print(self.ids[0])
                    if let response = response_{
                        self.reviews_ = response
                        //print(response)
                        DispatchQueue.main.async {
                            self.user_review.text = self.reviews_[0].text
                        }
                    }
                }
                DispatchQueue.main.async {
                    
                }
            }
        }
        
        //
        // Change background when scroll
        let toImage = UIImage(named:"background0\(currentPage).png")
        UIView.transition(with: self.background,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
                              self.background.image = toImage
                          },
                          completion: nil)
    }
    
    func saveData(info:[Reviews]){
        self.ids = info
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toMap"){
            if let nextViewController = segue.destination as? MapViewController{
                // transfer info from here
            }
        }
    }
    
    
    
}

extension RecViewController: UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate{
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
        cell.image.layer.cornerRadius = 40
        
        
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
        cell.rating.text = venues[indexPath.row].rating?.description
        DispatchQueue.global().async {

            let url = URL(string: self.venues[indexPath.row].image_address!)!

               do {

                   let data = try Data(contentsOf: url)

                   DispatchQueue.main.async {

                    cell.image.image = UIImage(data: data)

                   }

               } catch {
                   print(error.localizedDescription)
               }
           }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
}
