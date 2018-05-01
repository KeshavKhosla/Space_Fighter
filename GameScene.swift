//
//  GameScene.swift
//  Space Fighter
//
//  Created by Keshav Khosla on 1/5/18.
//  Copyright © 2018 KKhosla. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var score_Label: SKLabelNode!
    var score: Int = 0 {
        didSet {
            score_Label.text = "Score: \(score)"
        }
    }
    
    var gameTimer: Timer!
    
    var possibleAliens = ["Alien_4", "Alien_5"] // add images of alien_1 and alien_2
    
    let alienCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    
    let montion_detector = CMMotionManager()
    
    var xAcc:CGFloat = 0
    
    override func didMove(to view: SKView)
    {
        starfield = SKEmitterNode(fileNamed: "Starfield (2)")
        starfield.position = CGPoint(x:0, y:1500)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "Spaceship_6")
        
        player.position = CGPoint(x: self.frame.width / 30 - 25 , y: player.size.height / 100 - 600)
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        score_Label = SKLabelNode(text: "Score: 0")
        score_Label.position = CGPoint(x: -300, y: 630)
        score_Label.fontName = "AmericanTypewriter-Bold"
        score_Label.fontSize = 36
        score_Label.fontColor = UIColor.white
        score = 0
        
        self.addChild(score_Label)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
    }
    
    @objc func addAlien()
    {
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position - 100, y: self.frame.size.height + alien.size.height)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
    
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
        
        
    }
    
    
    
    func bulletFired() {
        self.run(SKAction.playSoundFileNamed("Torpedo+Explosion.mp3", waitForCompletion: false))
        
        let bulletNode = SKSpriteNode(imageNamed: "bullet")
        bulletNode.position = player.position
        bulletNode.position.y += 5
        
        bulletNode.physicsBody = SKPhysicsBody(circleOfRadius: bulletNode.size.width / 2)
        bulletNode.physicsBody?.isDynamic = true
        
        bulletNode.physicsBody?.categoryBitMask = bulletCategory
        bulletNode.physicsBody?.contactTestBitMask = alienCategory
        bulletNode.physicsBody?.collisionBitMask = 0
        bulletNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bulletNode)
        
        let animationDuration:TimeInterval = 0.3
        
        
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        bulletNode.run(SKAction.sequence(actionArray))
        
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        bulletFired()
    
   
        func begin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
            
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
            
        if (firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0
        {
            bulletCol_success(bulletNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
            
        }
    
        func bulletCol_success (bulletNode:SKSpriteNode, alienNode:SKSpriteNode)
    {
            
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = alienNode.position
        self.addChild(explosion)
            
        self.run(SKAction.playSoundFileNamed("Torpedo+Explosion.mp3", waitForCompletion: false))
            
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
            
            
        self.run(SKAction.wait(forDuration: 1.5))
        {
            explosion.removeFromParent()
        }
            
        score += 5
            
            
    }
        
        func didSimulatePhysics()
    {
            
        player.position.x += xAcc * 50
            
        if player.position.x < -20
        {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }
        else if player.position.x > self.size.width + 20
        {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
            
    }
    
        func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
    }
}
}
