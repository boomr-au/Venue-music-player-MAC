//
//  VSettingsViewController.swift
//  Venue
//
//  Created by CHITRA on 08/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa

class VSettingsViewController: NSViewController {
    var selectedZone:Result?
    @IBOutlet var textfieldVenueName:NSTextField!
    @IBOutlet var textfieldZoneName:NSTextField!
    @IBOutlet var textfieldZoneId:NSTextField!
    @IBOutlet var textfieldAppVersion:NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI(){
        textfieldVenueName.stringValue = selectedZone?.venue_name ?? ""
        textfieldZoneName.stringValue = selectedZone?.zone_name ?? ""
        textfieldZoneId.stringValue = selectedZone?.zone_id ?? ""
        textfieldAppVersion.stringValue = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    @IBAction func dismissView(sender:NSButton){
        self.dismiss(self)
    }
}
