//
//  ViewController.swift
//  SpheresARApp
//
//  Created by john bradley on 3/31/18.
//  Copyright © 2018 john. All rights reserved.
//Project:
//ARKit distance based opacity
//Create an ARKit app that places 2" diameter spheres (10x) randomly around you at a distance of at least 1 foot from each other
//The opacity of spheres should be based on how close the device is to them. Min: 0.2, max: 1.0
//Bonus: Tap the screen to randomly redistribute the spheres around you (with animation)

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    let scene = SCNScene()
    var changeX: Int = -1
    var changeY: Int = -1
    var changeZ: Int = -1
    var globePositions: [[Float]] = []
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.delegate = self
        positions()
        addTapGestureToSceneView()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        
        
        // Set the scene to the view
        sceneView.self.scene = scene
        positions()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        positions()
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        
    }
    func createSpheres(at position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 2)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/earth.jpeg")
        sphere.firstMaterial = material
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = position
        return sphereNode
    }
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        print("did tap")
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else { return }
        node.removeFromParentNode()
    }


    func positions() {
        var i = 0
            while i < 10 {
                self.changeX = random(-20..<20)
                self.changeY = random(-20..<20)
                self.changeZ = random(-20..<20)
                let check = checkDistance(x: Float(self.changeX), y: Float(self.changeY), z: Float(self.changeZ))
                print(check)
                if check == true {
                    print(check)
                    let position = SCNVector3(self.changeX,self.changeY, self.changeZ)
                    let globe = createSpheres(at: position)
                    self.scene.rootNode.addChildNode(globe)
                    self.globePositions.append([Float(self.changeX), Float(self.changeY), Float(self.changeZ)])
                    i = i + 1
            }
        }
    }
 
    func checkDistance(x: Float, y: Float, z: Float) -> Bool {
        var bool = true
        for i in self.globePositions {
        print(i)
        var a = (x - i[0])
        a = a*a
        var b = (y  - i[1])
        b = b*b
        var c = (z - i[2])
        c = c*c
        let length: Float = sqrtf(Float(a + b + c))
        print("length:", length)
        if length < 12 {
            print("length at false: ", length)
            bool = false
            }
        }
        return bool
    }
    func random(_ range:Range<Int>) -> Int {
        return range.lowerBound + Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        print("session")
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        print("currentTransform:", location)
    }
//    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        guard let pointOfView = sceneView.pointOfView else { return }
//        let transform = pointOfView.transform
//        let orientation = SCNVector3(-transform.m31, -transform.m32, transform.m33)
//        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
//        let currentPositionOfCamera = orientation + location
//        print(currentPositionOfCamera)
//    }
    
//    currentTransform: simd_float4x4([[-0.0485429, -0.931665, 0.360062, 0.0)], [0.998819, -0.0445781, 0.0193128, 0.0)], [-0.00194216, 0.360574, 0.932728, 0.0)], [-0.0230406, -0.00373207, 0.00755047, 1.0)]])

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.

    


    
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
