//
//  LevelSelect.swift
//  Rings
//
//  Created by Zachary Friedman on 7/21/16.
//  Copyright © 2016 Ellex All rights reserved.
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
    
    var first: CGPoint = CGPointMake(0.0, 0.0)
    let ButtonSound = SKAction.playSoundFileNamed("Button6.wav", waitForCompletion: false)
    let Teleport = SKAction.playSoundFileNamed("Die3.wav", waitForCompletion: false)
    
    var w1: MSButtonNode!
    var w2: MSButtonNode!
    var w3: MSButtonNode!
    var w4: MSButtonNode!
    var backButton: MSButtonNode!
    
    var cam: SKCameraNode!
    var ball: SKSpriteNode!
    var levelUpTo: Int = 1
    let screenWidth = 750
    var counter = 0
    let ballMove: Int = 150
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
        backButton = self.childNodeWithName("//backButton") as! MSButtonNode
        
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
        
        //Calculate last world played on
        var world = Int(lastPlayedLevel / 9)
        if world > 3 {world = 3}
        
        counter = world
        cam.position.x = camPos(world)
        ball.position.x = dotPos(world)
        
        w1.selectedHandler = {
            [unowned self] in
            self.shift(0)
            self.runAction(self.Teleport)
        }
        w2.selectedHandler = {
            [unowned self] in
            self.shift(1)
            self.runAction(self.Teleport)
        }
        w3.selectedHandler = {
            [unowned self] in
            self.shift(2)
            self.runAction(self.Teleport)
        }
        w4.selectedHandler = {
            [unowned self] in
            self.shift(3)
            self.runAction(self.Teleport)
        }
        
        backButton.selectedHandler = {
            [unowned self] in
            /* Load Game scene */
            let scene = Intro(fileNamed: "Intro")

            /* Ensure correct aspect mode */
            scene!.scaleMode = .AspectFill
            
            /* Restart game scene */
            self.view!.presentScene(scene)
            
        }
        
    }
    
    func load(level: Int) {
        /* Load Game scene */
        let scene = GameScene(fileNamed:"GameScene") as GameScene!
        
        scene.currentLevel = level
        
        /* Ensure correct aspect mode */
        scene.scaleMode = .AspectFit
        
        let skView = self.view!
        
        /* Show debug */
        skView.showsPhysics = false
        skView.showsDrawCount = false
        skView.showsFPS = false
        
        /* Start game scene */
        skView.presentScene(scene)
        
        scene.runAction(ButtonSound)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        first = touches.first!.locationInNode(self)
        
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
        
        if (last - first.x) > 20 && counter > 0 {
            

            counter -= 1
            cam.runAction(SKAction.moveToX(camPos(counter), duration: 0.3))
            ball.runAction(SKAction.moveToX(dotPos(counter), duration: 0.3))

            
        } else if (last - first.x) < -20 && counter < 3  {
            

            counter += 1
            cam.runAction(SKAction.moveToX(camPos(counter), duration: 0.3))
            ball.runAction(SKAction.moveToX(dotPos(counter), duration: 0.3))
            
            
        } else {
            for node in self.children {
                if node.name == "lvl" && node.containsPoint(location) && node.containsPoint(first) {
                    let button = node as! LevelButton
                    if button.active {load(button.levelIndex)}
                }
            }
        }
    }
    
}
