//
//  GameScene.swift
//  ExplodingMonkeys
//
//  Created by Simon Italia on 3/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import SpriteKit
import GameplayKit

//Set Collision values for objects that interact
enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1 
    
    //Connect our GameScene to the ViewController, albeit weak
    weak var viewController: GameViewController!
    
    var buildings = [BuildingNode]()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.699, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayer()
        
        //Set self as contactDelegate to be notified of node collisions
        physicsWorld.contactDelegate = self
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if let firstNode = firstBody.node {
            if let secondNode = secondBody.node {
                if firstNode.name == "banana"  && secondNode.name == "building" {
                    bananaHit(building: secondNode as! BuildingNode, atPoint: contact.contactPoint)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player1" {
                    destroy(player: player1)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player2" {
                    destroy(player: player2)
                }
            }                
        }
            
    } //End didBegin() method

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //Trigger change player if banana doesn't make contact with any scene node (building or other player)
    override func update(_ currentTime: TimeInterval) {
        if banana != nil {
            if banana.position.y < -1000 {
                banana.removeFromParent()
                banana = nil

                changePlayer()
            }
        }
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            buildings.append(building)
        }
    }
    
    func createPlayer() {
        
        //Create Player 1
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        
        //Apply Player1 physicsBody
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        //Set Player 1 position
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        //Create Player 2
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        
        //Apply Player2 physicsBody
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        //Set Player 2 position
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
        
    }
    
    //Convert degrees to radians
    func degreesToRadians(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    //Launch Banana
    func launchBanana(angle: Int, velocity: Int) {
        
        //Determine throw strength
        let speed = Double(velocity) / 10
        
        //Convert user input (degrees) to radians
        let radians = degreesToRadians(degrees: angle)
        
        //Remove any existing banana from scene
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        //Create a new Banana, add to scene
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
        //If player 1 throwing banana
        if currentPlayer == 1 {
            
            //Set banana to be thrown position and angular velocity (spin)
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            
            banana.physicsBody?.angularVelocity = -20
        
            //Animate player 1 monkey throwing banana
            let raisePlayerArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerPlayerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raisePlayerArm, pause, lowerPlayerArm])
            player1.run(sequence)

            //Move banana in correct direction from player 1
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
           banana.physicsBody?.applyImpulse(impulse)

        //If player 2 throwing banana
        } else {
            
            //Set banana to be thrown position and angular velocity (spin)
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            
            banana.physicsBody?.angularVelocity = 20
            
            //Animate player 2 monkey throwing banana
            let raisePlayerArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerPlayerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raisePlayerArm, pause, lowerPlayerArm])
            player2.run(sequence)
            
            //Move banana in correct direction from player 2
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }

    } //End launchBanana() method
    
    //Destroy part of Building when banana hits building
    func bananaHit(building: BuildingNode, atPoint contactPoint: CGPoint) {
        let buildingLocation = convert(contactPoint, to: building)
        building.hitAt(point: buildingLocation)
        
        //Explode building at banana contact point
        let explosion = SKEmitterNode(fileNamed: "hitBuilding")!
        explosion.position = contactPoint
        addChild(explosion)
        
        //Remove banana from scene
        banana.name = ""
        banana?.removeFromParent()
        banana = nil
        
        //Change Player
        changePlayer()
        
    }
    
    //Destroy Player when banana hits player, and update player score
    func destroy(player: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "hitPlayer")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        banana?.removeFromParent()
        
        //Update player score
        //Player One
        if currentPlayer == 1 {
            viewController.playerOneScore += 1
        
        //Player Two
        } else {
            viewController.playerTwoScore += 1
        }
        
        //End game whenn a player scores 3 points
        if viewController.playerOneScore == 3 || viewController.playerTwoScore == 3 {
            
            //Show won game alert
            var alertMessage: String
            var alertTitle: String
            
            //Player One wins the game
            if currentPlayer == 1 {
                alertTitle = "Player One is the Winner!!"
                alertMessage = "You're a loser Player Two"
            
            //If Player two wins the game
            } else {
                alertTitle = "Player Two is the Winner!!"
                alertMessage = "You're a loser Player One"
            }
            
            //Create alert
            let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Play again?", style: .default, handler: {
                action in self.self.startNewGame()
            }))
            
            //Present  dipslay alert
            self.view?.window?.rootViewController?.present(ac, animated: true)

            
        //Continue Game if no player has scored 3 points
        } else {
            
            //Change players and reset scene
            self.changePlayer()
            
            //Start new game round
            self.startNewRound()
        }
        
    } //End destroy(player: ) method
    
    //Start new round when player is hit by banana
    func startNewRound() {
        //Start new Game
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [unowned self] in
            let newRound = GameScene(size: self.size)
            
            //Update currentGame property to newGame
            newRound.viewController = self.viewController
            self.viewController.currentGame = newRound
            
            self.changePlayer()
            newRound.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newRound, transition: transition)
        }
    }
    
    //Switch players
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
            
        } else {
            currentPlayer = 1
        }
        
        viewController.activatePlayer(number: currentPlayer)
    }
    
    //End Game method to reset game after a player scores 3 points
    @objc func startNewGame() {
        //Start new Game
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [unowned self] in
            let newGame = GameScene(size: self.size)
            
            //Update currentGame property to newGame
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            //Reset player points back to 0
            self.viewController.playerOneScore = 0
            self.viewController.playerTwoScore = 0
            
            let transition = SKTransition.doorway(withDuration: 0.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
}

