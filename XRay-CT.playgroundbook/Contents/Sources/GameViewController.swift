//
//  GameViewController.swift
//  XRay-CT
//
//  Created by Tim Gymnich on 3/15/19.
//  Copyright © 2019 Tim Gymnich. All rights reserved.
//

import UIKit
import SpriteKit
import PlaygroundSupport

public final class GameViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    
    public var gameScene: GameScene?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Create View
        let skview = SKView(frame: view.frame)
        view.autoresizesSubviews = false
        view.addSubview(skview)

        //Setup Constraints
        skview.translatesAutoresizingMaskIntoConstraints = false
        skview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        skview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        skview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        skview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        let scene = GameScene(size: CGSize(width: 750, height: 1134))
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        gameScene = scene
        
        skview.presentScene(scene)
    }
    
}

