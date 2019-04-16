//
//  VZoneActivationViewController.swift
//  Venue
//
//  Created by CHITRA on 31/10/18.
//  Copyright © 2018 CHITRA. All rights reserved.
//

import Cocoa
var zoneVC : ZoneTabs!
class VZoneActivationViewController: NSViewController,NSTextFieldDelegate {
    @IBOutlet var textFieldId1:NSTextField!
    @IBOutlet var textFieldId2:NSTextField!
    @IBOutlet var textFieldId3:NSTextField!
    @IBOutlet var textFieldId4:NSTextField!
    @IBOutlet var textFieldId5:NSTextField!
    @IBOutlet var textFieldId6:NSTextField!
    var activeTextField:NSTextField?
    var activationCode:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        textFieldId1.becomeFirstResponder()
    }
    
    //MARK:- TextfIeld Delegates
       func controlTextDidChange(_ obj: Notification) {
        let textFieldSelected = obj.object as! NSTextField
        if(textFieldSelected == textFieldId1 && textFieldId1.stringValue != ""){
            textFieldId2.becomeFirstResponder()
            activeTextField = textFieldId2
        }else if(textFieldSelected == textFieldId2 && textFieldId2.stringValue != ""){
            textFieldId3.becomeFirstResponder()
            activeTextField = textFieldId3
        }else if(textFieldSelected == textFieldId3 && textFieldId3.stringValue != ""){
            textFieldId4.becomeFirstResponder()
            activeTextField = textFieldId4
        }else if(textFieldSelected == textFieldId4 && textFieldId4.stringValue != ""){
            textFieldId5.becomeFirstResponder()
            activeTextField = textFieldId5
        }else if(textFieldSelected == textFieldId5 && textFieldId5.stringValue != ""){
            textFieldId6.becomeFirstResponder()
            activeTextField = textFieldId6
        }else if(textFieldSelected == textFieldId6 && textFieldId6.stringValue != ""){
            textFieldId6.resignFirstResponder()
        }
    }
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if(commandSelector.description == "deleteBackward:" || commandSelector.description == "moveLeft:"){
            if(activeTextField?.stringValue == ""){
                if(activeTextField == textFieldId2){
                    textFieldId1.becomeFirstResponder()
                }else if(activeTextField == textFieldId3){
                    textFieldId2.becomeFirstResponder()
                }else if(activeTextField == textFieldId4){
                    textFieldId3.becomeFirstResponder()
                }else if(activeTextField == textFieldId5){
                    textFieldId4.becomeFirstResponder()
                }else if(activeTextField == textFieldId6){
                    textFieldId5.becomeFirstResponder()
                }
            }
        }
        return false
    }
    func controlTextDidBeginEditing(_ obj: Notification) {
        activeTextField = obj.object as? NSTextField
    }
    
    @IBAction func activateAction(_ sender: Any) {
        self.activate()
    }
    
    func activate(){
        let deviceVersion = "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion)" + "." +  "\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion)" + "." + "\(ProcessInfo.processInfo.operatingSystemVersion.patchVersion)"
        let device = Host.current().localizedName
        let deviceId = "deviceId"
        if(textFieldId1.stringValue != "" && textFieldId2.stringValue != "" && textFieldId3.stringValue != "" && textFieldId4.stringValue != "" && textFieldId5.stringValue != "" && textFieldId6.stringValue != ""){
            self.activationCode = textFieldId1.stringValue+textFieldId2.stringValue+textFieldId3.stringValue+textFieldId4.stringValue+textFieldId5.stringValue+textFieldId6.stringValue
            let dictParams = ["activation_code":self.activationCode!,"device_name":device ?? "New Device","device_version":deviceVersion,"secure_id":deviceId] as [String : Any]
            NetworkManager().postMethodAlamofire(ConstantsManager.activateZoneURL, dictionary: dictParams as NSDictionary) { (success, result, error) in
                if let activationCode:ActivationCodeBase = result as? ActivationCodeBase{
                    self.saveData(zoneData: activationCode.result![0])
                    let storyBoard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateController(withIdentifier: "VSheduleListViewController") as! VSheduleListViewController
                    newViewController.selectedZone = activationCode.result?[0]
                    let selectedIndex = ZoneTabs.shared.selectedTabViewItemIndex
                    
                    let newItem: NSTabViewItem = NSTabViewItem(identifier: "\(selectedIndex)")
                    newItem.label = "Zone \(selectedIndex + 1)"
                    // "tvcontroller" is in storyboard
                    newItem.viewController = newViewController
                    let tabItem = ZoneTabs.shared.tabViewItems[selectedIndex]
                    ZoneTabs.shared.removeTabViewItem(tabItem)
                    ZoneTabs.shared.insertTabViewItem(newItem, at: selectedIndex)
                    ZoneTabs.shared.selectedTabViewItemIndex = selectedIndex
                    // self.present(newViewController, animator: ReplacePresentationAnimator())
                 
                }else{
                    // GenericFunctions.showAlert
                    self.showAlert(question:ConstantsManager.activateCodeError, text: "Check Code")
                }
                
            }
        }else{
            self.showAlert(question:ConstantsManager.activateCodeError, text: "Check Code")
        }
    }
   
   
    func saveData(zoneData:Result){
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: zoneData)
        userDefaults.set(encodedData, forKey: "zoneData")
        userDefaults.set(self.activationCode, forKey: "activationCode")
        userDefaults.synchronize()
    }
    
    func showAlert(question: String, text: String) {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!) { (modalResponse) in
        }
    }
}

class ReplaceSegue: NSStoryboardSegue {
    override func perform() {
        if let fromViewController = sourceController as? NSViewController {
            if let toViewController = destinationController as? NSViewController {
                // no animation.
                fromViewController.view.window?.contentViewController = toViewController
            }
        }
    }
}
class ReplacePresentationAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        if let window = fromViewController.view.window {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                fromViewController.view.animator().alphaValue = 0
            }, completionHandler: { () -> Void in
                viewController.view.alphaValue = 0
                window.contentViewController = viewController
                viewController.view.animator().alphaValue = 1.0
            })
        }
    }
    
    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        if let window = viewController.view.window {
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                viewController.view.animator().alphaValue = 0
            }, completionHandler: { () -> Void in
                fromViewController.view.alphaValue = 0
                window.contentViewController = fromViewController
                fromViewController.view.animator().alphaValue = 1.0
            })
        }
    }
}
