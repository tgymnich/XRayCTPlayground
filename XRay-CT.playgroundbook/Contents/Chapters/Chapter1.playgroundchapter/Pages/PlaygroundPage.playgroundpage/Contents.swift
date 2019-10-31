//#-hidden-code
import UIKit
import SpriteKit
import PlaygroundSupport

let page = PlaygroundPage.current
let gameViewController = GameViewController()

let liveViewController: GameViewController = gameViewController
page.needsIndefiniteExecution = true
page.liveView = liveViewController

let gameScene = gameViewController.gameScene!


func getPhantomPixelMatrix() -> Matrix {
    return gameScene.getPhantomPixelMatrix()!
}

func computeSinogram(pixelData: Matrix, angles: [Double]) -> Matrix {
    gameScene.animateEmitterDetectorArray()
    return gameScene.renderSinogramAnimation(matrix: pixelData, angles: angles)
}

func filterSinogram(_ sinogram: Matrix, filter: Filter) -> Matrix {
    return Matrix.filterSinogram(sinogram, filter: filter)
}

func computeBackprojection(sinogram: Matrix, angles: [Double]) -> Matrix? {
    gameScene.renderBackprojectionAnimation(sinogram: sinogram, angles: angles)
    return nil
}

//#-end-hidden-code
let pixelData = getPhantomPixelMatrix()

let angles: [Double] = stride(from: 0, to: 180, by: 1).map { $0 }

let sinogram = computeSinogram(pixelData: pixelData, angles: angles)

let filteredSinogram = filterSinogram(sinogram, filter: .hamming)

let backprojection = computeBackprojection(sinogram: filteredSinogram, angles: angles)
