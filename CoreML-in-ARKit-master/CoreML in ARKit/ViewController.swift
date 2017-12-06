//
//  ViewController.swift
//  CoreML in ARKit
//
//  Created by Hanley Weng on 14/7/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

import Vision

class ViewController: UIViewController, ARSKViewDelegate {

    // SCENE
    @IBOutlet var sceneView: ARSKView!
    var latestPrediction : String = "…" // a variable containing the latest CoreML prediction
    var objectName:String = "…" // variable containing the value of the current object found by CoreML
    var prediction:String = "…" // variable containing the level of prediction
    
    // COREML
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml") // A Serial Queue
    @IBOutlet weak var debugTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Create a new scene
        let scene = SKScene()
        
        // Set the scene to the view
        sceneView.presentScene(scene)
        
        // Set up Vision Model
        guard let selectedModel = try? VNCoreMLModel(for: MyModel().model) else {
            fatalError("Could not load model.")
        }
        
        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]
        
        // Begin Loop to Update CoreML
        loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Enable plane detection
        //configuration.planeDetection = .horizontal
        
        // Run the view's session
        self.sceneView.session.run(configuration)
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
    
    // MARK: - Status Bar: Hide
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - CoreML Vision Handling
    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        dispatchQueueML.async {
            // 1. Run Update.
            self.updateCoreML()
            
            // 2. Add nodes in the view
            self.addObject()
            
            // 3. Loop this function.
            self.loopCoreMLUpdate()
        }
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...1] // top 2 results
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
    
        DispatchQueue.main.async {
            // Print Classifications
            //print(classifications)
            //print("--")
            
            // Display Debug Text on screen
            var debugText:String = ""
            debugText += classifications
            self.debugTextView.text = debugText
            
            // Store the latest prediction

            self.prediction = classifications.components(separatedBy: "- ")[1]
            self.objectName = classifications.components(separatedBy: "-")[0]
            self.objectName = self.objectName.components(separatedBy: ",")[0]
        }
    }
    
    func addObject(){
        let predictionFloat = (self.prediction as NSString).doubleValue
        
        if(predictionFloat > 0.5){
            guard let sceneView = self.sceneView else {
                return
            }
            // Variable used to find position of the object
            //var position = CGPoint(x:0,y:0)
            
            //position.x = self.sceneView.bounds.midX
            //position.y = self.sceneView.bounds.midY
            
            if let currentFrame = sceneView.session.currentFrame {
                // Create a transform with a translation of 3 meters in front of the camera
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.2
                let transform = simd_mul(currentFrame.camera.transform, translation)
                print(transform)
                
                // Add a new anchor to the session
                let anchor = ARAnchor(transform: transform)
                //print(anchor)
                sceneView.session.add(anchor: anchor)
            }
            // Update last object found
            self.latestPrediction = self.objectName
        }
    }
    
    // This function is called when an ARAnchor is added
   func view(_ view: ARSKView,nodeFor anchor: ARAnchor) -> SKNode? {
       let labelNode = SKLabelNode(text: self.latestPrediction)
       labelNode.horizontalAlignmentMode = .center
       labelNode.verticalAlignmentMode = .center
        //labelNode.xScale = 0.05
        //labelNode.yScale = 0.05
        //print(view)
        //labelNode.fontSize = 1
        return labelNode;
    }
    
    func updateCoreML() {
        ///////////////////////////
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        // Note: Not entirely sure if the ciImage is being interpreted as RGB, but for now it works with the Inception model.
        // Note2: Also uncertain if the pixelBuffer should be rotated before handing off to Vision (VNImageRequestHandler) - regardless, for now, it still works well with the Inception model.
        
        ///////////////////////////
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:]) // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
        
        ///////////////////////////
        // Run Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
        
    }
}
