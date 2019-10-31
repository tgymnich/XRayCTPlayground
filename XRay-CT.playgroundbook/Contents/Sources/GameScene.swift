//
//  GameScene.swift
//  XRay-CT
//
//  Created by Tim Gymnich on 3/15/19.
//  Copyright © 2019 Tim Gymnich. All rights reserved.
//

import SpriteKit

final public class GameScene: SKScene {
    
    static let size = CGSize(width: 128, height: 128)
    
    public let phantomNode = PhantomNode(size: size)
    let backprojectionNode = SKSpriteNode(imageNamed: "phantom_placeholder")
    let sinogramNode = SKSpriteNode(imageNamed: "animation_loading")
    let rotationTime = 15.0
    
    var allActions: [SKAction] = []
    var animations: SKAction { return SKAction.group(allActions) }
    
    
    override public func didMove(to view: SKView) {
        setupNodes()
    }
    
    /// Renders the phantom image in the current scene and returns the image as a bitmap matrix
    public func getPhantomPixelMatrix() -> Matrix? {
        // Scale to original size before rendering image
        phantomNode.xScale = 1
        phantomNode.yScale = 1
        guard let phantomTexture = self.scene?.view?.texture(from: phantomNode) else { return nil }
        let phantomImage = phantomTexture.cgImage()
        let pixelData = phantomImage.grayScalePixelData().map { Double($0) }
        let pixelMatrix = Matrix(rows: phantomImage.height, columns: phantomImage.width, grid: pixelData)
        phantomNode.xScale = 2
        phantomNode.yScale = 2
        return pixelMatrix
    }
    
    /// Setup for all the UI components
    private func setupNodes() {
        self.backgroundColor = .black
        
        phantomNode.position = CGPoint(x: -175, y: 200)
        phantomNode.xScale = 2
        phantomNode.yScale = 2
        phantomNode.name = "phantomNode"
        self.addChild(phantomNode)
        
        let phantomLabel = SKLabelNode(text: "Phantom")
        phantomLabel.fontName = "San Francisco"
        phantomLabel.position = CGPoint(x: phantomNode.frame.midX, y: phantomNode.frame.maxY + 25)
        phantomLabel.color = .white
        self.addChild(phantomLabel)
        
        backprojectionNode.position = CGPoint(x: 175, y: 200)
        backprojectionNode.name = "backprojectionNode"
        self.addChild(backprojectionNode)
        
        let backProjectionLabel = SKLabelNode(text: "Backprojection")
        backProjectionLabel.fontName = "San Francisco"
        backProjectionLabel.position = CGPoint(x: backprojectionNode.frame.midX, y: phantomNode.frame.maxY + 25)
        backProjectionLabel.color = .white
        self.addChild(backProjectionLabel)
        
        sinogramNode.position = CGPoint(x: 0, y: -250)
        sinogramNode.name = "sinogramNode"
        self.addChild(sinogramNode)
        
        let sinogramLabel = SKLabelNode(text: "Sinogram")
        sinogramLabel.fontName = "San Francisco"
        let sinogramAxisLabelX = SKLabelNode(text: "Degrees")
        let sinogramAxisLabelY = SKLabelNode(text: "X-Ray Attenuation")
        sinogramLabel.position = CGPoint(x: sinogramNode.frame.midX, y: sinogramNode.frame.maxY + 175)
        sinogramLabel.zPosition = 10
        sinogramLabel.color = .white
        self.addChild(sinogramLabel)
        
        sinogramAxisLabelX.position = CGPoint(x: sinogramNode.frame.midX, y: sinogramNode.frame.minY - 175)
        sinogramAxisLabelX.fontName = "San Francisco"
        sinogramAxisLabelX.zPosition = 10
        sinogramAxisLabelX.color = .white
        sinogramAxisLabelX.fontSize = 16.0
        self.addChild(sinogramAxisLabelX)
        
        sinogramAxisLabelY.position = CGPoint(x: sinogramNode.frame.minX + 10, y: sinogramNode.frame.midY)
        sinogramAxisLabelY.fontName = "San Francisco"
        sinogramAxisLabelY.zPosition = 10
        sinogramAxisLabelY.zRotation = 90 * CGFloat.pi/180
        sinogramAxisLabelY.color = .white
        sinogramAxisLabelY.fontSize = 16.0
        self.addChild(sinogramAxisLabelY)
    }
    
