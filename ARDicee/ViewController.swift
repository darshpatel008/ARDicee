//
//  ViewController.swift
//  ARDicee
//
//  Created by Darsh viroja  on 29/09/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        
        //        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //
        //        let sphere = SCNSphere(radius: 0.2)
        //
        //        let Material = SCNMaterial()
        //
        //        Material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpg")
        //
        //        sphere.materials = [Material]
        //
        //        let node = SCNNode()
        //
        //        node.position = SCNVector3(0, 0.1, -0.5)
        //
        //        node.geometry = sphere
        //
        //        sceneView.scene.rootNode.addChildNode(node)
        //
        //        sceneView.automaticallyUpdatesLighting = true
        //
        //
        //
        //
        //        sceneView.showsStatistics = true
        //
        //
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //
        //        sceneView.scene = scene
        //
        sceneView.automaticallyUpdatesLighting = true
        
        
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first
        {
            let touchLocation = touch.location(in: sceneView)
            
            let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = result.first
            {
                let dicescene =  SCNScene(named: "art.scnassets/diceCollada.scn")!
                
                if let diceNode = dicescene.rootNode.childNode(withName: "Dice", recursively: true)
                {
                    diceNode.position = SCNVector3(
                        x:hitResult.worldTransform.columns.3.x ,
                        y:hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z:hitResult.worldTransform.columns.3.z
                    )
                    
                    diceNode.scale = SCNVector3(0.5, 0.5, 0.5)
                    roll(dice: diceNode)
                }
            }
        }
    }
    
    func rollAll()
    {
        if !diceArray.isEmpty
        {
            for dice in diceArray
            {
                roll(dice: dice)
            }
            
        }
    }
    
    func roll(dice: SCNNode)
    {
        let randomx = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomz = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomx * 5),
                y: 0,
                z: CGFloat(randomz * 5),
                duration: 0.5))
        
        diceArray.append(dice)
        
        sceneView.scene.rootNode.addChildNode(dice)
    }
    
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem)
    {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        rollAll()
    }
    
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem)
    {
        if !diceArray.isEmpty
        {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
        
    }
    
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor
        {
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planenode = SCNNode()
            
            planenode.position = SCNVector3(planeAnchor.center.x,0, planeAnchor.center.z)
            
            planenode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            
            plane.materials = [gridMaterial]
            
            planenode.geometry = plane
            
            node.addChildNode(planenode)
            
            
        }
        else
        {
            return
        }
    }
    
}
