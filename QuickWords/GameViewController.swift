//
//  GameViewController.swift
//  LightningWords
//
//  Created by Peter Ostiguy on 9/12/16.
//  Copyright (c) 2016 Peter Ostiguy. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameplayKit
import GameKit



class GameViewController: UIViewController, GKTurnBasedMatchmakerViewControllerDelegate {
    

    
    func updateMatchData(_ matchData: GKTurnBasedMatch) {
        print("HELLO!!!!")
        print(matchData.participants![1])
        let opponent = matchData.participants![1]
       // matchData.endTurnWithNextParticipants([opponent], turnTimeout: GKTurnTimeoutDefault, matchData: matchData, completionHandler: nil)
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                       target: self,
                                                       selector: #selector(GameViewController.timerDidEnd(_:)),
                                                       userInfo: chosenWord,
                                                       repeats: true)
        //currentMatch?.endTurnWithNextParticipants(
        //[opponent()],
        //turnTimeout: GKTurnTimeoutDefault,
        // matchData: matchData,
        //  completionHandler: nil
        //  )
        
    }
    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFind match: GKTurnBasedMatch) {
        dismiss(animated: true) { self.updateMatchData(match) }
    }
    
    func player(_ player: GKPlayer, receivedTurnEventForMatch match: GKTurnBasedMatch, didBecomeActive: Bool) {
        updateMatchData(match)
    }

    
    func turnBasedMatchmakerViewController(_ viewController: GKTurnBasedMatchmakerViewController, didFailWithError error: Error) {
        print(error)
    }
    
    func turnBasedMatchmakerViewControllerWasCancelled(_ viewController: GKTurnBasedMatchmakerViewController) {print("cancelled")}

    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var lightNode: MDLLight!
    var letterList = [String]()
    var vowelList = [String]()
    var givenLetters = [String]()
    var chosenWord = [String]()
    var letterPlacementArray = [String]()
    var tile1 = SCNNode()
    var tile2 = SCNNode()
    var tile3 = SCNNode()
    var tile4 = SCNNode()
    var tile5 = SCNNode()
    var tile6 = SCNNode()
    var removedNodePosition = Float()
    var finalWord = String()
    var finalText = SCNNode()
    var timerText = SCNNode()
    var tileEscape = SCNNode()
    var replayR = SCNNode()
    var replayE = SCNNode()
    var replayP = SCNNode()
    var replayL = SCNNode()
    var replayA = SCNNode()
    var replayY = SCNNode()
    var wordScore = Int()
    
    var isWordValid = Bool()
    
    var timer = Timer()
    let timeInterval:TimeInterval = 1.0
    let timerEnd:TimeInterval = 10.0
    var timeCount:TimeInterval = 10.0
    var timerOn = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                       target: self,
                                                       selector: #selector(GameViewController.timerDidEnd(_:)),
                                                       userInfo: chosenWord,
                                                       repeats: true)
        
        let r = GKMatchRequest()
        r.minPlayers = 2
        r.maxPlayers = 2
        r.defaultNumberOfPlayers = 2
        let vc = GKTurnBasedMatchmakerViewController(
            matchRequest: r
        )
        vc.turnBasedMatchmakerDelegate = self
