//
//  Scene.swift
//  PaperjamRemove
//
//  Created by Sébastien Crettaz on 04.12.17.
//  Copyright © 2017 Human Tech. All rights reserved.
//

import SpriteKit
import ARKit
import Vision

class Scene: SKScene {
    var latestPrediction : String = "…" // a variable containing the latest CoreML prediction
    var objectName:String = "…" // variable containing the value of the current object found by CoreML
    static var displayName:String = "..."
    var oldAnchor : ARAnchor? = nil
    var state : Int = 0           // variable containing the actual state of the recognition :
    /* 0 : initialisation
     1 : Detect CurveClosed ==> Display "Open it" on Curve
     2 : Detect CurveOpen ==> Remove CurveClosed Node and display "Go to charger"
     3 : Detect ChargerClosed ==> Remove CurveOpen node dans display "Rise up"
     4 : Detect ChargerOpen ==> Remove ChargerClosed node and display "Go back from the printer"
     5 : Detect ADF closed ==> Remove ChargerOpen node and display "Open Scanner"
     6 : Detect ADF open ==> Remove ADFClosed node and display "Find DF1"
     7 : Detect DF1Closed ==> Remove ADFOpen node and display "Pull DF1"
     8 : Detect DF1Open ==> Remove DF1Closed node and display "Close DF1"
     9 : Detect DF1Closed ==> Remove DF1Open node and display "Close Scanner"
     10 : Detect ADFClosed ==> Remove DF1Closed node and display "Close charger"
     11 : Detect ChargerClosed ==> Remove "ADFClosed" node and display "Close curve"
     12 : Detect CurveClosed ==> Remove ChargerClosed node and display "End paperjam removal !"
     13 : go to 0
                                         */
    
    let debugLabel = SKLabelNode(text: "State")
    
    override func didMove(to view: SKView) {
        debugLabel.position = CGPoint(x:450,y:480)
        debugLabel.fontSize = 20
        debugLabel.fontName = "DevanagariSangamMN-Bold"
        debugLabel.fontColor = UIColor.green
        addChild(debugLabel)
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        var predictionFloat : Double = 0.0 // variable to cast the prediction var
        
        if let currentFrame = sceneView.session.currentFrame {
            DispatchQueue.global(qos: .background).async {
                do {
                    let model = try VNCoreMLModel(for:MyModel().model)
                    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                        // Jump onto the main thread
                        DispatchQueue.main.async {
                            var prediction:String = "…" // variable containing the level of prediction
                            
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
                            prediction = classifications.components(separatedBy: "- ")[1]
                            self.objectName = classifications.components(separatedBy: "-")[0]
                            self.objectName = self.objectName.components(separatedBy: ",")[0]
                            predictionFloat = (prediction as NSString).doubleValue
                            
                            self.debugLabel.text = String(format:"%d",self.state)
                            self.debugLabel.text = self.debugLabel.text! + self.objectName
                            
                            //print(result.identifier)
                        }
                    })
                    
                    let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                    try handler.perform([request])
                } catch {}
                
                
                //Add anchor if prediction is bigger than 0.5
                if(predictionFloat > 0.5 && self.latestPrediction != self.objectName){
                    
                    // get if the object is detected
                    let removeAnchor = self.stateText()
                    
                    // remove the old anchor
                    if self.oldAnchor != nil && removeAnchor{
                        sceneView.session.remove(anchor: self.oldAnchor!)
                    }
                    
                    // If the object isn't found on the screen, we don't add an anchor
                    if(!removeAnchor){
                        return
                    }
                    
                    //var dist : CGFloat = 0.0
                    
                    //for result in sceneView.hitTest(CGPoint(x: 0.5, y: 0.5), types: [.existingPlaneUsingExtent, .featurePoint]) {
                        //dist = result.distance
                    //}
                    // Create a transform with a translation of 0.4 meters in front of the camera
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.4
                    let transform = simd_mul(currentFrame.camera.transform, translation)
                    //print(translation)
                    
                    // Add a new anchor to the session
                    let anchor = ARAnchor(transform: transform)
                    
                    // Set the identifier
                    self.oldAnchor = anchor
                    sceneView.session.add(anchor: anchor)
                }
            }
        }
    }
    
    // Function stateText
    // Choose text to display from the states
    // Return : true if object found and can go to next step
    func stateText() -> Bool{
        // Update last object found
        self.latestPrediction = self.objectName
        
        // Remove whitespace in the prediction
        self.latestPrediction = self.latestPrediction.trimmingCharacters(in: .whitespaces)
        
        // Choice of text to display from the states
        switch self.state {
        case 0 :
            self.state = 1
            //Scene.displayName = "Go to curve, left from charger"
            return false
        case 1 :
            if(self.latestPrediction == "CurveClosed"){
                Scene.displayName = "Open it"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 2 :
            if(self.latestPrediction == "CurveOpen"){
                Scene.displayName = "Go right..."
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 3 :
            if(self.latestPrediction == "ChargerClosed"){
                Scene.displayName = "Rise up"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 4 :
            if(self.latestPrediction == "ChargerOpen"){
                Scene.displayName = "Go back to show the closed scanner"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 5 :
            if(self.latestPrediction == "ADFClosed"){
                Scene.displayName = "Open scanner"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 6 :
            if(self.latestPrediction == "ADFOpen"){
                Scene.displayName = "Find DF1 (green)"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 7 :
            if(self.latestPrediction == "DF1Closed"){
                Scene.displayName = "Pull DF1"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 8 :
            if(self.latestPrediction == "DF1Open"){
                Scene.displayName = "Close DF1 (Show DF1 button)"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 9 :
            if(self.latestPrediction == "DF1Closed"){
                Scene.displayName = "Close Scanner"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 10 :
            if(self.latestPrediction == "ADFClosed"){
                Scene.displayName = "Close charger"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 11 :
            if(self.latestPrediction == "ChargerClosed"){
                Scene.displayName = "Close curve"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        case 12 :
            if(self.latestPrediction == "CurveClosed"){
                Scene.displayName = "END FIXING PRINTER !"
                self.state = self.state+1
            }else{
                return false
            }
            return true
        default:
            return false
        }
    }
    
    // Function touchesBegan
    // Used if the user want to restart the debugging of the printer when the debugging is done
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(self.state == 13){
            self.state = 0
        }
    }
}
