//
//  ViewController.swift
//  PaperjamRemove
//
//  Created by Sébastien Crettaz on 04.12.17.
//  Copyright © 2017 Human Tech. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

import Vision

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create a node that will contains the label and the circle
        let node = SKNode()
        
        // Create the label displaying the text
        let labelNode = SKLabelNode(text: Scene.displayName)
        labelNode.fontName = "AppleSDGothicNeo-Bold"
        labelNode.fontColor = UIColor.orange
        labelNode.position = CGPoint(x : 0, y : 0)

        // Create the circle to put under the label
        let Circle = SKShapeNode(circleOfRadius: 10 ) // Size of Circle
        Circle.strokeColor = UIColor.black
        Circle.glowWidth = 1.0
        Circle.fillColor = UIColor.orange
        
        // Put the circle under the label
        Circle.position = CGPoint(x : 0, y : -20)
        
        // Add the label and the Circle to the node
        node.addChild(labelNode)
        node.addChild(Circle)
        
        return node;
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