//        self.presentViewController(vc, animated: true, completion: nil)
//        self.dismissViewControllerAnimated(true, completion: nil)
        
        
    
        
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let letters = try! fm.contentsOfDirectory(atPath: path + "/Letters")
        let vowels = try! fm.contentsOfDirectory(atPath: path + "/Vowels")
        
        for letter in letters {
            if letter.hasSuffix("jpeg") {
                let letterTitle = letter.replacingOccurrences(of: ".jpeg", with: "", options: NSString.CompareOptions.literal, range: nil)
                letterList.append(letterTitle)
            }
        }
        for vowel in vowels {
            if vowel.hasSuffix("jpeg") {
                let vowelTitle = vowel.replacingOccurrences(of: ".jpeg", with: "", options: NSString.CompareOptions.literal, range: nil)
                vowelList.append(vowelTitle)
            }
        }
        
        setupView()
        setupScene()
        setupCamera()
        setLetters()
        spawnFloor()
        spawnShelf()
        spawnShelfBack()
        spawnShelfSide1()
        spawnShelfSide2()
        spawnShelfTop()
        spawnShelfBottom()
        setupTimer()
        setupText()
        spawnTileEscape()

    }
    
    func setLetters(){
        tile1.removeFromParentNode()
        tile2.removeFromParentNode()
        tile3.removeFromParentNode()
        tile4.removeFromParentNode()
        tile5.removeFromParentNode()
        tile6.removeFromParentNode()
        chosenWord = []
        givenLetters = []
        finalWord = ""
        wordScore = 0
        letterList = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterList) as! [String]
        vowelList = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: vowelList) as! [String]
        givenLetters += letterList[0...5]
        letterPlacementArray = letterList
        spawnTile1()
        spawnTile2()
        spawnTile3()
        spawnTile4()
        spawnTile5()
        spawnTile6()

    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        scnView.autoenablesDefaultLighting = true
    }
    
    



    
    func setupTimer(){
        let text = SCNText(string: "", extrusionDepth: 1)
        timerText.geometry = text
        timerText.position = SCNVector3(x: -1.15, y: 6.0, z: 0.5)
        scnScene.rootNode.addChildNode(timerText)
        timerText.scale = SCNVector3Make(0.3, 0.3, 0.3)
        timerText.name = "shelf"
        text.materials.first?.diffuse.contents = UIColor.black
    }
    
    func setupText() {
        let text = SCNText(string: "", extrusionDepth: 1)
        finalText.geometry = text
        finalText.position = SCNVector3(x: -1.15, y: 6.0, z: 0.5)
        scnScene.rootNode.addChildNode(finalText)
        finalText.scale = SCNVector3Make(0.3, 0.3, 0.3)
        text.materials.first?.diffuse.contents = UIColor.black
        finalText.name = "shelf"
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = UIImage(named: "Backgrounds/wall.jpg")
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.40, alpha: 0.7)
        scnScene.rootNode.addChildNode(ambientLightNode)
