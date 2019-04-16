//
//  SchedulePlayListCell.swift
//  Venue
//
//  Created by CHITRA on 05/11/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa
protocol ScheduleCellDelegate {
    func showManualPlay(sender:NSButton)
}

class SchedulePlayListCell: NSTableCellView {
    @IBOutlet var labelBackground:NSTextField!
    @IBOutlet var labelScheduleName:NSTextField!
    @IBOutlet var labelSongCount:NSTextField!
    @IBOutlet var buttonPlay:NSButton!
    @IBOutlet var heightConstraint:NSLayoutConstraint!
    var scheduleDelegate:ScheduleCellDelegate!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    @IBAction func manualPlay(sender:NSButton){
        self.scheduleDelegate.showManualPlay(sender: sender)
    }
    
}
