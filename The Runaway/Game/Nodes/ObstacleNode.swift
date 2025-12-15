//
//  ObstacleNode.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation
import SpriteKit

// DİKKAT: Artık SKShapeNode değil, SKSpriteNode kullanıyoruz!
import SpriteKit

class ObstacleNode: SKSpriteNode {
    
    init(imageNamed: String, width: CGFloat, height: CGFloat) {
        let texture = SKTexture(imageNamed: imageNamed)
        let size = CGSize(width: width, height: height) // GÖRSEL BOYUT (Devasa)
        
        super.init(texture: texture, color: .clear, size: size)
        
         
        // Görsel ne kadar büyük olursa olsun, çarpışma kutusunu daraltıyoruz.
        // width * 0.4 -> Görselin genişliğinin sadece %40'ı kadar katı olsun.
        // height * 0.9 -> Boydan da azıcık kısalttım.
        let hitboxSize = CGSize(width: width * 0.2, height: height * 0.8) // 0.4->0.2 , 0.9->0.8
        
        // Fizik gövdesini görsel boyuta (size) göre değil, bu yeni hitboxSize'a göre kuruyoruz
        self.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        
        
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.obstacle
        self.physicsBody?.collisionBitMask = PhysicsCategories.none
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player
        
        self.name = "Obstacle"
        self.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
    
