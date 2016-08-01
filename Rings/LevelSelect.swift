//
//  LevelSelect.swift
//  Rings
//
//  Created by Zachary Friedman on 7/21/16.
//  Copyright © 2016 Idk Man. All rights reserved.
//

import Foundation
import SpriteKit

class LevelButton: SKSpriteNode {
    var levelIndex: Int = 0
    
    var active: Bool = false {
        didSet {
            if active {
                alpha = 1.0
            }
            else {
                alpha = 0.5
            }
        }
    }
}

class LevelSelect: SKScene {
    
    var first: CGFloat = 0.0
    var cam: SKCameraNode!
    
    var w1: MSButtonNode!
    var w2: MSButtonNode!
    var w3: MSButtonNode!
    var w4: MSButtonNode!
    
    var ball: SKSpriteNode!
    var levelUpTo: Int = 1
    let screenWidth = 750
    var counter = 0
    let ballMove: Int = 150
    var MoveRight: SKAction = SKAction.init(named: "MoveRight")!
    var MoveLeft: SKAction = SKAction.init(named: "MoveLeft")!
    var BallRight: SKAction = SKAction.init(named: "BallRight")!
    var BallLeft: SKAction = SKAction.init(named: "BallLeft")!
    var lastPlayedLevel = -1
    
    func dotPos(world: Int) -> CGFloat {
        return -220 + CGFloat(world) * 150
    }
    
    func camPos(world: Int) -> CGFloat {
        return 375 + CGFloat(world) * 750
    }
    
    func shift(world: Int) {
        ball.removeAllActions()
        cam.removeAllActions()
        ball.runAction(SKAction.moveToX(self.dotPos(world), duration: 0.5))
        cam.runAction(SKAction.moveToX(self.camPos(world), duration: 0.5))
        self.counter = world
    }

    override func didMoveToView(view: SKView) {

        /* Setup your scene here */
        w1 = self.childNodeWithName("//w1") as! MSButtonNode
        w2 = self.childNodeWithName("//w2") as! MSButtonNode
        w3 = self.childNodeWithName("//w3") as! MSButtonNode
        w4 = self.childNodeWithName("//w4") as! MSButtonNode
        
        cam = self.childNodeWithName("cam") as! SKCameraNode
        ball = self.childNodeWithName("//ball") as! SKSpriteNode
        
        levelUpTo = (NSUserDefaults.standardUserDefaults().objectForKey("LevelUpTo") ?? 0) as! Int
        if lastPlayedLevel == -1 {
            lastPlayedLevel = levelUpTo
        }        
        
        for child in self.children {
            if child.name == "lvl" {
                let button = child as! LevelButton
                button.levelIndex = Int(button.zPosition) - 1
                button.active = (button.levelIndex <= levelUpTo)
                button.children[0].userInteractionEnabled = false
            }
        }
        
        let world = Int(lastPlayedLevel / 9)
        counter = world
        cam.position.x = camPos(world)
        ball.position.x = dotPos(world)
        
        w1.selectedHandler = {self.shift(0)}
        w2.selectedHandler = {self.shift(1)}
        w3.selectedHandler = {self.shift(2)}
        w4.selectedHandler = {self.shift(3)}
        
    }
    
    func load(level: Int) {
        
        /* Grab reference to our SpriteKit view */
        let skView = self.view as SKView!
        
        /* Load Game scene */
        let scene = GameScene(fileNamed:"GameScene") as GameScene!
        
        scene.currentLevel = level
        
        /* Ensure correct aspect mode */
        scene.scaleMode = .AspectFit
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* Start game scene */
        skView.presentScene(scene)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        first = touches.first!.locationInNode(self).x
        
        let location = touches.first!.locationInNode(self)
        for node in self.children {
            if node.name == "lvl" && node.containsPoint(location) {
                let button = node as! LevelButton
                if button.active {
                    button.alpha = 0.75
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let location = touches.first!.locationInNode(self)
        let last = location.x
        
        for node in self.children {
            if node.name == "lvl" {
                let button = node as! LevelButton
                if button.active {
                    button.alpha = 1
                }
            }
        }
        
        if (last - first) > 20 && counter > 0 {
            
            //move camera left
            cam.runAction(MoveLeft)
            ball.runAction(BallLeft)
            counter -= 1

            
        } else if (last - first) < -20 && counter < 3  {
            
            //move camera right
            cam.runAction(MoveRight)
            ball.runAction(BallRight)
            counter += 1
            
            
        } else {
            for node in self.children {
                if node.name == "lvl" && node.containsPoint(location) {
                    let button = node as! LevelButton
                    if button.active {
                        load(button.levelIndex)
                    }
                }
            }
        }
    }
    
    
}
