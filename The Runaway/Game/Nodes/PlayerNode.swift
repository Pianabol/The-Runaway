//
//  PlayerNode.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation

import SpriteKit

class PlayerNode: SKShapeNode
{
    
    // Player'ı oluştururken çalışacak fonksiyon
    init(width: CGFloat)
    {
        // 1. Şekil Oluşturma: Bir kare çiziyoruz
        let size = CGSize(width: width, height: width)
        super.init()
        
        // Kare şeklini path olarak tanımla
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -width/2, y: -width/2), size: size), transform: nil)
        
        // 2. Görsel Ayarlar (Neon Teması)
        self.fillColor = .cyan           // İçi camgöbeği (Neon mavisi)
        self.strokeColor = .white        // Kenarları beyaz
        self.lineWidth = 2.0             // Kenar kalınlığı
        self.glowWidth = 5.0             // !Parıldama Efekti! (Neon hissi veren bu)
        
        // 3. Fizik Ayarları (Yerçekimi ve Çarpışma)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true           // Fizik kurallarına uysun mu? Evet.
        self.physicsBody?.allowsRotation = false     // Yuvarlanmasın, dik kalsın.
        self.physicsBody?.friction = 0.0             // Sürtünme yok (Kaymak gibi gitsin)
        self.physicsBody?.restitution = 0.0          // Zıplama yok (Yere yapışsın)
        self.physicsBody?.linearDamping = 0.0        // Hava direnci yok
        
        // 1. Benim kategorim (Kimliğim) ne? -> Player
        self.physicsBody?.categoryBitMask = PhysicsCategories.player
                
        // 2. Kiminle çarpışınca fiziksel tepki vereyim? (Takılayım/İteyim) -> Zemin (Ground)
        // (Engellere fiziksel çarpmasın, içinden geçerken oyun bitsin istiyorsak buraya obstacle yazmayız.
        // Ama "küt" diye çarpması için obstacle da ekleyebilirim. Şimdilik sadece ground kalsın.)
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground
                
        // 3. Kiminle temas edince "Haber Ver"? -> Engel (Obstacle)
        // (Fiziksel çarpışmasa bile dokunduğu an GameScene'e haber uçurur)
        self.physicsBody?.contactTestBitMask = PhysicsCategories.obstacle
        
        // İsimlendirme (Daha sonra kodda bulmak için)
        self.name = "Player"
    }
    
    // Bu kısım zorunlu (Swift'in kuralı)
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
