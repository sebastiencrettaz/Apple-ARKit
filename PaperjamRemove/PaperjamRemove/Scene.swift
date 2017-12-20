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
    var latestPrediction : String = "…"         // variable containing the latest CoreML prediction
    var objectName:String = "…"                 // variable containing the value of the current object found by CoreML
    static var displayName:String = "..."       // variable containing the text to display on the screen
    var oldAnchor : ARAnchor? = nil             // variable containing the actual node displayed on the screen. Used to remove it when
                                                // the app goes to the next state
    static var state : Int = 0                  // variable containing the actual state of the fixing
    var timeStart : Double = 0.0
    var time : Double = 0.0
    var initialize : Bool = true
    static var end : Bool = false
    
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
        time = currentTime
        // Get the time where the app started
        if(initialize){
            timeStart = currentTime
            initialize = false
        }
        
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
                            
                            self.debugLabel.text = String(format:"%d",Scene.state)
                            self.debugLabel.text = self.debugLabel.text! + self.objectName
                            self.debugLabel.text = self.debugLabel.text! + String(format:"%f",predictionFloat)
                            
                            //print(result.identifier)
                        }
                    })
                    
                    let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                    try handler.perform([request])
                } catch {}
                
                
                //Add anchor if prediction is bigger than 0.5
                if(predictionFloat > 0.75 && self.latestPrediction != self.objectName){
                    
                    // true if the object is detected in the right state
                    let removeAnchor = self.stateText()
                    
                    // remove the old anchor
                    if self.oldAnchor != nil && removeAnchor{
                        sceneView.session.remove(anchor: self.oldAnchor!)
                    }
                    // If the object isn't found on the screen, we won't add an anchor
                    if(!removeAnchor){
                        return
                    }
                    
                    
                    // Create a transform with a translation of 0.4 meters in front of the camera
                    var translation = matrix_identity_float4x4
                    translation.columns.3.z = -0.4
                    let transform = simd_mul(currentFrame.camera.transform, translation)
                    
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
        
        // Remove space character in the prediction
        self.latestPrediction = self.latestPrediction.trimmingCharacters(in: .whitespaces)
        
        // Choice of text to display from the states
        switch Scene.state {
        case 0 :
            if(time > timeStart + 2.0){
                Scene.state = 1
            }
            Scene.end = false
            return false
        case 1 :
            if(self.latestPrediction == "CurveClosed"){
                Scene.displayName = "Open it"
                Scene.state = Scene.state+1
            }else if(self.latestPrediction == "CurveOpen"){
                Scene.state = Scene.state+1
                return false
            }else{
                return false
            }
            break
        case 2 :
            if(self.latestPrediction == "CurveOpen"){
                Scene.displayName = "Go right 👉🏻"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        case 3 :
            if(self.latestPrediction == "ChargerClosed"){
                Scene.displayName = "Rise up"
                Scene.state = Scene.state+1
            }else if(self.latestPrediction == "ChargerOpen"){
                Scene.state = Scene.state+1
                return false
            }else{
                return false
            }
            break
        case 4 :
            if(self.latestPrediction == "ChargerOpen"){
                Scene.displayName = "Open the scanner"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        case 5 :
            if(self.latestPrediction == "ADFOpen"){
                Scene.displayName = "Find DF1 (green)"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        case 6 :
            if(self.latestPrediction == "DF1Closed"){
                Scene.displayName = "Pull DF1"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        case 7 :
            if(self.latestPrediction == "DF1Open"){
                Scene.displayName = "Close DF1 (Show DF1 button)"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        case 8 :
            if(self.latestPrediction == "DF1Closed"){
                Scene.displayName = "Close Scanner"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        case 9 :
            if(self.latestPrediction == "ChargerOpen"){
                Scene.displayName = "Close charger"
                Scene.state = Scene.state+1
            }else if(self.latestPrediction == "ChargerClosed"){
                Scene.state = Scene.state+1
                return false
            }else{
                return false
            }
            break
        case 10 :
            if(self.latestPrediction == "ChargerClosed"){
                Scene.displayName = "Close curve"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        case 11 :
            if(self.latestPrediction == "CurveClosed" || Scene.end){
                Scene.displayName = "END FIXING PRINTER !"
                Scene.state = Scene.state+1
            }else{
                return false
            }
            break
        default:
            return false
        }
        return true
    }
    
    // Function touchesBegan
    // Used if the user want to restart the debugging of the printer when the debugging is done
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(Scene.state == 12){
            Scene.state = 0
        }
    }
}
