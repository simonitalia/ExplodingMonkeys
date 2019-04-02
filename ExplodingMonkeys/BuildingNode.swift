//
//  BuildingNode.swift
//  ExplodingMonkeys
//
//  Created by Simon Italia on 3/23/19.
//  Copyright © 2019 SDI Group Inc. All rights reserved.
//

import UIKit
import SpriteKit

class BuildingNode: SKSpriteNode {
    
    var currentImage: UIImage!
    
    //Create building
    func setup() {
        name = "building"
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        configurePhysics()
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        
        //Create new CoreGraphics context the size of building
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            
            //Fill building with rectangle with 1 of 3 colors
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            var color: UIColor
            
            switch Int.random(in: 0...2) {
                case 0:
                    color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
                
                case 1:
                    color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
                
                default:
                    color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            } //End switch
            
            ctx.cgContext.setFillColor(color.cgColor)
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
        
            //Draw windows on building in 1 of 2 colors (yellow or gray)
            let lightOnColor = UIColor(hue: 0.190, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    
                    if Bool.random() {
                        ctx.cgContext.setFillColor(lightOnColor.cgColor)
                    
                    } else {
                        ctx.cgContext.setFillColor(lightOffColor.cgColor)
                        
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        
        //Return result as a UIImage
        return img
    
    }//End drawBuilding() method
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    
    }
    
    //Destroy part of building at point hit by banana
    func hitAt(point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2.0, y: abs(point.y - (size.height / 2.0)))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            currentImage.draw(at: CGPoint(x: 0, y: 0))
            
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        
        configurePhysics()
    }
    

}
