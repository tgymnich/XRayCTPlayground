//
//  PhantomNode.swift
//  XRay-CT
//
//  Created by Tim Gymnich on 3/16/19.
//  Copyright © 2019 Tim Gymnich. All rights reserved.
//

import SpriteKit

final public class PhantomNode: SKShapeNode {
    
    public init(size: CGSize) {
        let height = size.height
        let width = size.width
        let origin = CGPoint(x: -height/2, y: -width/2)
        let rect = CGRect(origin: origin, size: size)
        
        super.init()
        
        self.path = CGPath(rect: rect, transform: nil)
        self.lineWidth = 0.0
        self.fillColor = .black
        
        let ellipseA = SKShapeNode(ellipseOf: CGSize(width: 0.69 * width, height: 0.92 * height))
        ellipseA.lineWidth = 0.0
        ellipseA.fillColor = UIColor.white
        ellipseA.position = CGPoint(x: 0, y: 0)
        self.addChild(ellipseA)
        
        let ellipseB = SKShapeNode(ellipseOf: CGSize(width: 0.6224 * width, height: 0.874 * width))
        ellipseB.fillColor = UIColor.darkGray
        ellipseB.alpha = 1.0
        ellipseB.lineWidth = 0.0
        ellipseB.zRotation = 0.0
        ellipseB.position = CGPoint(x: 0, y: -0.0092 * height)
        ellipseA.addChild(ellipseB)
        
        let ellipseC = SKShapeNode(ellipseOf: CGSize(width: 0.11 * width, height: 0.31 * height))
        ellipseC.fillColor = UIColor.black
        ellipseC.alpha = 0.8
        ellipseC.lineWidth = 0.0
        ellipseC.zRotation = -0.314159
        ellipseC.position = CGPoint(x: 0.11 * width, y: 0)
        ellipseA.addChild(ellipseC)
        
        let ellipseD = SKShapeNode(ellipseOf: CGSize(width: 0.16 * width, height: 0.41 * height))
        ellipseD.fillColor = UIColor.black
        ellipseD.lineWidth = 0.0
        ellipseD.alpha = 0.8
        ellipseD.zRotation = 0.314159
        ellipseD.position = CGPoint(x: -0.11 * width, y: 0)
        ellipseA.addChild(ellipseD)
        
        let ellipseE = SKShapeNode(ellipseOf: CGSize(width: 0.21 * width, height: 0.25 * height))
        ellipseE.fillColor = UIColor.white
        ellipseE.lineWidth = 0.0
        ellipseE.alpha = 0.4
        ellipseE.zRotation = 0.0
        ellipseE.position = CGPoint(x: 0, y: 0.35 / 2 * height)
        ellipseA.addChild(ellipseE)
        
        let ellipseF = SKShapeNode(ellipseOf: CGSize(width: 0.046 * width, height: 0.046 * height))
        ellipseF.fillColor = UIColor.lightGray
        ellipseF.lineWidth = 0.0
        ellipseF.zRotation = 0.0
        ellipseF.alpha = 0.4
        ellipseF.position = CGPoint(x: 0, y: 0.1 / 2 * height)
        ellipseA.addChild(ellipseF)
        
        let ellipseG = SKShapeNode(ellipseOf: CGSize(width: 0.046 * width, height: 0.046 * height))
        ellipseG.fillColor = UIColor.lightGray
        ellipseG.lineWidth = 0.0
        ellipseG.zRotation = 0.0
        ellipseG.alpha = 0.4
        ellipseG.position = CGPoint(x: 0, y: -0.1 / 2 * height)
        ellipseA.addChild(ellipseG)
        
        let ellipseH = SKShapeNode(ellipseOf: CGSize(width: 0.046 * width, height: 0.023 * height))
        ellipseH.fillColor = UIColor.gray
        ellipseH.lineWidth = 0.0
        ellipseH.zRotation = 0.0
        ellipseH.alpha = 0.6
        ellipseH.position = CGPoint(x: -0.04 * width, y: -0.3025 * height)
        ellipseA.addChild(ellipseH)
        
        let ellipseI = SKShapeNode(ellipseOf: CGSize(width: 0.023 * width, height: 0.023 * height))
        ellipseI.fillColor = UIColor.gray
        ellipseI.lineWidth = 0.0
        ellipseI.zRotation = 0.0
        ellipseI.alpha = 0.6
        ellipseI.position = CGPoint(x: 0, y: -0.3025 * height)
        ellipseA.addChild(ellipseI)
        
        let ellipseJ = SKShapeNode(ellipseOf: CGSize(width: 0.023 * width, height: 0.046 * height))
        ellipseJ.fillColor = UIColor.lightGray
        ellipseJ.lineWidth = 0.0
        ellipseJ.zRotation = 0.0
        ellipseJ.alpha = 0.4
        ellipseJ.position = CGPoint(x: 0.03 * width, y: -0.605 / 2 * height)
        ellipseA.addChild(ellipseJ)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

