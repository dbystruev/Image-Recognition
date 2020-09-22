//
//  ViewController.swift
//  Image Recognition
//
//  Created by Denis Bystruev on 22.09.2020.
//

import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let videoPlayer: AVPlayer = {
        let url = Bundle.main.url(forResource: "theatre",
                                  withExtension: "mp4",
                                  subdirectory: "art.scnassets")!
        return AVPlayer(url: url)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Track images
        configuration.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources",
                                                                         bundle: nil)!
        configuration.maximumNumberOfTrackedImages = 2
        
//        configuration.planeDetection = [.horizontal]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            add(imageAnchor, to: node)
        case let planeAncor as ARPlaneAnchor:
            add(planeAncor, to: node)
        default:
            print(#line, #function, "Unknown anchor \(anchor)")
        }
    }
    
    func add(_ imageAnchor: ARImageAnchor, to node: SCNNode) {
        let size = imageAnchor.referenceImage.physicalSize
        let width = imageAnchor.name?.starts(with: "face") == true ?
            15.6 / 7.3414 * size.width :
            15.6 / 5.5065 * size.width
        let plane = SCNPlane(width: width, height: size.height)
        plane.firstMaterial?.diffuse.contents = videoPlayer
        videoPlayer.play()
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
//        planeNode.opacity = 0.25
        planeNode.runAction(
            .sequence([
                .wait(duration: 5),
                .fadeOut(duration: 2),
                .removeFromParentNode(),
            ])
        )
        
        node.addChildNode(planeNode)
    }
    
    func add(_ planeAnchor: ARPlaneAnchor, to node: SCNNode) {
        print(#line,
              #function,
              planeAnchor.center,
              planeAnchor.extent)
    }
    
}
