//
//  PlayerNode.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation


import SpriteKit

class PlayerNode: SKSpriteNode {
    
    init(imageNamed: String, width: CGFloat) {
        let texture = SKTexture(imageNamed: imageNamed)
        
        // 1. GÖRSEL BOYUT (Gözün gördüğü)
        // Burası dışarıdan gelen 'width' değerini kullanır (Örn: 120)
        let visualSize = CGSize(width: width, height: width)
        
        super.init(texture: texture, color: .clear, size: visualSize)
        
        // 2. FİZİKSEL BOYUT (Oyunun gördüğü)
        // Burayı görselden tamamen bağımsız, elle yazıyoruz.
        // Görsel 120 olsa bile, buraya 30 yazarsak, hitbox küçücük kalır.
         let hitboxSize = CGSize(width: 40, height: 60) // genişlik önemli değil ama yükseklik önemli. 60 iyi.
        
        // İPUCU: Virüs yuvarlak olduğu için kare yerine "Daire" (Circle) kullanırsak
        // köşelerden çarpma riski daha da azalır.
        // self.physicsBody = SKPhysicsBody(circleOfRadius: 32) // 2xYarıçap  = Genişlik. yuvarlak yapınca altlarından geçebiliyor. dikdörtgen olarak ayarlayacağım.
        
        // Eğer kare kalsın istiyorsan üstteki satırı sil, bunu aç:
        self.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.0
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.player
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground
        self.physicsBody?.contactTestBitMask = PhysicsCategories.obstacle
        
        self.name = "Player"
        self.zPosition = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