    /// Creates the detector array and prepapres its animation
    public func animateEmitterDetectorArray() {
        let detectorArray = SKSpriteNode(imageNamed: "detector_array.png")
        detectorArray.name = "detectorArray"
        detectorArray.size = CGSize(width: phantomNode.frame.width * 1.5, height: phantomNode.frame.height * 1.5)
        detectorArray.position = phantomNode.position
        self.addChild(detectorArray)
        
        if let xraySource = SKEmitterNode(fileNamed: "XRayParticle.sks") {
            xraySource.isHidden = true
            xraySource.emissionAngle = 270 * CGFloat.pi / 180
            xraySource.name = "xraySource"
            xraySource.position = CGPoint(x: 0, y: detectorArray.frame.height / 2 - detectorArray.frame.height * 0.12)
            detectorArray.addChild(xraySource)
            
            let unhide = SKAction.run(SKAction.unhide(), onChildWithName: "xraySource")
            let action = SKAction.run(unhide, onChildWithName: "detectorArray")
            allActions.append(action)
        }
        
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: 1 * CGFloat.pi / 180, duration: rotationTime / 360))
        let action = SKAction.run(rotate, onChildWithName: "detectorArray")
        allActions.append(action)
    }
    
    /// Renders the necessary frames for the sinogram animation in the background. And queues up the animation.
    public func renderSinogramAnimation(matrix: Matrix, angles: [Double]) -> Matrix {
        var sinogram = Matrix(rows: 2 * matrix.rows, columns: angles.count, repeatedValue: 0.0)
        var animationFrames: [SKTexture] = []
        animationFrames.reserveCapacity(angles.count)
        
        for angle in 0..<angles.count {
            Matrix.radon(matrix: matrix, result: &sinogram, angles: angles, angleAt: angle)
            guard let sinogramImage = UIImage.imageFrom(bitmap: [UInt8](matrix: sinogram), width: sinogram.columns, height: sinogram.rows)?.cgImage else { continue }
            animationFrames.append(SKTexture(cgImage: sinogramImage))
        }
        
        sinogramNode.run(SKAction.setTexture(animationFrames.first ?? SKTexture(imageNamed: "sinogram_placeholder"), resize: true))
        sinogramNode.xScale = 540.0 / CGFloat(angles.count)
        sinogramNode.yScale = 1
        let animation = SKAction.repeatForever(SKAction.animate(with: animationFrames, timePerFrame: rotationTime / Double(angles.count) * 0.5))
        let action = SKAction.run(animation, onChildWithName: "sinogramNode")
        allActions.append(action)
        
        return sinogram
    }
    

    
    /// Renders all the frames required by the backprojection animation in the background.
    /// When finished it queues up the animation and starts all other queued animations
    public func renderBackprojectionAnimation(sinogram: Matrix, angles: [Double]) {
        var result = Matrix(rows: sinogram.rows / 2, columns: sinogram.rows / 2, repeatedValue: 0.0)
        var animationFrames: [SKTexture] = []
        animationFrames.reserveCapacity(angles.count)
        
        for angle in 0..<angles.count {
            Matrix.inverseRadon(sinogram: sinogram, result: &result, angles: angles, angleAt: angle)
            let backprojection = [UInt8](matrix: result)
            guard let backprojectionImage = UIImage.imageFrom(bitmap: backprojection, width: result.rows, height: result.columns)?.cgImage else { continue }
            animationFrames.append(SKTexture(cgImage: backprojectionImage))
        }
        
        backprojectionNode.run(SKAction.setTexture(animationFrames.first ?? SKTexture(imageNamed: "phantom_placeholder"), resize: true))
        let animation = SKAction.repeatForever(SKAction.animate(with: animationFrames, timePerFrame: rotationTime / Double(angles.count) * 0.5))
        let action = SKAction.run(animation, onChildWithName: "backprojectionNode")
        allActions.append(action)
        self.run(animations)
    }
    
}
