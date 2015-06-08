//
//  GameStart.swift
//  Flappy
//
//  Created by Moe Wilson on 4/14/15.
//  Copyright (c) 2015 Yuliya Levitskaya. All rights reserved.
//


import SpriteKit
import AVFoundation
class GameScene: SKScene{
    
    var sceneTest:GameStart!
    let myLabel = SKLabelNode(fontNamed:"Chalkduster");
    let myLabel2 = SKLabelNode(fontNamed:"Chalkduster")
    
    override func didMoveToView(view: SKView) {
        myLabel.text = "Flappy";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) + myLabel.frame.size.height);
        self.addChild(myLabel)
        
        myLabel2.text = "Touch To Begin..";
        myLabel2.fontSize = 40;
        myLabel2.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.backgroundColor = UIColor.blackColor()
        self.addChild(myLabel2)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let gameView = self.view as SKView!
            gameView.ignoresSiblingOrder = true;
            sceneTest = GameStart(size: gameView.bounds.size)
            gameView.presentScene(sceneTest)
            sceneTest.scaleMode = .AspectFill
        }
    }
}
