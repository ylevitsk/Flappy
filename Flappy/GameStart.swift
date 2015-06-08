//
//  GameScene.swift
//  Flappy
//
//  Created by Moe Wilson on 4/7/15.
//  Copyright (c) 2015 Yuliya Levitskaya. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameStart: SKScene, SKPhysicsContactDelegate {
    
    var sceneTest: GameOver!
    var start = true;
    var location:CGPoint!
    var rocket:SKSpriteNode!
    var flame:SKSpriteNode!
    var mySoundURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("rocket", ofType: "wav")!)
    var soundPlayer = AVAudioPlayer();
    var planetTexture:SKTexture!
    var movePlanetsAndRemove:SKAction!
    
    var scoreLabelNode:SKLabelNode!
    var score = NSInteger()
    
    
    let rocketCategory: UInt32 = 1 << 0
    let planetCategory: UInt32 = 1 << 1
    let worldCategory: UInt32 = 1 << 2
    let scoreCategory: UInt32 = 1 << 3
    let flameCategory: UInt32 = 1 << 4
    
    var planetsNode:SKNode!
    var stayPaused = false as Bool
    let pauseLabel = SKLabelNode(fontNamed:"Chalkduster");
    override var paused: Bool {
        get {
            return super.paused
        }
        set {
            if (!stayPaused) {
                super.paused = newValue
            }
            stayPaused = false
        }
    }
    func setStayPaused() {
        self.stayPaused = true
        pauseLabel.text = "Touch to resume"
        pauseLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(pauseLabel)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("setStayPaused"), name: "stayPausedNotification", object: nil)
        
        planetsNode = SKNode()
        self.addChild(planetsNode)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.gravity = CGVectorMake(0.0, -1);
        self.physicsWorld.contactDelegate = self
        self.physicsBody?.categoryBitMask = worldCategory;
        var contactNode = SKNode()
        contactNode.position = CGPointMake( 0, 0)
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake( self.frame.size.width, 10))
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = worldCategory
        contactNode.physicsBody?.contactTestBitMask = rocketCategory
        //self.addChild(contactNode)
        
        
        // setup flame
        let flameTexture1 = SKTexture(imageNamed: "flame")
        flameTexture1.filteringMode = .Nearest
        let flameTexture2 = SKTexture(imageNamed: "flame2")
        flameTexture2.filteringMode = .Nearest
        let flameTexture3 = SKTexture(imageNamed: "flame3")
        flameTexture3.filteringMode = .Nearest
        
        let anim = SKAction.animateWithTextures([flameTexture1, flameTexture2, flameTexture3], timePerFrame: 0.2)
        let flaming = SKAction.repeatActionForever(anim)
        
        flame = SKSpriteNode(texture: flameTexture1)
        flame.runAction(flaming)
        
        //sound
        // Load
        soundPlayer = AVAudioPlayer(contentsOfURL: mySoundURL , error: nil)

        
        //sky
        let skyTexture = SKTexture(imageNamed: "sky")
        skyTexture.filteringMode = .Nearest
        
        let moveSkySprite = SKAction.moveByX(-skyTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.1 * skyTexture.size().width * 2.0))
        let resetSkySprite = SKAction.moveByX(skyTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveSkySpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite,resetSkySprite]))
        
        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( skyTexture.size().width*2); ++i {
            let sky = SKSpriteNode(texture: skyTexture)
            sky.setScale(1)
            sky.zPosition = -20
            sky.position = CGPointMake(i * sky.size.width, sky.size.height/2)
            sky.runAction(moveSkySpritesForever)
            self.addChild(sky)
        }
        //setup rocket
        setup()
        
        
        //planets
        // create the planet textures
        planetTexture = SKTexture(imageNamed: "planet")
        planetTexture.filteringMode = .Nearest
        
        // create the pipes movement action
        let distanceToMove = CGFloat(self.frame.size.width + 3.0 * planetTexture.size().width)
        let movePlanet = SKAction.moveByX(-distanceToMove, y:0.0, duration:NSTimeInterval(0.01 * distanceToMove))
        let removePlanet = SKAction.removeFromParent()
        movePlanetsAndRemove = SKAction.sequence([movePlanet, removePlanet])
        
        //setup score
        // Initialize label and create a label which holds the score
        scoreLabelNode = SKLabelNode(fontNamed:"MarkerFelt-Wide")
        scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), 5 * self.frame.size.height / 6 )
        scoreLabelNode.zPosition = 100
        score = 0
        scoreLabelNode.text = String(score)
        self.addChild(scoreLabelNode)
        
    }
    
    func setup(){
        // rocket object properties
        rocket = SKSpriteNode(imageNamed:"Spaceship")
        rocket.physicsBody = SKPhysicsBody(circleOfRadius: rocket.frame.size.height/2)
        rocket.physicsBody?.velocity = CGVectorMake( 0, 0 )
        rocket.physicsBody!.dynamic = true
        rocket.physicsBody?.allowsRotation = false
        rocket.xScale = 0.25
        rocket.yScale = 0.25
        rocket.position = CGPointMake(size.width/2, size.height/2 + 20)
        
        rocket.physicsBody?.categoryBitMask = rocketCategory
        rocket.physicsBody?.collisionBitMask = worldCategory | planetCategory
        rocket.physicsBody?.contactTestBitMask = worldCategory | planetCategory
        
        
        // flame object properties
        flame.physicsBody = SKPhysicsBody(circleOfRadius: flame.frame.size.height/2)
        flame.physicsBody?.velocity = CGVectorMake( 0, 0 )
        flame.physicsBody!.dynamic = true
        flame.physicsBody?.allowsRotation = false
        flame.setScale(0.5)
        flame.position = CGPointMake(size.width/2 - 1.23 * rocket.size.width, size.height/2)
        flame.anchorPoint = CGPointMake(0, 0)
        
        flame.physicsBody?.categoryBitMask = flameCategory
        flame.physicsBody?.collisionBitMask = worldCategory | planetCategory
        flame.physicsBody?.contactTestBitMask = worldCategory | planetCategory
        
        self.addChild(rocket)
        self.addChild(flame)
        var myJoint = SKPhysicsJointPin.jointWithBodyA(flame.physicsBody, bodyB: rocket.physicsBody, anchor: CGPoint(x:CGRectGetMidX(self.flame.frame) , y: CGRectGetMidY(self.rocket.frame)))
        self.physicsWorld.addJoint(myJoint)
        
        // spawn the pipes
        let spawn = SKAction.runBlock({() in self.spawnPlanets()})
        let delay = SKAction.waitForDuration(NSTimeInterval(4.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        
    }
    func spawnPlanets() {
        let h = self.frame.size.height
        let height = UInt32( UInt(self.frame.size.height))
        let y = arc4random() % (height)
        
        let planets = SKNode()
        planets.position = CGPointMake(self.frame.size.width + planetTexture.size().width/2, 0 )
        planets.zPosition = -10
        
        let planet = SKSpriteNode(texture: planetTexture)
        let size = CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(0.02 - 0.2) + min(0.02, 0.2)
        planet.setScale(size);
        planet.position = CGPointMake(0.0, CGFloat(Double(y)))
        planet.physicsBody = SKPhysicsBody(circleOfRadius: planet.frame.size.height/2)
        planet.physicsBody?.dynamic = false
        planet.physicsBody?.categoryBitMask = planetCategory
        planet.physicsBody?.contactTestBitMask = rocketCategory
        planets.addChild(planet)
        
        var contactNode = SKNode()
        let t = planet.size.width + rocket.size.width/2
        contactNode.position = CGPointMake( planet.size.width + rocket.size.width*3/4, CGRectGetMidY( self.frame))
        contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake( planet.size.width, self.frame.size.height ))
        contactNode.physicsBody?.dynamic = false
        contactNode.physicsBody?.categoryBitMask = scoreCategory
        contactNode.physicsBody?.contactTestBitMask = rocketCategory
        planets.addChild(contactNode)
        planets.runAction(movePlanetsAndRemove)
        
        planetsNode.addChild(planets)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        self.paused = false;
        pauseLabel.removeFromParent()
        for touch: AnyObject in touches {
            rocket.physicsBody?.velocity = CGVectorMake(0, 0)
            rocket.physicsBody?.applyImpulse(CGVectorMake(0, 500))
            // Play sound
            soundPlayer.play();
        }
    }
    // TODO: Move to utilities somewhere. There's no reason this should be a member function
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        rocket.zRotation = self.clamp( -1, max: 0.5, value: rocket.physicsBody!.velocity.dy * ( rocket.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) )
        flame.zRotation = self.clamp( -1, max: 0.5, value: rocket.physicsBody!.velocity.dy * ( rocket.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) )
        
    }
    func didBeginContact(contact: SKPhysicsContact) {
        let t = contact.bodyA.categoryBitMask
        let s = contact.bodyB.categoryBitMask
        if (contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
            // Increment score
            score++
            scoreLabelNode.text = String(score)
        }
        else if (contact.bodyA.categoryBitMask & worldCategory ) == worldCategory || ( contact.bodyB.categoryBitMask & worldCategory ) == worldCategory || (contact.bodyA.categoryBitMask & flameCategory ) == flameCategory || ( contact.bodyB.categoryBitMask & flameCategory ) == flameCategory{
        }
        else{
            var firstScore = NSInteger()
            var secondScore = NSInteger()
            var thirdScore = NSInteger()
            var fourthScore = NSInteger()
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            let documentsDirectory = paths.objectAtIndex(0) as NSString
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
            if let dict = myDict  {
                if(c>1){
                  //loading values
                  firstScore = dict.objectForKey("first") as Int
                  secondScore = dict.objectForKey("second") as Int
                  thirdScore = dict.objectForKey("third") as Int
                  fourthScore = dict.objectForKey("fourth") as Int
                }
                
            } else {
                println("WARNING: Couldn't create dictionary from GameData.plist! Default values will be used!")
            }
            if score > fourthScore{
                var dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
                //saving values
                if(score == firstScore || score == secondScore || score == thirdScore || score == fourthScore){
                    dict.setObject(fourthScore as AnyObject, forKey: "fourth")
                    dict.setObject(thirdScore as AnyObject, forKey: "third")
                    dict.setObject(secondScore as AnyObject, forKey: "second")
                    dict.setObject(firstScore as AnyObject, forKey: "first")
                }
                else if(score > firstScore){
                    dict.setObject(thirdScore as AnyObject, forKey: "fourth")
                    dict.setObject(secondScore as AnyObject, forKey: "third")
                    dict.setObject(firstScore as AnyObject, forKey: "second")
                    dict.setObject(score as AnyObject, forKey: "first")
                }
                else if(score > secondScore){
                    dict.setObject(thirdScore as AnyObject, forKey: "fourth")
                    dict.setObject(secondScore as AnyObject, forKey: "third")
                    dict.setObject(score as AnyObject, forKey: "second")
                    dict.setObject(firstScore as AnyObject, forKey: "first")
                }
                else if(score > thirdScore){
                    dict.setObject(thirdScore as AnyObject, forKey: "fourth")
                    dict.setObject(score as AnyObject, forKey: "third")
                    dict.setObject(secondScore as AnyObject, forKey: "second")
                    dict.setObject(firstScore as AnyObject, forKey: "first")
                }
                else{
                    dict.setObject(score as AnyObject, forKey: "fourth")
                    dict.setObject(thirdScore as AnyObject, forKey: "third")
                    dict.setObject(secondScore as AnyObject, forKey: "second")
                    dict.setObject(firstScore as AnyObject, forKey: "first")
                }
                //...
            
                //writing to GameData.plist
                dict.writeToFile(path, atomically: false)
            
                let resultDictionary = NSMutableDictionary(contentsOfFile: path)
                println("Saved GameData.plist file is --> \(resultDictionary?.description)")
            }
            let gameView = self.view as SKView!
            gameView.ignoresSiblingOrder = true;
            sceneTest = GameOver(size: gameView.bounds.size)
            gameView.presentScene(sceneTest)
            sceneTest.scaleMode = .AspectFill
        }
    }
}
