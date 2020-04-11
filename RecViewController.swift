//
//  RecViewController.swift
//  Final
//
//  Created by Di Wang on 4/10/20.
//  Copyright © 2020 william haberkorn. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell{
    
}

class RecViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var time: UILabel!
    
    var timer = Timer()
    
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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func tick() {
        time.text = DateFormatter.localizedString(from: Date(),
                                                  dateStyle: .long,
                                                  timeStyle: .short)
    }

}

extension RecViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cells", for: indexPath) as! CustomCell
        // Do something with cell;
        cell.layer.cornerRadius = 16;
        
        let regularBlur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: regularBlur)
        blurView.frame = cell.bounds
        blurView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cell.addSubview(blurView)
        cell.sendSubviewToBack(blurView)
        return cell
    }
    
    
}
