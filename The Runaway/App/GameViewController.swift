//
//  GameViewController.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let view = self.view as! SKView?
        {
            
            /* eski oyun açılışı, yenisinde giriş ekranı var. bunu silme bi dursun
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene")
            {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            } */
            
            // Artık dosya (sks) aramıyoruz, direkt kodla MenuScene yaratıyoruz
            let scene = MenuScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill // Ekranı tam kaplasın

            view.presentScene(scene)
            
            //şimdilik bi engelleri görünür yap.
            view.showsPhysics = true
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return .allButUpsideDown
        }
        else
        {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool
    {
        return true
    }
}
