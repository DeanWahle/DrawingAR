//
//  ViewController.swift
//  DrawingAR
//
//  Created by Dean Wahle on 1/16/22.
//

import UIKit
import ARKit
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var reset: UIButton!
    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting debug options
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.showsStatistics = true
        //running with configuration
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        //dispose of any resources that can be recreated
    }
    
    //never ending loop, as long as something is being rendered, this
    //function is triggered
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //grabbing position of the camera every time the screen is rendered
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        //obtain current position vector of the phone
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        //obtain orientation vector pointing in the direction of the camera
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        //we need to combine these values to put nodes in front of the camera
        //but "+" doesn't combine vectors, so we need to make a custom function
        let currentPositionOfCamera = orientation + location
        
        DispatchQueue.main.async{
            //when the draw button is pressed, add a sphere node at the position that the camera is looking
            
            if self.draw.isHighlighted{
                //creating sphere
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                //setting position
                sphereNode.position = currentPositionOfCamera
                //adding node to sceneView
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                //coloring the sphere
                sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            } else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.name = "pointer"
                pointer.position = currentPositionOfCamera
                
                self.sceneView.scene.rootNode.enumerateChildNodes({(node, _) in
                    //removing previous pointers
                    if(node.name == "pointer"){
                        node.removeFromParentNode()
                    }
                })
                
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.red
            }
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        //print("reset")
        //pause user session
        self.sceneView.session.pause()
        //remove box node from scene view
        //node is a child of the root node
        //we enumerate through the child nodes, and we remvoe the box from its
        //parent, we remove it from the sceneView
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in node.removeFromParentNode()
        }
        //Now that we removed the box, we are going to rerun the session with the same
        //configuration, but it will reset tracking
        self.sceneView.session.run(configuration, options:
            [.resetTracking, .removeExistingAnchors])
    }
    
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3{
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}
