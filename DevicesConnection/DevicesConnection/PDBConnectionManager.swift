//
//  PDBConnectionManager.swift
//  DevicesConnection
//
//  Created by админ on 8/24/17.
//  Copyright © 2017 dashaproduction. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol PDBConnectionManagerDelegate {
    func recieveMessage(message: String)
    func errorOccured(message: String?)
}


final class PDBConnectionManager: NSObject {

    //MARK: - properties
    private let serviceType: String = "pdb-app-service"
    fileprivate let waitingTime: TimeInterval = 20
    fileprivate let messageKey: String = "message"
    
    public var delegate: PDBConnectionManagerDelegate?
    
    fileprivate var session: MCSession!
    fileprivate var peer: MCPeerID!
    fileprivate var browser: MCNearbyServiceBrowser!
    fileprivate var advertiser: MCNearbyServiceAdvertiser!
    fileprivate var foundPeers = [MCPeerID]()

    //MARK: - initializator
    override init() {
        super.init()
        
        peer = MCPeerID(displayName: UIDevice.current.name)
        
        session = MCSession(peer: peer)
        session.delegate = self
        
        browser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }
    
    //MARK: - public
    public func sendMessage(message: String) {
        let dataDictionary : Dictionary<String, String> = [messageKey : message]
        let archiveData = NSKeyedArchiver.archivedData(withRootObject: dataDictionary)
        
        do {
            try session.send(archiveData, toPeers: foundPeers, with: .unreliable)
        }
        catch {
            delegate?.errorOccured(message: "Can't send message")
        }
    }
    
    public func canSendMessage() -> Bool {
        return foundPeers.count > 0
    }
}

extension PDBConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        delegate?.errorOccured(message: error.localizedDescription)
    }
}

extension PDBConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        foundPeers.append(peerID)
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: waitingTime)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        delegate?.errorOccured(message: error.localizedDescription)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.index(of: peerID) {
            foundPeers.remove(at: index)
        }
    }
}

extension PDBConnectionManager: MCSessionDelegate {
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let data = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: String] {
            if let message = data[messageKey] {
                delegate?.recieveMessage(message: message)
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
}
