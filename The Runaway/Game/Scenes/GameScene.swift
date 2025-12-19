//
//  GameScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

// bu versiyona, game over eklendi, ve çalışırsa eğer restart modu geldi. hadi bakalım.
// bu versiyona skor eklendi, yüksek skor kayıt ediliyor. Yeni rekor, yeni yüksek rekor ve kayıtlı.
// arka plan ve engellere görsel eklendi, ayrıca karakterimiz için bir icon getirildi.
// bu versiyonda oyuna, gittikçe zorlaşan bir tasarım eklendi. Yer çekimi (karakter hızı) da artıyor gittikçe, engellerin geliş hızı da artıyor, spawn oluş hızı da.

//bu versiyon büyük final, sesleri ekleyip testlere hazır bir hale getirilecek

import SpriteKit
import GameplayKit
import AVFoundation //sesler

class GameScene: SKScene, SKPhysicsContactDelegate
{
    
    var player: PlayerNode?
    var scoreLabel: SKLabelNode!
    var background: SKSpriteNode! // Arka planı tutacak değişken
    var backgroundMusicPlayer: AVAudioPlayer? //music
    
    var isGameOver = false
    var score = 0
    {
        didSet
        {
            scoreLabel.text = "\(score)"
            adjustDifficulty() // yeni zorluk sistemi
        }
    }
    
    var moveDuration: TimeInterval = 4.0
    var obstacleSpawnRate: TimeInterval = 2.0
    
    var lastUpdateTime: TimeInterval = 0
    // var obstacleSpawnRate: TimeInterval = 1.5 // git gide zorlaşan hale dönüşecek.
    
    
    
    var timeSinceLastSpawn: TimeInterval = 0
    
    override func didMove(to view: SKView)
    {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Siyah arka plan satırını sildik!
         // score = 0
        moveDuration = 4.0                  //her oyunbaşında hızı sıfırla
        createBackground() // YENİ: Arka plan görselini ekle
        obstacleSpawnRate = 2.0
        
        physicsWorld.contactDelegate = self
        // yer çekimini başa döndür
        physicsWorld.gravity = CGVector(dx: 0, dy: -12.0)
        
        createWalls()
        addPlayer()
        setupScoreLabel()
        playBackgroundMusic() //music başlasın
    }
    
    func adjustDifficulty()
    {
            // Hızlanma formülü
            // Başlangıç hızı (4.0) - (Skor * 0.05)
       
            // max(1.2, ...) Oyun asla 1.2 saniyeden daha hızlı olamaz. yoksa çok zor olur.
            
            let newDuration = 4.0 - (Double(score) * 0.05)
            moveDuration = max(1.2, newDuration)
            
            // Hızlandıkça engellerin geliş sıklığını da artır. daha da zorlaştır.
            // Hareket hızının yarısı kadar sürede bir engel at.
            obstacleSpawnRate = moveDuration / 1.8
        
            // oyun ilerledikçe karakterin hızı da artacak
            let baseGravity: CGFloat = 12.0
            let extraGravity = CGFloat(score) * 0.35 // 0.2 -> 0.5 -> 0.35
            let newGravityMagnitude = min(35.0, baseGravity + extraGravity) // 22.0 -> 35.0
        
            //yer çekim yönünü koru:
            let currentSign: CGFloat = physicsWorld.gravity.dy > 0 ? 1.0 : -1.0
        
            physicsWorld.gravity = CGVector(dx: 0, dy: newGravityMagnitude * currentSign)
           // Konsol output hız takibi (Debug için)
           // print("Skor: \(score) | Hız: \(moveDuration) | Sıklık: \(obstacleSpawnRate)")
           // print("Skor: \(score) | Yerçekimi Gücü: \(newGravityMagnitude)")
            
        }
    
    func createBackground()
    {
        // arka plan görseli (deneme)
        background = SKSpriteNode(imageNamed: "bg_cyber")
        // görsel sahneyi kaplar. (Aspect Fill gibi)
        background.size = self.size
        background.aspectFillToSize(fillSize: self.size)
        background.position = CGPoint.zero // Tam orta
        background.zPosition = -10 // en arkada
        addChild(background)
    }
    
    //music
    func playBackgroundMusic()
    {
            // baştan başlat
            backgroundMusicPlayer?.stop()
            backgroundMusicPlayer?.currentTime = 0
            
            //   "bg_music", wav değil m4a
            if let musicURL = Bundle.main.url(forResource: "bg_music", withExtension: "m4a") {
                do {
                    backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                    backgroundMusicPlayer?.numberOfLoops = -1 // -1 = Sonsuz döngü
                    backgroundMusicPlayer?.volume = 0.75 // Ses seviyesi (%50)
                    backgroundMusicPlayer?.prepareToPlay()
                    backgroundMusicPlayer?.play()
                }
                catch
                {
                    print("Müzik çalınamadı: \(error)")
                }
            }
        }
    
    func setupScoreLabel()
    {
        scoreLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .white.withAlphaComponent(0.8) // Biraz daha belirgin yaptım
        scoreLabel.position = CGPoint(x: 0, y: self.size.height / 2 - 160) // Çentik altı
        scoreLabel.zPosition = 5
        addChild(scoreLabel)
    }
    
    func createWalls()
    {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = PhysicsCategories.ground
    }
    
    func addPlayer()
    {
            // virüs genişliği (deneme)
            player = PlayerNode(imageNamed: "virus_player", width: 150)
            
            // Konumunu biraz daha yukarı alalım (y: -100) ki zemine tam otursun
            player?.position = CGPoint(x: -self.size.width / 3, y: -100)
            
            if let playerNode = player
            {
                addChild(playerNode)
            }
    }
    
