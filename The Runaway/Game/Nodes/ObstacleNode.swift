//
//  ObstacleNode.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation

import SpriteKit

class ObstacleNode: SKShapeNode
{
    
    // Engel oluştururken genişlik ve yükseklik isteyeceğiz
    init(width: CGFloat, height: CGFloat)
    {
        let size = CGSize(width: width, height: height)
        super.init()
        
        // Dikdörtgen şeklini oluştur
        // (origin noktasını sol-üst köşe yapıyoruz ki yerleştirmesi kolay olsun)
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        
        // Görsel Ayarlar (Neon Mor)
        self.fillColor = .purple
        self.strokeColor = .white
        self.lineWidth = 2.0
        self.glowWidth = 3.0 // Hafif parlasın
        
        // Fizik Ayarları
        self.physicsBody = SKPhysicsBody(rectangleOf: size, center: CGPoint(x: width/2, y: height/2))
        self.physicsBody?.isDynamic = false // DİKKAT: Engel hareket etmez, olduğu yerde çivi gibi durur.
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.categoryBitMask = PhysicsCategories.obstacle
        //son eklediklerim.
        self.physicsBody?.collisionBitMask = PhysicsCategories.none // Engel kimseyle fiziksel itişmesin (Duvar gibi dursun)
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player // Player bana değerse haber ver
        
        self.name = "Obstacle"
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
