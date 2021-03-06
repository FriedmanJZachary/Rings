//
//  SurvivalMode.swift
//  Rings
//
//  Created by Zachary Friedman on 8/2/16.
//  Copyright © 2016 Idk Man. All rights reserved.
//

import Foundation
import SpriteKit


class SurvivalMode: SKScene, SKPhysicsContactDelegate {
    
    var ball: SKSpriteNode!
    var backButton: MSButtonNode!
    var restartButton: MSButtonNode!
    var lastBase: SKNode?
    var forceConst = CGFloat(1500.0)
    var timer = 3.0
    var obstacleTimer = 0.0
    var camConst: CGFloat = 3
    var canJump = true
    
    var game: GameState = .Play
    var cam: SKNode!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        ball = self.childNodeWithName("ball") as! SKSpriteNode
        cam = self.childNodeWithName("cam") as SKNode!
        backButton = self.childNodeWithName("//backButton") as! MSButtonNode

        //Set up physics/background world
        self.view?.showsPhysics = false
        physicsWorld.contactDelegate = self
        self.scene?.backgroundColor = UIColor(red: 16/255, green: 25/255, blue: 41/255, alpha: 1)

        backButton.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = LevelSelect(fileNamed: "LevelSelect")
            
            /* Ensure correct aspect mode */
            scene!.scaleMode = .AspectFill
            
            /* Restart game scene */
            skView.presentScene(scene)
            
        }
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            
            if game == .GameOver {return}
            if canJump == false {return}
            
            let location = touch.locationInNode(self)
            
            let absolutePos = ball.convertPoint(CGPoint(x: 0.0, y: 0.0), toNode: self)
            
            
