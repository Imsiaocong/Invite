//
//  CustomInfoWindow.swift
//  Final
//
//  Created by william haberkorn on 5/5/20.
//  Copyright © 2020 william haberkorn. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {

    @IBOutlet weak var Info: UILabel!

    @IBOutlet weak var Chat: UIButton!
    @IBOutlet weak var Accept: UIButton!
    
    override init(frame: CGRect) {
     super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
     super.init(coder: aDecoder)
    }
    
    // load custom view depending on whether the
    // marker is an event or general
    func loadView(text: String, event: Bool) -> CustomInfoWindow{
     let customInfoWindow = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as! CustomInfoWindow
     customInfoWindow.Info.text = text
        
     return customInfoWindow
    }
    
    // future use
    @IBAction func acceptPin(_ sender: Any) {
        
    }
    // future use
    @IBAction func chat(_ sender: Any) {
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
