//
//  Matrix.swift
//  XRay-CT
//
//  Created by Tim Gymnich on 3/15/19.
//  Copyright © 2019 Tim Gymnich. All rights reserved.
//

import Accelerate

public struct Matrix {
    
    public let rows: Int
    public let columns: Int
    public var grid: [Double]
    
    public init(rows: Int, columns: Int, grid: [Double]) {
        assert(rows * columns == grid.count)
        self.rows = rows
        self.columns = columns
        self.grid = grid
    }
    
    public init(rows: Int, columns: Int, repeatedValue: Double) {
        self.rows = rows
        self.columns = columns
        self.grid = .init(repeating: repeatedValue, count: rows * columns)
    }
    
    public subscript(row: Int, column: Int) -> Double {
        get { return grid[(row * columns) + column] }
        set { grid[(row * columns) + column] = newValue }
    }
    
    static public func * (lhs: Matrix, rhs: Double) -> Matrix {
        var results = lhs
        
        results.grid.withUnsafeMutableBufferPointer { ptr in
            cblas_dscal(Int32(lhs.grid.count), rhs, ptr.baseAddress, 1)
        }
        return results
    }
    
    public func transpose() -> Matrix {
        var results = Matrix(rows: columns, columns: rows, repeatedValue: 0)
        
        grid.withUnsafeBufferPointer { srcPtr in
            results.grid.withUnsafeMutableBufferPointer { dstPtr in
                vDSP_mtransD(srcPtr.baseAddress!, 1, dstPtr.baseAddress!, 1, vDSP_Length(columns), vDSP_Length(rows))
            }
        }
        return results
    }
}


extension Array where Element == UInt8 {
    
    /// Scales all values for display as a 8-Bit grasyscale bitmap
    init(matrix: Matrix) {
        var input = matrix.grid
        let length = vDSP_Length(input.count)
        var max = 0.0
        var min = 0.0
        
        vDSP_maxvD(&input, 1, &max, length)
        
        var scalingFactor = 255 / max
        
        input.withUnsafeMutableBufferPointer { ptr in
            vDSP_vthresD(ptr.baseAddress!, 1, &min, ptr.baseAddress!, 1, length)
            vDSP_vsmulD(ptr.baseAddress!, 1, &scalingFactor, ptr.baseAddress!, 1, length)
        }
        
        var result = [UInt8](repeating: 0, count: input.count)
        
        vDSP_vfixu8D(&input, 1, &result, 1, length)
        
        self = result
    }
    
}

