//
//  GameScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

// bu versiyona, game over eklendi, ve çalışırsa eğer restart modu geldi. hadi bakalım.
// bu versiyona skor eklendi, yüksek skor kayıt ediliyor. Yeni rekor, yeni yüksek rekor ve kayıtlı.
// arka plan ve engellere görsel eklendi, ayrıca karakterimiz için bir icon getirildi.

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: PlayerNode?
    var scoreLabel: SKLabelNode!
    var background: SKSpriteNode! // Arka planı tutacak değişken
    
    var isGameOver = false
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var lastUpdateTime: TimeInterval = 0
    var obstacleSpawnRate: TimeInterval = 1.5
    var timeSinceLastSpawn: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Siyah arka plan satırını sildik!
        
        createBackground() // YENİ: Arka plan görselini ekle
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -12.0)
        
        createWalls()
        addPlayer()
        setupScoreLabel()
    }
    
    func createBackground() {
        // YENİ FONKSİYON: Arka plan görselini yükle
        background = SKSpriteNode(imageNamed: "bg_cyber")
        // Görselin sahneyi tamamen kaplamasını sağla (Aspect Fill gibi)
        background.size = self.size
        background.aspectFillToSize(fillSize: self.size)
        background.position = CGPoint.zero // Tam ortaya koy
        background.zPosition = -10 // Her şeyin en arkasında dursun
        addChild(background)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .white.withAlphaComponent(0.8) // Biraz daha belirgin yaptım
        scoreLabel.position = CGPoint(x: 0, y: self.size.height / 2 - 160) // Çentik altı
        scoreLabel.zPosition = 5
        addChild(scoreLabel)
    }
    
    func createWalls() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = PhysicsCategories.ground
    }
    
    func addPlayer()
    {
            // Virüsün genişliğini 100 yaptık, artık kocaman ve net görünecek
            player = PlayerNode(imageNamed: "virus_player", width: 150)
            
            // Konumunu biraz daha yukarı alalım (y: -100) ki zemine tam otursun
            player?.position = CGPoint(x: -self.size.width / 3, y: -100)
            
            if let playerNode = player {
                addChild(playerNode)
            }
        }
    func spawnObstacle() {
        if isGameOver { return }
        
        // --- DEĞİŞİKLİK BURADA: RASTGELE BOYUTLAR ---
        // Genişlik: 150 ile 220 arasında değişsin (Bazen ince, bazen kalın)
        let obstacleWidth = CGFloat.random(in: 220...270)   //200 ile başladık 220-270 oldu bakalım.
        
        // Yükseklik: 200 (Kısa) ile 450 (Çok Uzun) arasında değişsin.
        // Eğer 450 gelirse ekranın yarısını geçer, seni mecburen diğer tarafa iter.
        let obstacleHeight = CGFloat.random(in: 380...670) //250->380 bakalım.
        
        // Artık sabit sayıları değil, yukarıdaki random sayıları kullanıyoruz
        let obstacle = ObstacleNode(imageNamed: "obstacle_crystal", width: obstacleWidth, height: obstacleHeight)
        
        // Sağ taraftan başlasın
        let startX = self.size.width / 2 + obstacleWidth
        
        // --- MATEMATİKSEL SABİTLEME (Aynen Korundu) ---
        let isTop = Bool.random()
        let yPos: CGFloat
        
        if isTop {
            // TAVAN: Hesaplamayı yeni 'obstacleHeight'a göre yapıyoruz
            yPos = self.size.height / 2 - obstacleHeight / 2
            
            // Kristalin ucunun aşağı bakması için ters çevir
            obstacle.zRotation = .pi
        } else {
            // ZEMİN: Hesaplamayı yeni 'obstacleHeight'a göre yapıyoruz
            yPos = -self.size.height / 2 + obstacleHeight / 2
        }
        
        obstacle.position = CGPoint(x: startX, y: yPos)
        addChild(obstacle)
        
        // Hız sabiti (İstersen burayı da random yapabilirsin ama şimdilik kalsın)
        let moveLeft = SKAction.moveBy(x: -(self.size.width + obstacleWidth * 2), y: 0, duration: 3.5)
        
        let scoreAction = SKAction.run {
            if !self.isGameOver { self.score += 1 }
        }
        
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveLeft, scoreAction, remove]))
    }
    
   /*
    eski engel yaratma func, silme bi şimdilik dursun fail olma ihtimaline karşı.
    func spawnObstacle() {
            if isGameOver { return }
            
            // Görseli büyük tutuyoruz
            let obstacleWidth: CGFloat = 200
            let obstacleHeight: CGFloat = 360 // Biraz daha uzattım ki ekranı iyice kaplasın
            
            let obstacle = ObstacleNode(imageNamed: "obstacle_crystal", width: obstacleWidth, height: obstacleHeight)
            
            // Sağ taraftan başlasın
            let startX = self.size.width / 2 + obstacleWidth
            
            // --- MATEMATİKSEL SABİTLEME ---
            let isTop = Bool.random()
            let yPos: CGFloat
            
            if isTop {
                // TAVAN: Ekranın Üst Sınırı - Engelin Yarısı
                // Böylece engelin üst kenarı, ekranın üst kenarına tam öpüşür.
                yPos = self.size.height / 2 - obstacleHeight / 2
                
                // Kristalin ucunun aşağı bakması için ters çevirebiliriz (Opsiyonel ama havalı durur)
                obstacle.zRotation = .pi
            } else {
                // ZEMİN: Ekranın Alt Sınırı + Engelin Yarısı
                // Böylece engelin alt kenarı, ekranın alt kenarına tam öpüşür.
                yPos = -self.size.height / 2 + obstacleHeight / 2
            }
            
            obstacle.position = CGPoint(x: startX, y: yPos)
            addChild(obstacle)
            
            let moveLeft = SKAction.moveBy(x: -(self.size.width + obstacleWidth * 2), y: 0, duration: 3.5)
            
            let scoreAction = SKAction.run {
                if !self.isGameOver { self.score += 1 }
            }
            
            let remove = SKAction.removeFromParent()
            obstacle.run(SKAction.sequence([moveLeft, scoreAction, remove]))
        }
    */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }
        
        // YENİ: Arka Plan Parlaklık Efekti!
        // Arka planı anlık olarak beyaza boyayıp (parlatıp) geri eski haline döndürür.
        let flashUp = SKAction.colorize(with: .white, colorBlendFactor: 0.3, duration: 0.05)
        let flashDown = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.05)
        background.run(SKAction.sequence([flashUp, flashDown]))
        
        physicsWorld.gravity.dy *= -1
        player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: physicsWorld.gravity.dy * 2))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == (PhysicsCategories.player | PhysicsCategories.obstacle) {
            triggerGameOver()
        }
    }
    
    func triggerGameOver() {
            if isGameOver { return }
            
            isGameOver = true
            
            // 1. Oyuncuyu Öldür (Efektler)
            player?.color = .red
            player?.colorBlendFactor = 0.8
            player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // Dondur
            
            // Engelleri durdur
            self.enumerateChildNodes(withName: "Obstacle") { node, _ in
                node.removeAllActions()
            }
            
            // --- YENİ "DIV" TASARIMI BAŞLIYOR ---
            
            // 2. Kutu (Div) Oluşturma
            let boxWidth: CGFloat = 320
            let boxHeight: CGFloat = 260
            let cornerRadius: CGFloat = 20
            
            // Dikdörtgen şekli (Rounded Rect)
            let gameOverBox = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: cornerRadius)
            
            // Tasarım Özellikleri (CSS gibi düşün)
            gameOverBox.fillColor = UIColor.black.withAlphaComponent(0.85) // %85 Koyu Siyah Arka Plan
            gameOverBox.strokeColor = .black // Çerçeve rengi
            gameOverBox.lineWidth = 2 // Çerçeve kalınlığı
            gameOverBox.position = CGPoint(x: 0, y: 0) // Ekranın tam ortası
            gameOverBox.zPosition = 50 // Her şeyin üstünde (z-index)
            
            // Kutuyu sahneye ekle
            addChild(gameOverBox)
            
            // Hafif bir "Pop-up" animasyonu (Büyüyerek gelsin)
            gameOverBox.setScale(0)
            gameOverBox.run(SKAction.scale(to: 1.0, duration: 0.3))
            
            // 3. Başlık: SYSTEM FAILURE (Kutunun içine ekliyoruz)
            let titleLabel = SKLabelNode(fontNamed: "Orbitron-Bold") // Yoksa "AvenirNext-Bold"
            titleLabel.text = "SYSTEM FAILURE"
            titleLabel.fontSize = 32
            titleLabel.fontColor = .red // İstediğin kırmızı renk
            titleLabel.position = CGPoint(x: 0, y: 60) // Kutunun içinde yukarıda
            titleLabel.zPosition = 51
            gameOverBox.addChild(titleLabel) // Sahneye değil, KUTUYA ekliyoruz
            
            // 4. Skorlar: Data Stolen (Kutunun içine)
            let highScore = UserDefaults.standard.integer(forKey: "HighScore")
            if score > highScore {
                UserDefaults.standard.set(score, forKey: "HighScore")
            }
            
            let scoreLabel = SKLabelNode(fontNamed: "Orbitron-Regular") // Yoksa "AvenirNext-Bold"
            scoreLabel.text = "Data Stolen: \(score)"
            scoreLabel.fontSize = 22
            scoreLabel.fontColor = .cyan // İstediğin mavi renk
            scoreLabel.position = CGPoint(x: 0, y: 10) // Başlığın altında
            scoreLabel.zPosition = 51
            gameOverBox.addChild(scoreLabel)
            
            let bestLabel = SKLabelNode(fontNamed: "Orbitron-Regular")
            bestLabel.text = "Best Hack: \(max(score, highScore))"
            bestLabel.fontSize = 18
            bestLabel.fontColor = .cyan.withAlphaComponent(0.7) // Biraz daha soluk mavi
            bestLabel.position = CGPoint(x: 0, y: -20)
            bestLabel.zPosition = 51
            gameOverBox.addChild(bestLabel)
            
            // 5. Restart Mesajı (En altta)
            let restartLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
            restartLabel.text = "Tap to Reboot"
            restartLabel.fontSize = 20
            restartLabel.fontColor = .yellow
            restartLabel.position = CGPoint(x: 0, y: -80) // Kutunun altında
            restartLabel.zPosition = 51
            
            // Yanıp sönme efekti
            let blink = SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.fadeIn(withDuration: 0.5)])
            restartLabel.run(SKAction.repeatForever(blink))
            
            gameOverBox.addChild(restartLabel)
        }
    
    func restartGame() {
        if let view = self.view {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            let transition = SKTransition.fade(withDuration: 0.5)
            view.presentScene(newScene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        timeSinceLastSpawn += deltaTime
        if timeSinceLastSpawn > obstacleSpawnRate {
            spawnObstacle()
            timeSinceLastSpawn = 0
        }
    }
}
// Yardımcı bir eklenti: Görseli bozmadan sahneye sığdırmak için
extension SKSpriteNode {
    func aspectFillToSize(fillSize: CGSize) {
        if let texture = self.texture {
            self.size = texture.size()
            let verticalRatio = fillSize.height / self.texture!.size().height
            let horizontalRatio = fillSize.width / self.texture!.size().width
            let scaleRatio = max(verticalRatio, horizontalRatio)
            self.setScale(scaleRatio)
        }
    }
}
