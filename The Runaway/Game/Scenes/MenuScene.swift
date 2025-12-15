//
//  MenuScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 16.12.2025.
//

import Foundation

import SpriteKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Koordinat merkezi ekranın ortası olsun
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // 1. Arka Plan (GameScene ile aynı)
        let background = SKSpriteNode(imageNamed: "bg_cyber")
        background.size = self.size
        // Görseli ekrana sığdır (Aspect Fill)
        if let texture = background.texture {
            let verticalRatio = self.size.height / texture.size().height
            let horizontalRatio = self.size.width / texture.size().width
            let scaleRatio = max(verticalRatio, horizontalRatio)
            background.setScale(scaleRatio)
        }
        background.position = CGPoint.zero
        background.zPosition = -1
        addChild(background)
        
        // 2. Oyunun Adı (Başlık)
        let titleLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        titleLabel.text = "THE RUNAWAY" // Veya "CYBER BREACH"
        titleLabel.fontSize = 50
        titleLabel.fontColor = .cyan
        titleLabel.position = CGPoint(x: 0, y: self.size.height / 3)
        // Hafif gölge efekti
        let shadow = SKLabelNode(fontNamed: "Orbitron-Bold")
        shadow.text = "THE RUNAWAY"
        shadow.fontSize = 50
        shadow.fontColor = .black
        shadow.alpha = 0.5
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        titleLabel.addChild(shadow)
        
        addChild(titleLabel)
        
        // 3. Hikaye Kutusu (Div)
        createStoryBox()
        
        // 4. Tap to Start Yazısı
        let startLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        startLabel.text = "TAP TO INFILTRATE" // "Sızmak için Dokun"
        startLabel.fontSize = 28
        startLabel.fontColor = .yellow
        startLabel.position = CGPoint(x: 0, y: -self.size.height / 3)
        
        // Yanıp Sönme Animasyonu
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.6),
            SKAction.fadeIn(withDuration: 0.6)
        ])
        startLabel.run(SKAction.repeatForever(blink))
        addChild(startLabel)
    }
    
    func createStoryBox() {
        // Kutu Boyutları
        let boxWidth: CGFloat = 340
        let boxHeight: CGFloat = 220
        let cornerRadius: CGFloat = 15
        
        // Kutuyu oluştur
        let storyBox = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: cornerRadius)
        storyBox.fillColor = UIColor.black.withAlphaComponent(0.8) // %80 siyah cam
        storyBox.strokeColor = .green // Cyberpunk yeşili çerçeve
        storyBox.lineWidth = 2
        storyBox.position = CGPoint(x: 0, y: 0) // Tam orta
        addChild(storyBox)
        
        // Hikaye Metni (SpriteKit'te alt alta yazı için ayrı label'lar kullanmak en temizidir)
        let line1 = SKLabelNode(fontNamed: "Orbitron-Regular")
        line1.text = "CASUS: 734"
        line1.fontSize = 18
        line1.fontColor = .green
        line1.position = CGPoint(x: 0, y: 60)
        storyBox.addChild(line1)
        
        let line2 = SKLabelNode(fontNamed: "AvenirNext-Regular")
        line2.text = "Cyberpunk bir dünyada sistemi"
        line2.fontSize = 16
        line2.fontColor = .white
        line2.position = CGPoint(x: 0, y: 20)
        storyBox.addChild(line2)
        
        let line3 = SKLabelNode(fontNamed: "AvenirNext-Regular")
        line3.text = "çökertmek için görevlendirildin."
        line3.fontSize = 16
        line3.fontColor = .white
        line3.position = CGPoint(x: 0, y: -5)
        storyBox.addChild(line3)
        
        let line4 = SKLabelNode(fontNamed: "AvenirNext-Bold")
        line4.text = "Engelleri aş, dünyayı kurtar!"
        line4.fontSize = 16
        line4.fontColor = .cyan
        line4.position = CGPoint(x: 0, y: -45)
        storyBox.addChild(line4)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Ekrana dokunulduğunda Oyuna (GameScene) geç
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        
        // Havalı bir geçiş efekti (Kapı açılması)
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
