//
//  Matrix+Radon.swift
//  XRay-CT
//
//  Created by Tim Gymnich on 3/17/19.
//  Copyright © 2019 Tim Gymnich. All rights reserved.
//

import Foundation

extension Matrix {
    
    private static func rho(_ r: Int, _ R: Int) -> Double {
        let dX = 1.0
        let dRho  = dX / sqrt(2)
        let rhoMin = -(Double(R) - 1) / 2 * dRho
        
        return rhoMin + Double(r) * dRho
    }
    
    private static func rnd(_ number: Double) -> Double {
        return number < 0.0 ? ceil(number - 0.5) : floor(number + 0.5)
    }
    
    /// Computes the radon transfrom of matrix for the angle at index t and writes the result in result.
    static func radon(matrix: Matrix, result: inout Matrix, angles: [Double], angleAt t: Int) {
        let M = matrix.rows
        let N = matrix.columns
        let dX = 1.0
        let dY = 1.0
        let xMin = -(Double(M) - 1) / 2 * dX
        let yMin = -(Double(N) - 1) / 2 * dY
        let R = 2 * max(M,N)
        let radians = angles.map { ($0 + 90) * Double.pi / 180 }
        let c = sqrt(Double(M &* M &+ N &* N))
        
        assert(t<=radians.count)
        assert(result.rows == R && result.columns == angles.count)
        
        // Convert degrees to radians and rotate by 90 degrees
        let theta = radians[t]
        let cosTheta = cos(theta)
        let sinTheta = sin(theta)
        let rhoOffset = xMin * cosTheta + yMin * sinTheta
        
        if abs(sinTheta) > 1 / sqrt(2) {
            let alpha = -cosTheta / sinTheta
            
            for r in 0..<R {
                let beta = (rho(r, R) - rhoOffset) / (dX * sinTheta)
                var sum = 0.0
                
                for m in 0..<M {
                    let n = Int(rnd(alpha * Double(m) + beta))
                    if n >= 0 && n < N {
                        sum += matrix[m,n]
                    }
                }
                let val = dX * sum / abs(sinTheta) / c
                result[r,t] = val
            }
            
        } else {
            let alpha = -sinTheta / cosTheta
            
            for r in 0..<R {
                let beta = (rho(r,R) - rhoOffset) / (dX * cosTheta)
                var sum = 0.0
                
                for n in 0..<N {
                    let m = Int(rnd(alpha * Double(n) + beta))
                    if m >= 0 && m < M {
                        sum += matrix[m,n]
                    }
                }
                let val = dX * sum / abs(cosTheta) / c
                result[r,t] = val
            }
        }
    }
    
    /// Reconstructs the image from a sinogram for angle at index t.
    /// Angles describes the angles (in degrees) at which the projections were taken.
    static func inverseRadon(sinogram: Matrix, result: inout Matrix, angles: [Double], angleAt t: Int) {
        let M = sinogram.rows / 2
        let T = angles.count
        let R = sinogram.rows
        let dX = 1.0
        let xMin = -(Double(M) - 1) / 2 * dX
        let dRho = dX / sqrt(2)
        let rhoMin = -(Double(R) - 1) / 2 * dRho
        let rhoOffset = rhoMin / dRho
        // Convert degrees to radians and rotate by 90 degrees
        let radians = angles.map { ($0 + 90) *  Double.pi / 180 }
        let cosTheta = radians.map { cos($0) }
        let sinTheta = radians.map { sin($0) }
        
        assert(t <= radians.count)
        assert(result.rows == M && result.columns == M)
        
        var xc = Matrix(rows: M, columns: T, repeatedValue: 0.0)
        var ys = Matrix(rows: M, columns: T, repeatedValue: 0.0)
        
        for m in 0..<M {
            let xRel = (xMin + Double(m) * dX) / dRho
            
            for t in 0..<T {
                xc[m,t] = xRel * cosTheta[t]
                ys[m,t] = xRel * sinTheta[t] - rhoOffset
            }
        }
        
        for m in 0..<M {
            for n in 0..<M {
                var sum = 0.0
                let rm = xc[m,t] + ys[n,t]
                let rl = Int(rm)
                if rl < R - 1 && rl >= 0 {
                    let w = rm - Double(rl)
                    sum += (1 - w) * sinogram[rl,t] + w * sinogram[rl+1,t]
                }
                result[m,n] += sum
            }
        }
    }
}
