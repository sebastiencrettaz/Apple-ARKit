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
        
        // Force app to launch in landscape orientation
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        
        // Get screen height
        var screenHeight: CGFloat {
            return UIScreen.main.bounds.height
        }
        
        // Get screen width
        var screenWidth: CGFloat {
            return UIScreen.main.bounds.width
        }
        
        // Create button if printer fixed before the end of the fixing
        let button = UIButton();
        button.setTitle("Printer fixed", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: 30)
        button.addTarget(self, action: #selector(finishFix(sender:)), for: .touchUpInside)
        button.frame = CGRect(x: 20.0, y: screenHeight-50.0, width: 200, height: 50)
        
        // Create imageView to show user what he should do to repair the printer
        ViewController.imageView = UIImageView(frame:CGRect(x : screenWidth - screenWidth*0.3,y: screenHeight-screenHeight*0.3 ,width : screenWidth*0.3 ,height : screenHeight*0.3));
        ViewController.imageView.layer.borderWidth = 2
        ViewController.imageView.image = UIImage(named:"HumanTechLogo.png")
        
        // Add button and viewController to the view
        self.view.addSubview(ViewController.imageView)
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
    
    // Force app to run in landscape mode
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UInt(UIInterfaceOrientationMask.landscapeRight.rawValue))
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
        // Depends on the state, the user must close parts he has already opened
        if(Scene.state-1 < 5){
            Scene.state = 13-(Scene.state-1)
        }
    }
}
