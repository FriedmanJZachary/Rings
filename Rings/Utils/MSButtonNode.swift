//
//  MSButtonNode.swift
//  Make School
//
//  Created by Martin Walsh on 20/02/2016.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import SpriteKit

enum MSButtonNodeState {
    case MSButtonNodeStateActive, MSButtonNodeStateSelected, MSButtonNodeStateHidden
}

class MSButtonNode: SKSpriteNode {
    
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }
    
    /* Button state management */
    var state: MSButtonNodeState = .MSButtonNodeStateActive {
        didSet {
            switch state {
            case .MSButtonNodeStateActive:
                /* Enable touch */
                self.userInteractionEnabled = true
                
                /* Visible */
                self.alpha = 1
                break
            case .MSButtonNodeStateSelected:
                /* Semi transparent */
                self.alpha = 0.7
                break
            case .MSButtonNodeStateHidden:
                /* Disable touch */
                self.userInteractionEnabled = false
                
                /* Hide */
                self.alpha = 0.0
                break
            }
        }
    }
    
    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {
        
        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)
        
        /* Enable touch on button node */
        self.userInteractionEnabled = true
    }
    
    // MARK: - Touch handling
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        state = .MSButtonNodeStateSelected
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        state = .MSButtonNodeStateActive
        selectedHandler()
    }
    
}