    func spawnObstacle()
    {
        if isGameOver { return }
        
        // RASTGELE BOYUTLAR
        
        // Genişlik: 150 ile 220 arasında değişsin (Bazen ince, bazen kalın)
        let obstacleWidth = CGFloat.random(in: 220...270)   //200 ile başladık 220-270 oldu bakalım.
        
        
        // Eğer 450 gelirse ekranın yarısını geçer, seni mecburen diğer tarafa iter.
        let obstacleHeight = CGFloat.random(in: 380...570) //250->380 bakalım.670->570
        //test için düşük değerler.
        
        
        let obstacle = ObstacleNode(imageNamed: "obstacle_crystal", width: obstacleWidth, height: obstacleHeight)
        
        // Sağ taraftan başlasın
        let startX = self.size.width / 2 + obstacleWidth
        
        // Ekrana bitişik engeller çıkması için:
        let edgeOffset: CGFloat = 80 // 80 piksellik bir taşma payı
        
        
        //  SABİTLEME
        let isTop = Bool.random()
        let yPos: CGFloat
        
        if isTop
        {
                    // TAVAN:
                    // Normal Konum + edgeOffset (Yukarı it)
                    yPos = (self.size.height / 2 - obstacleHeight / 2) + edgeOffset
                    
                    obstacle.zRotation = .pi // Kristalin ucu aşağı baksın
        }
        else
        {
                    // ZEMİN:
                    // Normal Konum - edgeOffset (Aşağı it)
                    yPos = (-self.size.height / 2 + obstacleHeight / 2) - edgeOffset
        }
        
        obstacle.position = CGPoint(x: startX, y: yPos)
        addChild(obstacle)
        
        // Hız sabiti ( şimdilik sabit, daha sonra değişecek.)
        let moveLeft = SKAction.moveBy(x: -(self.size.width + obstacleWidth * 2), y: 0, duration: moveDuration) //3.5 -> moveDuration
        
        let scoreAction = SKAction.run
        {
            if !self.isGameOver { self.score += 1 }
        }
        
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveLeft, scoreAction, remove]))
    }
    
   /*
    eski engel yaratma func, silme bi şimdilik dursun fail olma ihtimaline karşı.
    func spawnObstacle() {
            if isGameOver { return }
            
            // Görseli büyük tut
            let obstacleWidth: CGFloat = 200
            let obstacleHeight: CGFloat = 360 // Biraz daha uzattım ki ekranı iyice kaplasın
            
            let obstacle = ObstacleNode(imageNamed: "obstacle_crystal", width: obstacleWidth, height: obstacleHeight)
            
            // Sağ taraftan başlasın
            let startX = self.size.width / 2 + obstacleWidth
            
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if isGameOver
        {
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
        
        run(SKAction.playSoundFileNamed("change_dir.wav", waitForCompletion: false))
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == (PhysicsCategories.player | PhysicsCategories.obstacle)
        {
            //  bg music durdur
            backgroundMusicPlayer?.stop()
                        
            // hit sesi (shatter.wav) 💥
            let shatterSound = SKAction.playSoundFileNamed("shatter.wav", waitForCompletion: false)
                        
            //  sessizlik/gerilim 0.5 saniye
            let waitAction = SKAction.wait(forDuration: 0.5)
                        
            // detected.wav
            let detectedVoice = SKAction.playSoundFileNamed("detected.wav", waitForCompletion: false)
                        
            // Bu sesleri sırasıyla oynat:
            run(SKAction.sequence([shatterSound, waitAction, detectedVoice]))
            
            triggerGameOver()
        }
    }
    
    func triggerGameOver()
    {
            if isGameOver { return }
            
            isGameOver = true
            
            // 1. virüsü öldür (efektler)
            player?.color = .red
            player?.colorBlendFactor = 0.8
            player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // Dondur
            
            // Engelleri durdur
            self.enumerateChildNodes(withName: "Obstacle") { node, _ in
                node.removeAllActions()
            }
            
             
            
            // 2. Kutu (Div) Oluşturma
            let boxWidth: CGFloat = 320
            let boxHeight: CGFloat = 260
            let cornerRadius: CGFloat = 20
            
            // Dikdörtgen şekli (Rounded Rect)
            let gameOverBox = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: cornerRadius)
            
            // Tasarım Özellikleri (CSS)
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
            
            //   SYSTEM FAILURE (Kutunun içine ekliyoruz)
            let titleLabel = SKLabelNode(fontNamed: "Orbitron-Bold") // Yoksa "AvenirNext-Bold"
            titleLabel.text = "SYSTEM FAILURE"
            titleLabel.fontSize = 32
            titleLabel.fontColor = .red
            titleLabel.position = CGPoint(x: 0, y: 60) // Kutunun içinde yukarıda
            titleLabel.zPosition = 51
            gameOverBox.addChild(titleLabel) // Sahneye değil, KUTUYA ekliyoruz
            
            //  Data Stolen (Kutunun içine) -skor-
            let highScore = UserDefaults.standard.integer(forKey: "HighScore")
            if score > highScore {
                UserDefaults.standard.set(score, forKey: "HighScore")
            }
            
            let scoreLabel = SKLabelNode(fontNamed: "Orbitron-Regular") // Yoksa "AvenirNext-Bold"
            scoreLabel.text = "Data Stolen: \(score)"
            scoreLabel.fontSize = 22
            scoreLabel.fontColor = .cyan
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
    
    func restartGame()
    {
        if let view = self.view
        {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            let transition = SKTransition.fade(withDuration: 0.5)
            view.presentScene(newScene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if isGameOver { return }
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        timeSinceLastSpawn += deltaTime
        if timeSinceLastSpawn > obstacleSpawnRate
        {
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
