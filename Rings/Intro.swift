//
//  Intro.swift
//  Rings
//
//  Created by Zachary Friedman on 8/1/16.
//  Copyright © 2016 Ellex All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class Intro: SKScene {
    
    /* UI Connections */
    var buttonPlay: MSButtonNode!
    var buttonSurvival: MSButtonNode!
    var highScore: SKLabelNode!
    var ring: SKSpriteNode!
    var music: AVAudioPlayer!
    
    override func didMoveToView(view: SKView) {

        /* Set UI connections */
        buttonPlay = self.childNodeWithName("//buttonPlay") as! MSButtonNode
        buttonSurvival = self.childNodeWithName("//buttonSurvival") as! MSButtonNode
        let levelUpTo = (NSUserDefaults.standardUserDefaults().objectForKey("LevelUpTo") ?? 0) as! Int
        let ButtonSound = SKAction.playSoundFileNamed("Button6.wav", waitForCompletion: false)


            do {
                try music = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("IntroPiano", ofType: "mp3")!), fileTypeHint: nil)
            }
            catch {
            }
            
            music.numberOfLoops = -1
            music.play()
        

        
        if levelUpTo >= 36 {
            buttonSurvival.state = .MSButtonNodeStateActive
        } else {
            buttonSurvival.state = .MSButtonNodeStateHidden
        }
        

        
        /* Setup restart button selection handler */
        buttonPlay.selectedHandler = {
            [unowned self] in
            /* Load Game scene */
            let scene = GameScene(fileNamed:"GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            self.music.pause()
            
            let skView = self.view!
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            
            /* Start game scene */
            skView.presentScene(scene)
            
            scene.runAction(ButtonSound)

        }

        buttonSurvival.selectedHandler = {
            [unowned self] in
            
            self.music.pause()
            /* Load Game scene */
            let scene = GameSceneCentrifuge(fileNamed:"GameSceneCentrifuge")
            
            /* Ensure correct aspect mode */
            scene!.scaleMode = .AspectFit
            
            let skView = self.view!
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = false
            skView.showsFPS = false
            
            /* Start game scene */
            skView.presentScene(scene)
            
            scene?.runAction(ButtonSound)
            
            
        }
        
    }
    
}