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
    static var imageView : UIImageView!    // object used for displaying images to help fixing for user

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenHeight: CGFloat {
            return UIScreen.main.bounds.height
        }
        
        var screenWidth: CGFloat {
            return UIScreen.main.bounds.width
        }
        
        let button = UIButton();
        button.setTitle("Printer fixed", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: 30)
        button.addTarget(self, action: #selector(finishFix(sender:)), for: .touchUpInside)
        
        
        ViewController.imageView = UIImageView(frame:CGRect(x : screenWidth - 450.0,y: screenHeight-300.0 ,width : 450,height : 300));
        ViewController.imageView.layer.borderWidth = 2
        ViewController.imageView.image = UIImage(named:"HumanTechLogo.png")
        self.view.addSubview(ViewController.imageView)

        button.frame = CGRect(x: 20.0, y: screenHeight-50.0, width: 200, height: 50)
        self.view.addSubview(button)
        
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
        labelNode.fontColor = UIColor.green
        labelNode.position = CGPoint(x : 0, y : 0)

        // Create the circle to put under the label
        let Circle = SKShapeNode(circleOfRadius: 10 ) // Size of Circle
        Circle.strokeColor = UIColor.black
        Circle.glowWidth = 1.0
        Circle.fillColor = UIColor.green
        
        // Put the circle under the label
        Circle.position = CGPoint(x : 0, y : -20)
        
        // Add the label and the Circle to the node
        node.addChild(labelNode)
        node.addChild(Circle)
        
        return node;
    }
    
    @objc private func finishFix(sender: UIButton){
        Scene.state = 11
        Scene.end = true
    }
}
