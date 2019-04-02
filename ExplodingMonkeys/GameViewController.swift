//
//  GameViewController.swift
//  ExplodingMonkeys
//
//  Created by Simon Italia on 3/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    //MARK: Interface Object Outlets
    
    //Left Slider
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var angleLabel: UILabel!
    
    //Right Slider
    @IBOutlet weak var velocitySlider: UISlider!
    @IBOutlet weak var velocityLabel: UILabel!
    
    //Launch Button
    @IBOutlet weak var launchButton: UIButton!
    
    //Player Label
    @IBOutlet weak var playerNumber: UILabel!
    
    //Players score UI labels and properties
    @IBOutlet weak var playerOneScoreLabel: UILabel!
    @IBOutlet weak var playerTwoScoreLabel: UILabel!
    
    var playerOneScore = 0 {
        didSet {
            playerOneScoreLabel.text = "Player One Score: \(playerOneScore)"
        }
    }
    
    var playerTwoScore = 0 {
        didSet {
            playerTwoScoreLabel.text = "Player Two Score: \(playerTwoScore)"
        }
    }
    
    //Connect the GameViewController to the GameScene
    var currentGame: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene
                    //Informs the ViewController of the current game/scene (SKScene)
                
                currentGame.viewController = self
                    //Informs the game scene of the GameViewController (UIVC)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: Interface Object Actions
    
    //Left Slider moved
    @IBAction func angleChanged(_ sender: Any) {
        //let angleValue = angleSlider.value
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
        
    }
    
    //Right Slider moved
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
        
    }
    
    //Launch Button tapped
    @IBAction func launchButtonTapped(_ sender: Any) {
        
        //Hide interface controls once Launch button is tapped
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        currentGame.launchBanana(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
        
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<<PLAYER ONE"
            
        } else {
            playerNumber.text = "<<<PLAYER TWO"
        }
        
        //Unhide interface controls for Player
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        
        launchButton.isHidden = false
    }

}
