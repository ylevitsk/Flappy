//
//  GameOver.swift
//  Flappy
//
//  Created by Moe Wilson on 4/14/15.
//  Copyright (c) 2015 Yuliya Levitskaya. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameOver: SKScene{
    var sceneTest:GameStart!
    var gameOver = SKNode();
    var highScoreLabelNode:SKLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
    var firstScoreLabelNode:SKLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
    var secondScoreLabelNode:SKLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
    var thirdScoreLabelNode:SKLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
    var fourthScoreLabelNode:SKLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")

    var highScore = NSInteger();
    
    override func didMoveToView(view: SKView) {
        //setup high score
        // Initialize label and create a label which holds the score
        highScoreLabelNode.position = CGPointMake(CGRectGetMidX( gameOver.frame ), CGRectGetMidY(gameOver.frame))
        highScoreLabelNode.zPosition = 100
        highScoreLabelNode.text = "High Scores: ";
        
        firstScoreLabelNode.text = String(highScore)
        secondScoreLabelNode.text = String(highScore)
        thirdScoreLabelNode.text = String(highScore)
        fourthScoreLabelNode.text = String(highScore)
        firstScoreLabelNode.position = CGPointMake(CGRectGetMidX( gameOver.frame ), CGRectGetMidY(gameOver.frame) - highScoreLabelNode.frame.size.height)
        firstScoreLabelNode.zPosition = 100
        secondScoreLabelNode.position = CGPointMake(CGRectGetMidX( gameOver.frame ), CGRectGetMidY(gameOver.frame) - highScoreLabelNode.frame.size.height - firstScoreLabelNode.frame.size.height)
        secondScoreLabelNode.zPosition = 100
        thirdScoreLabelNode.position = CGPointMake(CGRectGetMidX( gameOver.frame ), CGRectGetMidY(gameOver.frame) - highScoreLabelNode.frame.size.height - firstScoreLabelNode.frame.size.height - secondScoreLabelNode.frame.size.height)
        thirdScoreLabelNode.zPosition = 100
        fourthScoreLabelNode.position = CGPointMake(CGRectGetMidX( gameOver.frame ), CGRectGetMidY(gameOver.frame) - highScoreLabelNode.frame.size.height - firstScoreLabelNode.frame.size.height - secondScoreLabelNode.frame.size.height - thirdScoreLabelNode.frame.size.height)
        fourthScoreLabelNode.zPosition = 100
        

         loadData()
        
        let myLabel =  SKLabelNode(fontNamed:"Chalkduster");
        myLabel.fontSize = 50;
        myLabel.text = "Game Over"
        myLabel.position = CGPoint(x:CGRectGetMidX(gameOver.frame), y:CGRectGetMidY(gameOver.frame) + myLabel.frame.size.height);

        
        var myLabel2 = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        myLabel2.text = "Touch To Restart..";
        myLabel2.fontSize = 30;
        myLabel2.position = CGPoint(x:CGRectGetMidX(gameOver.frame), y:CGRectGetMidY(gameOver.frame) - highScoreLabelNode.frame.size.height * 2 - firstScoreLabelNode.frame.size.height - secondScoreLabelNode.frame.size.height - thirdScoreLabelNode.frame.size.height);
        
        gameOver.addChild(myLabel2)
        gameOver.addChild(myLabel)
        gameOver.addChild(highScoreLabelNode)
        gameOver.addChild(firstScoreLabelNode)
        gameOver.addChild(secondScoreLabelNode)
        gameOver.addChild(thirdScoreLabelNode)
        gameOver.addChild(fourthScoreLabelNode)
        gameOver.position = CGPointMake(CGRectGetMidX( self.frame ), CGRectGetMidY(self.frame))
        
        
        self.addChild(gameOver)
        

    }
    func loadData(){
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as String
        let path = documentsDirectory.stringByAppendingPathComponent("GameData.plist")
        
        let fileManager = NSFileManager.defaultManager()
        
        //check if file exists
        if(!fileManager.fileExistsAtPath(path)) {
            // If it doesn't, copy it from the default file in the Bundle
            if let bundlePath = NSBundle.mainBundle().pathForResource("GameData", ofType: "plist") {
                
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                println("Bundle GameData.plist file is --> \(resultDictionary?.description)")
                
                fileManager.copyItemAtPath(bundlePath, toPath: path, error: nil)
                println("copy")
            } else {
                println("GameData.plist not found. Please, make sure it is part of the bundle.")
            }
        } else {
            println("GameData.plist already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path)
        println("Loaded GameData.plist file is --> \(resultDictionary?.description)")
        
        var myDict = NSDictionary(contentsOfFile: path)
        let c = myDict?.count;
        if let dict = myDict {
            //loading values
            if(c>1){
               firstScoreLabelNode.text = String(dict.objectForKey("first") as Int)
               secondScoreLabelNode.text = String(dict.objectForKey("second") as Int)
               thirdScoreLabelNode.text = String(dict.objectForKey("third") as Int)
               fourthScoreLabelNode.text = String(dict.objectForKey("fourth") as Int)
            }
            //...
        } else {
            println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
        }
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
