//
//  Scene.swift
//  PaperjamRemove
//
//  Created by Lin on 04.12.17.
//  Copyright © 2017 Human Tech. All rights reserved.
//

import SpriteKit
import ARKit
import Vision

class Scene: SKScene {
    var latestPrediction : String = "…" // a variable containing the latest CoreML prediction
    static var objectName:String = "…" // variable containing the value of the current object found by CoreML
    var prediction:String = "…" // variable containing the level of prediction
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        var predictionFloat : Double = 0.0
        // Variable used to find position of the object
        //var position = CGPoint(x:0,y:0)
        
        //position.x = self.sceneView.bounds.midX
        //position.y = self.sceneView.bounds.midY
        
        if let currentFrame = sceneView.session.currentFrame {
            DispatchQueue.global(qos: .background).async {
                do {
                    let model = try VNCoreMLModel(for:MyModel().model)
                    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                        // Jump onto the main thread
                        DispatchQueue.main.async {
                            // Access the first result in the array after casting the array as a VNClassificationObservation array
                            guard let results = request.results as? [VNClassificationObservation] else {
                                print ("No results?")
                                return
                            }
                            // Get Classifications
                            let classifications = results[0...1] // top 2 results
                                .flatMap({ $0 })
                                .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
                                .joined(separator: "\n")
                            
                            // Store the latest prediction
                            self.prediction = classifications.components(separatedBy: "- ")[1]
                            Scene.objectName = classifications.components(separatedBy: "-")[0]
                            Scene.objectName = Scene.objectName.components(separatedBy: ",")[0]
                            predictionFloat = (self.prediction as NSString).doubleValue
                            
                            //print(result.identifier)
                        }
                    })
                    
                    let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                    try handler.perform([request])
                } catch {}
                
                
                //print(self.prediction)
                
                if(predictionFloat > 0.5 && self.latestPrediction != Scene.objectName){
                    // Create a transform with a translation of 0.2 meters in front of the camera
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.4
                    let transform = simd_mul(currentFrame.camera.transform, translation)
                    //print(translation)
                    
                    // Add a new anchor to the session
                    let anchor = ARAnchor(transform: transform)
                    
                    // Set the identifier
                    //ARBridge.shared.anchorsToIdentifiers[anchor] = result.identifier
                    sceneView.session.add(anchor: anchor)
                    
                    // Update last object found
                    self.latestPrediction = Scene.objectName
                }
            }
        }
    }
}
