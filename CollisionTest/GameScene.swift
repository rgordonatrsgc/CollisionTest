//
//  GameScene.swift
//  CollisionTest
//
//  Created by Russell Gordon on 12/18/16.
//  Copyright © 2016 Russell Gordon. All rights reserved.
//

import SpriteKit
import GameplayKit

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class GameScene: SKScene {
    
    // MARK: Properties
    let tileCount : CGFloat = 8.0
    var tileSize : Int = 0
    var player = SKSpriteNode()
    var playerSpeed : CGFloat = 1000
    var playerHitWall : Bool = false
    var newHeading : CGFloat = 0
    var priorHeading : CGFloat = 0
    
    override func didMove(to view: SKView) {
        
        // Set background
        backgroundColor = SKColor.black
        
        // Determine tile size
        tileSize = Int(self.size.height / tileCount)
        
        // Draw a brick wall in the middle of the screen
        for i in 1...Int(tileCount) {
            let wall = SKSpriteNode(imageNamed: "brick")
            wall.name = "brick"
            wall.position = CGPoint(x: self.size.width / 2, y: CGFloat(tileSize / 2 + tileSize * i) )
            wall.zPosition = 1
            wall.setScale(6.0)
            addChild(wall)
        }
        
        // Draw the player node
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: self.size.height / 2)
        player.zPosition = 1
        player.setScale(1.0)
        addChild(player)

    }
    
    // This function runs approximately 60 times per second
    override func update(_ currentTime: TimeInterval) {
        
        // See if the player is colliding with the wall
        checkCollisions()
    }
    
    // This responds to a single touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // A touch actually has many points (since a finger is large) so
        // only proceed if we can get the first touch
        guard let touch = touches.first else {
            return
        }
        
        // Get the location of the first touch
        let touchLocation = touch.location(in: self)
        
        // Get the distance between player's current position and the touch location
        let distanceToTouch = distance(from: touchLocation, to: player.position)
        
        // Get the time player should take to arrive at this destination
        let time = TimeInterval(distanceToTouch / playerSpeed)
        
        // Determine the current heading for the player (relative to current position)
        priorHeading = newHeading // Save the prior heading before heading off on new one
        newHeading = heading(from: player.position, to: touchLocation)
        let absoluteHeadingDifference = abs(newHeading - priorHeading)
        print("priorHeading is: \(priorHeading)")
        print("newHeading is: \(newHeading)")
        print("absolute difference between old and new headings \(abs(newHeading - priorHeading))")
        
        // Create the move action
        let actionMove = SKAction.move(to: touchLocation, duration: time)
        
        // Run the move action
        if playerHitWall == true && absoluteHeadingDifference > 90 && absoluteHeadingDifference < 270 {
            playerHitWall = false // Reset the boolean
            player.run(actionMove, withKey: "playerMovingWithGodModeNothingWillStopItMuahaha")
        } else {
            player.run(actionMove, withKey: "playerMoving")
        }
    }
    
    // This determines the distance between two points using the Pythagorean Theorem
    func distance(from : CGPoint, to: CGPoint) -> CGFloat {
        
        return sqrt(pow(from.x - to.x, 2) + pow(from.y - to.y, 2))
    }
    
    // This determines the heading of the player relative to their prior position
    func heading(from currentPosition : CGPoint, to newPosition: CGPoint) -> CGFloat {
        let oppositeLength = newPosition.y - currentPosition.y
        let adjacentLength = newPosition.x - currentPosition.x
        let distanceToTouch = distance(from: currentPosition, to: newPosition)
        let angle = CGFloat(acos(Double(adjacentLength / distanceToTouch)).radiansToDegrees)
        if oppositeLength < 0 {
            return 180 + (180 - angle)
        } else {
            return angle
        }
    }
    
    // This function checks for collisions between the wall and the player
    func checkCollisions() {
        
        // Find all the bricks in the scene that form a wall
        enumerateChildNodes(withName: "brick", using: {
            node, _ in
            
            // Get a reference to the brick
            let brick = node as! SKSpriteNode
            
            // Check to see if this wall segment is touching the player
            if brick.frame.intersects(self.player.frame) {
                
                // A brick is touching the player, so make the player stop
                self.player.removeAction(forKey: "playerMoving")
                
                // Set a boolean to say that the player stopped because of a wall being hit
                // However, don't do this if the player is moving in "god mode"
                if (self.player.action(forKey: "playerMovingWithGodModeNothingWillStopItMuahaha") == nil) {
                    self.playerHitWall = true
                }
                
                
                
            }
            
        })

        
    }
    
    
}
