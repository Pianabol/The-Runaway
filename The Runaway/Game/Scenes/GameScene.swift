//
//  GameScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

// bu versiyona, game over eklendi, ve çalışırsa eğer restart modu geldi. hadi bakalım.

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: PlayerNode?
    
    // Oyun durumunu takip etmek için bir değişken
    var isGameOver = false
    
    // Zamanlayıcılar
    var lastUpdateTime: TimeInterval = 0
    var obstacleSpawnRate: TimeInterval = 1.5
    var timeSinceLastSpawn: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        // ÇÖZÜM BURADA: Merkez noktasını hep ekranın ortası (0.5, 0.5) yapıyoruz.
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5) //umarım restart edince her şey birbirine girmez bu sefer.
                
        self.backgroundColor = .black
        
        
        // Çarpışma Dedektifini Aktif Et
        physicsWorld.contactDelegate = self
        
        // Yerçekimi
        physicsWorld.gravity = CGVector(dx: 0, dy: -12.0)
        
        createWalls()
        addPlayer()
    }
    
    func createWalls() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = PhysicsCategories.ground
    }
    
    func addPlayer() {
        player = PlayerNode(width: 50)
        player?.position = CGPoint(x: -self.size.width / 3, y: 0)
        if let playerNode = player {
            addChild(playerNode)
        }
    }
    
    func spawnObstacle() {
        // Eğer oyun bittiyse yeni engel üretme
        if isGameOver { return }
        
        let obstacleWidth: CGFloat = 40
        let obstacleHeight: CGFloat = 100
        
        let obstacle = ObstacleNode(width: obstacleWidth, height: obstacleHeight)
        
        let startX = self.size.width / 2 + obstacleWidth
        let isTop = Bool.random()
        let yPos = isTop ? (self.size.height / 2 - obstacleHeight) : (-self.size.height / 2)
        
        obstacle.position = CGPoint(x: startX, y: yPos)
        addChild(obstacle)
        
        let moveLeft = SKAction.moveBy(x: -(self.size.width + obstacleWidth * 2), y: 0, duration: 4.0)
        let remove = SKAction.removeFromParent()
        
        obstacle.run(SKAction.sequence([moveLeft, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1. Durum: Oyun bittiyse, tıklayınca yeniden başlat
        if isGameOver {
            restartGame()
            return
        }
        
        // 2. Durum: Oyun devam ediyorsa yerçekimini çevir
        physicsWorld.gravity.dy *= -1
        player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: physicsWorld.gravity.dy * 2))
    }
    
    // Çarpışma Algılayıcı
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (PhysicsCategories.player | PhysicsCategories.obstacle) {
            triggerGameOver()
        }
    }
    
    func triggerGameOver() {
        // Zaten oyun bittiyse tekrar çalıştırma (bazen üst üste tetiklenebilir)
        if isGameOver { return }
        
        isGameOver = true
        print("OYUN BİTTİ")
        
        // 1. Oyuncuyu Kırmızı Yap
        player?.fillColor = .red
        
        // 2. Sahnedeki her şeyi durdur (Engeller dursun)
        // self.isPaused = true // Bunu yaparsak her şey donar, Restart yazısı da çıkmaz.
        // O yüzden sadece engellerin hızını 0 yapıyoruz:
        self.enumerateChildNodes(withName: "Obstacle") { node, _ in
            node.removeAllActions()
        }
        player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // Oyuncuyu dondur
        
        // 3. Ekrana "GAME OVER" Yazısı Ekle
        let gameOverLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 60
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        gameOverLabel.zPosition = 10 // Her şeyin üstünde görünsün
        addChild(gameOverLabel)
        
        // 4. "Tap to Restart" Yazısı Ekle
        let restartLabel = SKLabelNode(fontNamed: "Helvetica")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 30
        restartLabel.fontColor = .yellow
        restartLabel.position = CGPoint(x: 0, y: -50)
        restartLabel.zPosition = 10
        addChild(restartLabel)
    }
    
    func restartGame() {
        // Sahneyi sıfırdan oluştur ve geçiş yap
        if let view = self.view {
            // Yeni bir sahne yarat
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            
            // Animasyonlu geçiş (Kapı gibi açılsın)
            let transition = SKTransition.doorsOpenHorizontal(withDuration: 0.5)
            view.presentScene(newScene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        timeSinceLastSpawn += deltaTime
        
        if timeSinceLastSpawn > obstacleSpawnRate {
            spawnObstacle()
            timeSinceLastSpawn = 0
        }
    }
}
