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
    var changeX: Float?
    var changeY: Float?
    var changeZ: Float?
    var globePositions: [[Float]] = []
    var bool: Bool?
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.delegate = self
        
        addTapGestureToSceneView()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.self.scene = scene
        
//      generates 10x Spheres
        positions()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createSpheres(at position: SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.0254)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "art.scnassets/earth.jpeg")
        sphere.firstMaterial = material
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = position
        sphereNode.opacity = 1.0
        return sphereNode
    }

//    Creates 10x spheres with an earth.jpeg wrapper
    func positions() {
        var i = 0
        while i < 10 {
//          generates 3x random Floats between -1 and 1
            self.changeX = random(-1000..<1000)
            self.changeY = random(-1000..<1000)
            self.changeZ = random(-1000..<1000)

            let position = SCNVector3(self.changeX!,self.changeY!, self.changeZ!)
//          creates a sphere at the x,y,z SCNVector3 positions that were randoms generated
            let sphere = createSpheres(at: position)

//          check the newly created sphere against the already added spheres sets a boolean to false
//          if any of the spheres are within 0.3048 meters of another sphere
            for child in self.scene.rootNode.childNodes {
                self.bool = true
                let distance = sphere.position - child.position
                let length = distance.length()
                if length < 0.3048 {
                    self.bool = false
                }
            }
//          appends the newly generated sphere if it isn't within a foot of any other sphere
            if self.bool == true {
                self.scene.rootNode.addChildNode(sphere)
                self.globePositions.append([Float(self.changeX!), Float(self.changeY!), Float(self.changeZ!)])
                i = i + 1
            }
        }
        print(self.scene.rootNode.childNodes)
    }

    func random(_ range:Range<Float>) -> Float {
        var x = range.lowerBound + Float(arc4random_uniform(UInt32(range.upperBound - range.lowerBound)))
        x = x/1000
        return x
        
    }
    
//  runs everytime a frame changes and resets the opacity of all the spheres based on proximity to the user
//    (0.2 if the SCNNode is more than 1.5 meters away, 1.0 if the user on top of the node)
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        for child in self.scene.rootNode.childNodes {
            let distance = location - child.position
            let length = distance.length()
            var opacity = CGFloat(1) - CGFloat(Float(length)/1.5)
            if opacity > 1.0 {
                child.opacity = 1.0
            }
            else {
                if opacity < 0.2 {
                    opacity = 0.2
                }
                child.opacity = opacity
            }
//            print("child length:", length, "child opacity: ", child.opacity)
        }
    }
//    initializes func listener for a tap
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
// calls refreshView func upon user tap action
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        refreshView()
        
    }
    
//  removes all SCNNodes and runs the positions function to create 10x new ones
    func refreshView() {
        print("refresh")
        for child in self.scene.rootNode.childNodes {
            child.removeFromParentNode()
        }
        positions()
    }
    

    func session(_ session: ARSession, didFailWithError error: Error) {
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    }
}
extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
}
func - (l: SCNVector3, r: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(l.x - r.x, l.y - r.y, l.z - r.z)
}



