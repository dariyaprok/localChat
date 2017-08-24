//
//  ViewController.swift
//  DevicesConnection
//
//  Created by админ on 8/24/17.
//  Copyright © 2017 dashaproduction. All rights reserved.
//

import UIKit

let errorTitle: String = "Error"
let okTitle: String = "Ok"

class PDBViewController: UIViewController, PDBConnectionManagerDelegate {
    
    //MARK: - properties
    @IBOutlet private weak var messagesTextView: UITextView!
    
    private var connectedManager: PDBConnectionManager = PDBConnectionManager()
    fileprivate var previousText: String = ""
    fileprivate var textViewTimer: Timer?
    
    fileprivate let waitingTime: TimeInterval = 1
    
    //MARK: - life cycle
    override func viewDidLoad() {
        connectedManager.delegate = self
    }
    
    //MARK: - data messages
    func sendMessage() {
        if connectedManager.canSendMessage() {
            let message: String = messagesTextView.text.substring(from: previousText.endIndex)
            connectedManager.sendMessage(message: message)
            self.previousText = self.messagesTextView.text
        }
    }
    
    //MARK: - PDBConnectionManagerDelegate
    func recieveMessage(message: String) {
        DispatchQueue.main.async {
            self.messagesTextView.text = self.messagesTextView.text.appending(message)
            self.previousText = self.messagesTextView.text
        }
    }
    
    func errorOccured(message: String?) {
        let alertController = UIAlertController(title: errorTitle, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: okTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if #available(iOS 9.0, *) {
            alertController.preferredAction = cancelAction
        } 
        self.present(alertController, animated: true, completion: nil)
    }
    
}

extension PDBViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if self.textViewTimer != nil {
            self.textViewTimer!.invalidate()
            self.textViewTimer = nil
        }
        self.textViewTimer = Timer.scheduledTimer(timeInterval: waitingTime, target: self, selector: #selector(sendMessage), userInfo: nil, repeats: false)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty {
            return false
        }
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.selectedRange = NSMakeRange(textView.text.characters.count, 0)
    }
}