//        scnView.allowsCameraControl = true

    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 3, z: 14.5)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func changeTile1(){
        if tile1.opacity < 1.0 && Double(tile1.position.x) > Double(removedNodePosition) {
            let newPosition = tile1.position.x - 1.2
            tile1.position = SCNVector3(x: newPosition, y: 2.5, z: 0.0)
            tile1.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            tile1.opacity = tile1.opacity + 0.01
        }
    }
    func changeTile2(){
        if tile2.opacity < 1.0 && Double(tile2.position.x) > Double(removedNodePosition){
            let newPosition = (tile2.position.x - 1.2)
            tile2.position = SCNVector3(x: newPosition, y: 2.5, z: 0.0)
            tile2.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            tile2.opacity = tile2.opacity + 0.01
        }
    }
    func changeTile3(){
        if tile3.opacity < 1.0 && Double(tile3.position.x) > Double(removedNodePosition){
            let newPosition = tile3.position.x - 1.2
            tile3.position = SCNVector3(x: newPosition, y: 2.5, z: 0.0)
            tile3.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            tile3.opacity = tile3.opacity + 0.01
        }
    }
    func changeTile4(){
        if tile4.opacity < 1.0 && Double(tile4.position.x) > Double(removedNodePosition){
            let newPosition = tile4.position.x - 1.2
            tile4.position = SCNVector3(x: newPosition, y: 2.5, z: 0.0)
            tile4.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            tile4.opacity = tile4.opacity + 0.01
        }
    }
    func changeTile5(){
        if tile5.opacity < 1.0 && Double(tile5.position.x) > Double(removedNodePosition) {
            let newPosition = tile5.position.x - 1.2
            tile5.position = SCNVector3(x: newPosition, y: 2.5, z: 0.0)
            tile5.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            tile5.opacity = tile5.opacity + 0.01
            
        }
    }
    func changeTile6(){
        if tile6.opacity < 1.0 && Double(tile6.position.x) > Double(removedNodePosition){
            let newPosition = tile6.position.x - 1.2
            tile6.position = SCNVector3(x: newPosition, y: 2.5, z: 0.0)
            tile6.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            tile6.opacity = tile6.opacity + 0.01
        }
    }
    
    func spawnTileEscape() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        tileEscape = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(tileEscape)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/X.jpeg")
        tileEscape.position = SCNVector3(x: 3.0, y: 8.75, z: 0.3)
        tileEscape.name = "escape"
    }
    
    func spawnTile1() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        tile1 = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(tile1)
        tile1.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Vowels/"+"\(vowelList[0])"+".jpeg")
        tile1.position = SCNVector3(x: 2.6, y: -2.25, z: 0.3)
        tile1.name = vowelList[0]
    }
    func spawnTile2() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        tile2 = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(tile2)
        tile2.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Vowels/"+"\(vowelList[1])"+".jpeg")
        tile2.position = SCNVector3(x: -0.9, y: -2.25, z: 2.1)
        tile2.name = vowelList[1]
    }
    func spawnTile3() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        tile3 = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(tile3)
        tile3.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/"+"\(givenLetters[2])"+".jpeg")
        tile3.position = SCNVector3(x: -3.3, y: -2.25, z: 0.5)
        tile3.name = givenLetters[2]
    }
    func spawnTile4() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        tile4 = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(tile4)
        tile4.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/"+"\(givenLetters[3])"+".jpeg")
        tile4.position = SCNVector3(x: 1.5, y: -2.25, z: 0.8)
        tile4.name = givenLetters[3]
    }
    func spawnTile5() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        tile5 = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(tile5)
        tile5.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/"+"\(givenLetters[4])"+".jpeg")
        tile5.position = SCNVector3(x: 0.0, y: -2.25, z: 0.0)
        tile5.name = givenLetters[4]
    }
    func spawnTile6() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        tile6 = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(tile6)
        tile6.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        tile6.position = SCNVector3(x: -1.8, y: -2.25, z: -1.1)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/"+"\(givenLetters[5])"+".jpeg")
        tile6.name = givenLetters[5]
    }
    
    func spawnReplayR() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        replayR = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(replayR)
        replayR.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        replayR.position = SCNVector3(x: -3.0, y: -2.25, z: 2.1)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/R.jpeg")
        replayR.name = "replay"
    }
    func spawnReplayE() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        replayE = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(replayE)
        replayE.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        replayE.position = SCNVector3(x: -1.8, y: -2.0, z: 2.1)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/E.jpeg")
        replayE.name = "replay"
    }
    func spawnReplayP() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        replayP = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(replayP)
        replayP.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        replayP.position = SCNVector3(x: -0.6, y: -1.75, z: 2.1)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/P.jpeg")
        replayP.name = "replay"
    }
    func spawnReplayL() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        replayL = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(replayL)
        replayL.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        replayL.position = SCNVector3(x: 0.6, y: -1.5, z: 2.1)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/L.jpeg")
        replayL.name = "replay"
    }
    func spawnReplayA() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        replayA = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(replayA)
        replayA.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        replayA.position = SCNVector3(x: 1.8, y: -1.25, z: 2.1)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/A.jpeg")
        replayA.name = "replay"
    }
    func spawnReplayY() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.1)
        replayY = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(replayY)
        replayY.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        replayY.position = SCNVector3(x: 3.0, y: -1.0, z: 2.1)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Letters/Y.jpeg")
        replayY.name = "replay"
    }
    
    func spawnFloor() {
        var geometry:SCNGeometry
        geometry = SCNBox(width: 30.0, height: 0.1, length: 11.0, chamferRadius: 0.0)
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.position = SCNVector3(x: 0.0, y: -3.0, z: 0.0)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Backgrounds/carpet.jpg")
        geometryNode.name = "floor"
    }
    
    func spawnShelf(){
        var geometry:SCNGeometry
        geometry = SCNBox(width: 8.6, height: 0.3, length: 8.0, chamferRadius: 0.0)
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.position = SCNVector3(x: 0.0, y: 1.6, z: -3.0)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Backgrounds/wood.jpg")
        geometryNode.name = "shelf"
    }
    
    func spawnShelfBack(){
        var geometry:SCNGeometry
        geometry = SCNBox(width: 8.6, height: 8.1, length: 0.1, chamferRadius: 0.0)
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.position = SCNVector3(x: 0.0, y: 1.4, z: -4.0)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Backgrounds/wood.jpg")
        geometryNode.name = "shelf"
    }
    
    func spawnShelfSide1(){
        var geometry:SCNGeometry
        geometry = SCNBox(width: 0.3, height: 8.5, length: 8.0, chamferRadius: 0.0)
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.position = SCNVector3(x: -4.2, y: 1.4, z: -3.0)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Backgrounds/wood.jpg")
        geometryNode.name = "shelf"
    }
    func spawnShelfSide2(){
        var geometry:SCNGeometry
        geometry = SCNBox(width: 0.3, height: 8.5, length: 8.0, chamferRadius: 0.0)
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.position = SCNVector3(x: 4.2, y: 1.4, z: -3.0)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Backgrounds/wood.jpg")
        geometryNode.name = "shelf"
    }
    
    func spawnShelfTop(){
        var geometry:SCNGeometry
        geometry = SCNBox(width: 8.6, height: 0.3, length: 8.0, chamferRadius: 0.0)
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.friction = 0.1
        geometryNode.position = SCNVector3(x: 0.0, y: 5.4, z: -3.0)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Backgrounds/wood.jpg")
        geometryNode.name = "shelf"
    }
    func spawnShelfBottom(){
        var geometry:SCNGeometry
        geometry = SCNBox(width: 8.6, height: 0.3, length: 8.0, chamferRadius: 0.0)
        let geometryNode = SCNNode(geometry: geometry)
        scnScene.rootNode.addChildNode(geometryNode)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.friction = 0.1
        geometryNode.position = SCNVector3(x: 0.0, y: -2.8, z: -3.0)
        geometry.materials.first?.diffuse.contents = UIImage(named: "Backgrounds/wood.jpg")
        geometryNode.name = "shelf"
    }
    
    
    func handleTouchFor(_ node: SCNNode) {
        if node.name == "escape" {
            print("escape!")
            performSegue(withIdentifier: "tileEscapeSegue", sender: tileEscape)
        }
        
        else if node.name != "floor" && node.name != "shelf" && node.opacity == 1.0 && node.name != "replay"{
            node.opacity = 0.99 - (0.01 * CGFloat(chosenWord.count))
            let blockXPlacement = -3.2 + Double(chosenWord.count) * 1.3
            node.position = SCNVector3(x: Float(blockXPlacement), y: 2.5, z: 0.0)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody!.mass = 25.0
            node.physicsBody!.allowsResting = true
            chosenWord.append(node.name!)
        }
        else if node.name != "floor" && node.name != "shelf" && node.opacity != 1.0 && node.name != "replay"{
            removedNodePosition = node.position.x
            let removedNodeOpacity = Double(node.opacity)
            if removedNodeOpacity < 1.0 && removedNodeOpacity > 0.985 {
                chosenWord.remove(at: 0)
            }
            else if removedNodeOpacity < 0.985 && removedNodeOpacity > 0.975 {
                chosenWord.remove(at: 1)
            }
            else if removedNodeOpacity < 0.975 && removedNodeOpacity > 0.965 {
                chosenWord.remove(at: 2)
            }
            else if removedNodeOpacity < 0.965 && removedNodeOpacity > 0.955 {
                chosenWord.remove(at: 3)
            }
            else if removedNodeOpacity < 0.955 && removedNodeOpacity > 0.945 {
                chosenWord.remove(at: 4)
            }
            else if removedNodeOpacity < 0.945 && removedNodeOpacity > 0.935 {
                chosenWord.remove(at: 5)
            }
            node.opacity = 1.0
            changeTile1()
            changeTile2()
            changeTile3()
            changeTile4()
            changeTile5()
            changeTile6()
            if node.name == tile1.name{
                node.position = SCNVector3(x: 2.6, y: -1.75, z: 0.3)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            }
            else if node.name == tile2.name{
                node.position = SCNVector3(x: -0.9, y: -1.75, z: 2.1)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            }
            else if node.name == tile3.name{
                node.position = SCNVector3(x: -3.3, y: -1.75, z: 0.5)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            }
            else if node.name == tile4.name{
                node.position = SCNVector3(x: 1.5, y: -1.75, z: 0.8)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            }
            else if node.name == tile5.name{
                node.position = SCNVector3(x: 0.0, y: -1.75, z: 0.0)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            }
            else if node.name == tile6.name{
                node.position = SCNVector3(x: -1.8, y: -1.75, z: -1.1)
                node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            }
        }
        else if node.name == "replay"{
            setLetters()
            finalText.removeFromParentNode()
            replayR.removeFromParentNode()
            replayE.removeFromParentNode()
            replayP.removeFromParentNode()
            replayL.removeFromParentNode()
            replayA.removeFromParentNode()
            replayY.removeFromParentNode()
            setupTimer()
            timer.invalidate()
            timeCount = 10
            timerOn = true
            timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                           target: self,
                                                           selector: #selector(GameViewController.timerDidEnd(_:)),
                                                           userInfo: chosenWord,
                                                           repeats: true)

            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults.first!
            handleTouchFor(result.node)
        }
    }
    
    func timeString(_ time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format:"%01i",Int(seconds))
    }
    
    func timerDidEnd(_ timer:Timer){
        timeCount = timeCount - timeInterval
        if timerOn == true {
            if timeCount <= 0 {
                timerOn = false
                timerText.removeFromParentNode()
                hideTile1()
                hideTile2()
                hideTile3()
                hideTile4()
                hideTile5()
                hideTile6()
                createWord()
                checkWord()
            }
            else {
                let text = SCNText(string: timeString(timeCount), extrusionDepth: 1)
                text.materials.first?.diffuse.contents = UIColor.black
                timerText.geometry = text
            }
        }
    }
    
    func createWord(){
        for letter in chosenWord{
            finalWord += letter
        }
    }
    
    func hideTile1() {
        if tile1.opacity == 1.0 {
            tile1.removeFromParentNode()

        }
    }
    func hideTile2() {
        if tile2.opacity == 1.0 {
            tile2.removeFromParentNode()
        }
    }
    func hideTile3() {
        if tile3.opacity == 1.0 {
            tile3.removeFromParentNode()
        }
    }
    func hideTile4() {
        if tile4.opacity == 1.0 {
            tile4.removeFromParentNode()
        }
    }
    func hideTile5() {
        if tile5.opacity == 1.0 {
            tile5.removeFromParentNode()
        }
    }
    func hideTile6() {
        if tile6.opacity == 1.0 {
            tile6.removeFromParentNode()
        }
    }
    
    func findScore() {
        for letter in chosenWord{
            if letter == "A" {
                wordScore += 1
            }
            else if letter == "B" {
                wordScore += 3
            }
            else if letter == "C" {
                wordScore += 3
            }
            else if letter == "D" {
                wordScore += 2
            }
            else if letter == "E" {
                wordScore += 1
            }
            else if letter == "F" {
                wordScore += 4
            }
            else if letter == "G" {
                wordScore += 2
            }
            else if letter == "H" {
                wordScore += 4
            }
            else if letter == "I" {
                wordScore += 1
            }
            else if letter == "J" {
                wordScore += 5
            }
            else if letter == "K" {
                wordScore += 5
            }
            else if letter == "L" {
                wordScore += 1
            }
            else if letter == "M" {
                wordScore += 3
            }
            else if letter == "N" {
                wordScore += 1
            }
            else if letter == "O" {
                wordScore += 1
            }
            else if letter == "P" {
                wordScore += 3
            }
            else if letter == "Q" {
                wordScore += 5
            }
            else if letter == "R" {
                wordScore += 1
            }
            else if letter == "S" {
                wordScore += 1
            }
            else if letter == "T" {
                wordScore += 1
            }
            else if letter == "U" {
                wordScore += 1
            }
            else if letter == "V" {
                wordScore += 4
            }
            else if letter == "W" {
                wordScore += 4
            }
            else if letter == "X" {
                wordScore += 5
            }
            else if letter == "Y" {
                wordScore += 3
            }
            else if letter == "Z" {
                wordScore += 5
            }
        }
    }
    

    
    func checkWord() {
        let scriptUrl = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=dict.1.1.20160524T165204Z.14c112c0d0312cef.fa4f3cb65f43e438c70fe5681b51dd96c9247e1a&lang=en-ru&text="
        let urlWithParams = scriptUrl + finalWord
        let myUrl = URL(string: urlWithParams)
        let request = NSMutableURLRequest(url:myUrl!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil{
                print("error= \(error)")
                return
            }
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            let lengthOfWord = self.finalWord.characters.count
            if responseString!.length > 25 {
                self.isWordValid = true
                self.findScore()
                print(self.wordScore)
                self.saveHighscore(self.wordScore)
                self.displayScore(self.wordScore)
                
                
                //                var text = SCNText()
                if  lengthOfWord < 4 {
                    let text = SCNText(string: "Your word is \n        " + self.finalWord, extrusionDepth: 1)
                    self.finalText.geometry = text
                    self.finalText.position = SCNVector3(x: -2.7, y: -1.3, z: 0.5)
                    self.finalText.scale = SCNVector3Make(0.098, 0.098, 0.098)
                    text.materials.first?.diffuse.contents = UIColor.white
                    let font = UIFont(name: "Times New Roman", size: 10.0)
                    text.font = font
                    text.alignmentMode = kCAAlignmentCenter
                    self.finalText.geometry = text
                    //                    timerOn = false
                }
                else if lengthOfWord == 4{
                    let text = SCNText(string: "Your word is \n      " + self.finalWord, extrusionDepth: 1)
                    self.finalText.geometry = text
                    self.finalText.position = SCNVector3(x: -2.7, y: -1.3, z: 0.5)
                    self.finalText.scale = SCNVector3Make(0.098, 0.098, 0.098)
                    text.materials.first?.diffuse.contents = UIColor.white
                    let font = UIFont(name: "Times New Roman", size: 10.0)
                    text.font = font
                    text.alignmentMode = kCAAlignmentCenter
                    self.finalText.geometry = text
                    //                    timerOn = false
                    
                }
                else if lengthOfWord < 7{
                    let text = SCNText(string: "Your word is \n    " + self.finalWord, extrusionDepth: 1)
                    self.finalText.geometry = text
                    self.finalText.position = SCNVector3(x: -2.7, y: -1.1, z: 0.5)
                    self.finalText.scale = SCNVector3Make(0.098, 0.098, 0.098)
                    text.materials.first?.diffuse.contents = UIColor.white
                    let font = UIFont(name: "Times New Roman", size: 10.0)
                    text.font = font
                    text.alignmentMode = kCAAlignmentCenter
                    self.finalText.geometry = text
                    //                    timerOn = false
                }
            }
            else {
                self.isWordValid = false
                if lengthOfWord == 0 {
                    let text = SCNText(string: "   You Didn't \n Enter A Word!", extrusionDepth: 1)
                    self.finalText.geometry = text
                    self.finalText.position = SCNVector3(x: -2.7, y: -1.1, z: 0.5)
                    self.finalText.scale = SCNVector3Make(0.098, 0.098, 0.098)
                    text.materials.first?.diffuse.contents = UIColor.white
                    let font = UIFont(name: "Times New Roman", size: 10.0)
                    text.font = font
                    text.alignmentMode = kCAAlignmentCenter
                    self.finalText.geometry = text
                }
                else if lengthOfWord < 5 {
                    let text = SCNText(string: "Sorry!   " + self.finalWord + "\n is not a word.", extrusionDepth: 1)
                    self.finalText.geometry = text
                    self.finalText.position = SCNVector3(x: -2.7, y: -1.1, z: 0.5)
                    self.finalText.scale = SCNVector3Make(0.098, 0.098, 0.098)
                    text.materials.first?.diffuse.contents = UIColor.white
                    let font = UIFont(name: "Times New Roman", size: 10.0)
                    text.font = font
                    text.alignmentMode = kCAAlignmentCenter
                    self.finalText.geometry = text
                }
                
                else {
                    let text = SCNText(string: "Sorry! " + self.finalWord + "\n is not a word.", extrusionDepth: 1)
                    self.finalText.geometry = text
                    self.finalText.position = SCNVector3(x: -2.7, y: -1.1, z: 0.5)
                    self.finalText.scale = SCNVector3Make(0.098, 0.098, 0.098)
                    text.materials.first?.diffuse.contents = UIColor.white
                    let font = UIFont(name: "Times New Roman", size: 10.0)
                    text.font = font
                    text.alignmentMode = kCAAlignmentCenter
                    self.finalText.geometry = text
                }
            }
            self.spawnReplayR()
            self.spawnReplayE()
            self.spawnReplayP()
            self.spawnReplayL()
            self.spawnReplayA()
            self.spawnReplayY()
            
        }
        self.setupText()
        task.resume()
    }
    
    func displayScore(_ score:Int){
        let text = SCNText(string: "\(score) pts", extrusionDepth: 1)
        timerText.geometry = text
        timerText.position = SCNVector3(x: -2.9, y: 6.0, z: 0.5)
        scnScene.rootNode.addChildNode(timerText)
        timerText.scale = SCNVector3Make(0.2, 0.2, 0.2)
        timerText.name = "shelf"
        text.materials.first?.diffuse.contents = UIColor.black
    }
    
    func saveHighscore(_ score:Int) {
        
 
        if GKLocalPlayer.localPlayer().isAuthenticated {
            
            
            let scoreReporter = GKScore(leaderboardIdentifier: "LightningWordLeaderboard")
            
            scoreReporter.value = Int64(wordScore)
            print(score)
            print(wordScore)
            
            let scoreArray: [GKScore] = [scoreReporter]
            
            GKScore.report(scoreArray, withCompletionHandler: {(error : NSError?) -> Void in
                if error != nil {
                    print("error!!!!!!!")
                }
            } as? (Error?) -> Void)
            
        }
        
    }
}