//                for child in Obstacle!.children {
//                    if child.name == "touchless" {
//                        let sprite = child as! SKSpriteNode
//                        
//                        let ballPosRelativeToSprite = self.convertPoint(absolutePos, toNode:sprite)
//                        
//                        let scaledSize = CGSize(width: sprite.size.width / sprite.xScale, height: sprite.size.height / sprite.yScale)
//                        
//                        let frameMin = CGPoint(x: scaledSize.width, y: scaledSize.height) * sprite.anchorPoint * CGVectorMake(-1, -1)
//                        let frame = CGRect(origin: frameMin, size: scaledSize)
//                        
//                        if frame.contains(ballPosRelativeToSprite) { return }
//                    }
//                }
            
            
            //Move ball by constant in direction of tap
            
            if ball.parent != self {
                timer = 0.0
            }
            
            ball.removeAllActions()
            ball.removeFromParent()
            self.addChild(ball)
            ball.position = absolutePos
            
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.categoryBitMask = 4
            ball.physicsBody?.collisionBitMask = 2
            ball.physicsBody?.contactTestBitMask = 0xffffffff
            ball.physicsBody?.restitution = 0.85
            
            let x = location.x - ball.position.x
            let y = location.y - ball.position.y
            let vector = sqrt(x*x + y*y)
            
            let xNorm = x/vector * forceConst
            let yNorm = y/vector * forceConst
            
            ball.physicsBody?.velocity = CGVector(dx: xNorm, dy: yNorm)
            
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        cam.position.y += camConst
        timer += 1.0/60.0
        updateObstacles()
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        /* Ensure only called while game running */
        if game != .Play { return }
        
        
        /* Get references to bodies involved in collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent nodes */
        if let nodeA = contactA.node, nodeB = contactB.node {
            
            
            /* Did our hero pass through the 'goal'? */
            if (nodeA.name == "ball" && nodeB.name == "base") {
                
                if (timer < 0.25 && nodeB == lastBase){
                    return
                }
                
                timer = 0
                lastBase = nodeB
                canJump = true
                
                ball.physicsBody?.contactTestBitMask = 0
                ball.physicsBody = nil
                ball.position = self.convertPoint(ball.position, toNode: nodeB)
                ball.removeFromParent()
                nodeB.addChild(ball)
                let action = SKAction.moveTo(CGPoint(x: 0.0, y: 0.0), duration: 0.25)
                action.timingMode = .EaseOut
                ball.removeAllActions()
                ball.runAction(action)
                
            } else if (nodeA.name == "base" && nodeB.name == "ball") {
                
                if (timer < 0.25 && nodeA == lastBase){return}
                
                timer = 0
                lastBase = nodeA
                canJump = true
                
                ball.physicsBody?.contactTestBitMask = 0
                ball.physicsBody = nil
                ball.position = self.convertPoint(ball.position, toNode: nodeA)
                ball.removeFromParent()
                nodeA.addChild(ball)
                let action = SKAction.moveTo(CGPoint(x: 0.0, y: 0.0), duration: 0.25)
                action.timingMode = .EaseOut
                ball.removeAllActions()
                ball.runAction(action)
                
                
            } else if (nodeA.name == "ball" && nodeB.name == "ring") || (nodeA.name == "ring" && nodeB.name == "ball") {
                
                gameOver()
                
            } else if (nodeA.name! == "ball" && nodeB.name!.containsString("Portal")) {
                ball.removeAllActions()
                
                ball.physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)
                ball.runAction(SKAction.sequence([SKAction.moveTo(nodeB.convertPoint(CGPoint(x: 0.0, y: 0.0),toNode: self), duration: 0.5), SKAction.runBlock({
                    let portalChild = nodeB.children[0]
                    let destination = portalChild.convertPoint(CGPoint(x: 0.0, y: 0.0),toNode: self)
                    self.ball.runAction(SKAction.moveTo(destination, duration: 0))
                })
                    ]))
                
                
                
            } else if (nodeA.name!.containsString("Portal") && nodeB.name == "ball") {
                ball.removeAllActions()
                
                ball.physicsBody!.velocity = CGVector(dx: 0.0, dy: 0.0)
                ball.runAction(SKAction.sequence([SKAction.moveTo(nodeA.convertPoint(CGPoint(x: 0.0, y: 0.0),toNode: self), duration: 0.5), SKAction.runBlock({
                    let portalChild = nodeA.children[0]
                    let destination = portalChild.convertPoint(CGPoint(x: 0.0, y: 0.0),toNode: self)
                    self.ball.runAction(SKAction.moveTo(destination, duration: 0))
                })
                    ]))
                
                
            }
        }
    }
    
    func gameOver() {
        
        game = .GameOver
        ball.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        ball.physicsBody?.dynamic = false
        ball.removeAllActions()
        ball.runAction(SKAction.sequence([SKAction.runBlock({self.ball.removeAllChildren()}), SKAction.scaleBy(0, duration: 0.5), SKAction.runBlock({
            self.reloadLevel()
        })]))
        
    }
    
    
    func reloadLevel() {
        
        /* Grab reference to our SpriteKit view */
        let skView = self.view as SKView!
        
        /* Load Game scene */
        let scene = SurvivalMode(fileNamed: "SurvivalMode")
        
        /* Ensure correct aspect mode */
        scene!.scaleMode = .AspectFill
        
        /* Restart game scene */
        skView.presentScene(scene)
        
    }
    
    
    func updateObstacles() {
        
        obstacleTimer += 1.0/60.0
        
        if (obstacleTimer > 2.5) {
            
            let resourcePath = NSBundle.mainBundle().pathForResource("Obstacle1", ofType: "sks")
            let Obstacle = SKReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
            let pointY = CGPoint(x: 0, y: 1000)
            let ySet = cam.convertPoint(pointY, toNode: self)
            let xRand = CGFloat(arc4random_uniform(UInt32(150))) 
            Obstacle.position = CGPoint(x: xRand, y: ySet.y)
            addChild(Obstacle)
            obstacleTimer = 0.0
            
        
        }
        

        
        
        
        
    }
    

    
}