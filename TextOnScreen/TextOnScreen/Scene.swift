//
//  Scene.swift
//  TextOnScreen
//
//  Created by Lin on 17.10.17.
//  Copyright © 2017 Human Tech. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    let distanceLabel = SKLabelNode(text: "Distance")
    
    override func didMove(to view: SKView) {
        
        // Setup your scene here
        distanceLabel.position = CGPoint(x:450,y:480)
        distanceLabel.fontSize = 20
        distanceLabel.fontName = "DevanagariSangamMN-Bold"
        distanceLabel.fontColor = UIColor.green
        addChild(distanceLabel)
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        var position = CGPoint(x:0,y:0)

        if let touch = touches.first {
            position = touch.location(in: self)
            position.x = (position.x + 683)/(683)
            position.y = (position.y + 506)/506
            print(position)
        }
        
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            var distance : CGFloat = 0.0
            for result in sceneView.hitTest(position, types: [.existingPlaneUsingExtent, .featurePoint]) {
                distance = result.distance // Get Distance to object
                print("Distance : ",result.distance)
            }
            distanceLabel.text = String(format:"%.2f",distance)
            
            // Create a transform with a translation of 3 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2-Float(distance)
            let transform = simd_mul(currentFrame.camera.transform, translation)
            print(transform)
            
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
