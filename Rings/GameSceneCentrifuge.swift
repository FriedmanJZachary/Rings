//
//  GameSceneCentrifuge.swift
//  Rings
//
//  Created by Zachary Friedman on 8/3/16.
//  Copyright © 2016 Ellex All rights reserved.
//

import SpriteKit
import Foundation
import AVFoundation


enum GameStateCentrifuge {
    case Playing, GameOver
}


class ObstacleBox: SKSpriteNode {
    var timer = 0.0
    var alive = true
}

class FlipperBox: SKSpriteNode {
    var timer = 0.0
    var alive = true
}

class GameSceneCentrifuge: SKScene, SKPhysicsContactDelegate {
    
    var impulseAngle: CGFloat = 0.0
    var ball: SKSpriteNode!
    var ring: SKSpriteNode!
    var platform: SKSpriteNode!
    var obstacleLayer: SKNode!
    var flipperLayer: SKNode!
    var box: SKNode!
    var label: SKLabelNode!
    var HSlabel: SKLabelNode!
    
    var spawnTimer: CFTimeInterval = 0
    var flipperTimer: CFTimeInterval = 0
    var spawnPoint: SKNode!
    var flipperSpawn: SKNode!
    var points = 0
    var buttonRestart: MSButtonNode!
    var state: GameStateCentrifuge = .Playing
    var Reversed = true
    var cameraSpinner: SKNode!
    var backButton: MSButtonNode!
    var Die = SKAction.playSoundFileNamed("Die3.wav", waitForCompletion: false)
    var Jump = SKAction.playSoundFileNamed("Move5.wav", waitForCompletion: false)
    var ShieldDown = SKAction.playSoundFileNamed("ShieldDown.wav", waitForCompletion: false)
    var Flip = SKAction.playSoundFileNamed("Flip2.wav", waitForCompletion: false)
    var ShieldUp = SKAction.playSoundFileNamed("Powerup.wav", waitForCompletion: false)
    var shieldCount = 0
    var shield: SKSpriteNode!
    let ShieldThere:SKAction = SKAction.init(named: "FadeIn")!
    let ShieldGone:SKAction = SKAction.init(named: "ShieldFade")!
    let savedScore: Int = (NSUserDefaults.standardUserDefaults().objectForKey("HighestScore") ?? 0) as! Int
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        ball = self.childNodeWithName("ball") as! SKSpriteNode
        ring = self.childNodeWithName("//ring") as! SKSpriteNode
        platform = self.childNodeWithName("platform") as! SKSpriteNode!
        obstacleLayer = self.childNodeWithName("//obstacleLayer") as SKNode!
        flipperLayer = self.childNodeWithName("//flipperLayer") as SKNode!
        box = self.childNodeWithName("box") as SKNode!
        spawnPoint = self.childNodeWithName("spawnPoint")
        label = self.childNodeWithName("//label") as! SKLabelNode
        buttonRestart = self.childNodeWithName("//buttonRestart") as! MSButtonNode
        flipperSpawn = self.childNodeWithName("flipperSpawn")
        cameraSpinner = self.childNodeWithName("cameraSpinner")
        backButton = self.childNodeWithName("//backButton") as! MSButtonNode
        shield = self.childNodeWithName("//shield") as! SKSpriteNode
        HSlabel = self.childNodeWithName("//HSlabel") as! SKLabelNode
        HSlabel.text = "Highscore:" + String(savedScore)
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            
        }
        
        
        let colorize = SKAction.repeatActionForever(SKAction.sequence([SKAction.colorizeWithColor(.redColor(), colorBlendFactor: 1, duration: 2),
            SKAction.colorizeWithColor(.blueColor(), colorBlendFactor: 1, duration: 5),
            SKAction.colorizeWithColor(.greenColor(), colorBlendFactor: 1, duration: 5)]))
        
        ring.runAction(colorize)
        ball.physicsBody?.mass = 0.45
        
        self.physicsWorld.contactDelegate = self
        
        /* Setup restart button selection handler */
        buttonRestart.selectedHandler = {
            [unowned self] in
            /* Load Game scene */
            let scene = GameSceneCentrifuge(fileNamed:"GameSceneCentrifuge") 
            
            /* Ensure correct aspect mode */
            scene!.scaleMode = .AspectFill
            
            /* Restart game scene */
            self.view!.presentScene(scene)
        }
        
        /* Setup restart button selection handler */
        backButton.selectedHandler = {
            [unowned self] in
            /* Load Game scene */
            let scene = Intro(fileNamed:"Intro") as Intro!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Restart game scene */
            self.view!.presentScene(scene)
        }
        
        /* Hide restart button */
        buttonRestart.state = .MSButtonNodeStateHidden
        
        
        let RingSpin:SKAction = SKAction.init(named: "RingSpin")!
        cameraSpinner.runAction(RingSpin)
        shield.runAction(ShieldGone)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if ball.position.y <= 370 {
            ball.physicsBody?.applyImpulse(CGVectorMake(0, 250))
            runAction(Jump)
            
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        for reference in obstacleLayer.children {
            let obstacle = reference.children[0].children[0] as! ObstacleBox
            obstacle.color = ring.color
            
        }
        
        
        /* Process obstacles */
        if (state == .Playing) {updateObstacles(); updateFlipper()}
        else if (state == .GameOver) {return}
        
        ball.position.x = 375
        spawnTimer += 1.0/60.0
        flipperTimer += 1.0/60.0
        
        
    }
    
    func updateFlipper() {
        /* Update Flipper */
        
        
        /* Loop through obstacle layer nodes */
        for reference in flipperLayer.children {
            
            let flipper = reference.children[0].children[0] as! FlipperBox
            
            flipper.timer += 1.0/60.0
            
            /* Check if obstacle should leave the scene */
            if (flipper.timer >= 2.1 && flipper.alive == true) {
                
                
                /* Remove obstacle node from obstacle layer */
                flipper.alive = false
                flipper.runAction(SKAction.scaleTo(0, duration: 0.5))
                reference.runAction(SKAction.removeFromParentAfterDelay(0.5))
                
                
            }
            
        }
        
        /* Time to add a new flipper? */
        if flipperTimer >= ((1.9) * 4.7) {
            
            /* Create a new obstacle reference object using our obstacle resource */
            let resourcePath = NSBundle.mainBundle().pathForResource("Flipper", ofType: "sks")
            let newFlipper = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
            flipperLayer.addChild(newFlipper)
            let FlipperGrow:SKAction = SKAction.init(named: "FlipperGrow")!
            newFlipper.runAction(FlipperGrow)
            
            /* Generate new obstacle position at spawn point */
            let randomPosition = CGPointMake(flipperSpawn.position.x, flipperSpawn.position.y)
            
            /* Convert new node position back to obstacle layer space */
            newFlipper.position = self.convertPoint(randomPosition, toNode: flipperLayer)
            print("newFlipper Position: \(newFlipper.position)")
            print("Length to Center: \((newFlipper.position - CGPointMake(0,0)).length())")
            
            // Reset spawn timer
            flipperTimer = Double(CGFloat.random())
        }
        
        
        
    }
    
    
    func updateObstacles() {
        /* Update Obstacles */
        
        
        /* Loop through obstacle layer nodes */
        for reference in obstacleLayer.children {
            
            let obstacle = reference.children[0].children[0] as! ObstacleBox
            
            //Update Timer
            obstacle.timer += 1.0/60.0
            
            /* Check if obstacle should leave the scene */
            if (obstacle.timer >= 1.7 && obstacle.alive == true) {
                
                /* Remove obstacle node from obstacle layer */
                obstacle.alive = false
                obstacle.runAction(SKAction.scaleTo(0, duration: 0.5))
                reference.runAction(SKAction.removeFromParentAfterDelay(0.5))
                
                points += 1
                label.text = String(points)
                
            }
            
        }
        
        /* Time to add a new obstacle? */
        if spawnTimer >= 1.6 {
            
            /* Create a new obstacle reference object using our obstacle resource */
            let resourcePath = NSBundle.mainBundle().pathForResource("Obstacle", ofType: "sks")
            let newObstacle = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
            obstacleLayer.addChild(newObstacle)
            
            //Have obstacle expand onto scene
            let Grow:SKAction = SKAction.init(named: "Grow")!
            newObstacle.runAction(Grow)
            
            /* Generate new obstacle position, start just outside screen and with a random y value */
            let randomPosition = CGPointMake(spawnPoint.position.x, spawnPoint.position.y)
            
            /* Convert new node position back to obstacle layer space */
            newObstacle.position = self.convertPoint(randomPosition, toNode: obstacleLayer)
            
            // Reset spawn timer
            spawnTimer = Double(CGFloat.random())
        }
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if state == .GameOver {
            return
        }
        /* Get references to bodies involved in collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        let nodeA = contactA.node!
        let nodeB = contactB.node!
        
        /* Was this contact between the ball and the obstacle? */
        if (nodeA.name == "ball" && nodeB.name == "obstacleBall" || nodeA.name == "obstacleBall" && nodeB.name == "ball") {
            if shieldCount < 4 {
                state = .GameOver
                gameOver()
            } else if shieldCount >= 4 {
                shieldCount = 0
                shield.runAction(ShieldGone)
                runAction(ShieldDown)
                
            }
            return
        } else if (nodeA.name == "Flipper" && nodeB.name == "ball" || nodeA.name == "ball" && nodeB.name == "Flipper") {
            
            //Add points & shield
            points += 2
            label.text = String(points)
            runAction(Flip)
            //ball.physicsBody?.applyImpulse(CGVectorMake(0, 50))
            shieldCount += 1
            if shieldCount >= 4 {
                shield.runAction(ShieldThere)
                runAction(ShieldUp)
            }
            
            self.childNodeWithName("cameraSpinner")!.removeAllActions()
            Reversed = !Reversed
            
            //Play reversed spin forever
            let ReverseRingSpin:SKAction = SKAction.init(named: "ReverseRingSpin")!
            let RingSpin:SKAction = SKAction.init(named: "RingSpin")!
            
            if Reversed == true {
                cameraSpinner.runAction(ReverseRingSpin)
            } else {
                cameraSpinner.runAction(RingSpin)
            }
            
            let Shrink:SKAction = SKAction.init(named: "Shrink")!
            
            if nodeA.name == "Flipper" {
                nodeA.runAction(Shrink)
            } else if nodeB.name == "Flipper" {
                nodeB.runAction(Shrink)
            }
            
            
        }
        
    }
    
    func gameOver() {
        
        print("You Lose")
        self.childNodeWithName("cameraSpinner")!.removeAllActions()
        runAction(Die)
        
        
        /* Run action */
        //ball.runAction(heroDeath)
        
        ball.physicsBody?.dynamic = false
        
        let FadeOut:SKAction = SKAction.init(named: "FadeOut")!
        ball.runAction(FadeOut)        
        
        /* Show restart button */
        buttonRestart.state = .MSButtonNodeStateActive
        
        
        // To get the saved score
        if (savedScore < points) {
            //To assign new highscore
            let highestScore:Int = points
            NSUserDefaults.standardUserDefaults().setObject(highestScore, forKey:"HighestScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        
    }
    
}
