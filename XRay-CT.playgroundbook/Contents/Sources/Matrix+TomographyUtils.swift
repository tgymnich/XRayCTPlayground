//
//  Matrix+TomographyUtils.swift
//  XRay-CT
//
//  Created by Tim Gymnich on 3/17/19.
//  Copyright © 2019 Tim Gymnich. All rights reserved.
//

import Accelerate

extension Matrix {
    
    /// Filters the singogram by applying a filter to the shifted frequency domain of the singnals in the sinogram.
    static public func filterSinogram(_ matrix: Matrix, filter filterType: Filter = .none) -> Matrix {
        let LOG_N = vDSP_Length(log2(Double(matrix.rows)))
        let vectorLength = matrix.rows
        let vectorCount = matrix.columns
        let count = matrix.columns * matrix.rows
        let setup: FFTSetupD = vDSP_create_fftsetupD(LOG_N, FFTRadix(kFFTRadix2))!
        defer { vDSP_destroy_fftsetupD(setup) }
        
        // Transpose the matrix for easier access to the columns
        let tm = matrix.transpose()
        
        var tempSplitComplexReal: [Double] = tm.grid
        var tempSplitComplexImag: [Double] = [Double](repeating: 0.0, count: count)
        var tempSplitComplex : DSPDoubleSplitComplex = DSPDoubleSplitComplex(realp: &tempSplitComplexReal, imagp: &tempSplitComplexImag)
        
        // Rearrange the Fourier transform by shifting the zero-frequency component to the center of the vector. The imaginary part can be ignored since its zero.
        ifftshift(vectors: &tempSplitComplexReal, vectorCount: tm.rows, vectorLength: tm.columns)
        
        vDSP_fftm_zipD(setup, &tempSplitComplex, 1, vectorLength, LOG_N, vDSP_Length(vectorCount), FFTDirection(kFFTDirection_Forward))
        
        fftshift(vectors: &tempSplitComplexReal, vectorCount: tm.rows, vectorLength: tm.columns)
        fftshift(vectors: &tempSplitComplexImag, vectorCount: tm.rows, vectorLength: tm.columns)
        
        // Apply a filter to the Fourier transform to filter out frequencies near the zero-frequency (fourier slice theorem).
        var filter: [Double]
        
        switch filterType {
        case .none: break
        case .ramp:
            filter = createModifiedRampFilter(vectorLength: vectorLength)
            fallthrough
        case .hamming:
            filter = createModifiedHammingFilter(vectorLength: vectorLength)
            fallthrough
        default:
            
            tempSplitComplexReal.withUnsafeMutableBufferPointer { ptr in
                for i in 0..<vectorCount {
                    let sourceVectorStart = ptr.baseAddress?.advanced(by: i * vectorLength)
                    vDSP_vmulD(sourceVectorStart!, 1, &filter, 1, sourceVectorStart!, 1, vDSP_Length(vectorLength))
                }
            }
            
            tempSplitComplexImag.withUnsafeMutableBufferPointer { ptr in
                for i in 0..<vectorCount {
                    let sourceVectorStart = ptr.baseAddress?.advanced(by: i * vectorLength)
                    vDSP_vmulD(sourceVectorStart!, 1, &filter, 1, sourceVectorStart!, 1, vDSP_Length(vectorLength))
                }
            }
        }
        
        ifftshift(vectors: &tempSplitComplexReal, vectorCount: tm.rows, vectorLength: tm.columns)
        ifftshift(vectors: &tempSplitComplexImag, vectorCount: tm.rows, vectorLength: tm.columns)
        
        vDSP_fftm_zipD(setup, &tempSplitComplex, 1, vectorLength, LOG_N, vDSP_Length(vectorCount), FFTDirection(kFFTDirection_Inverse))
        
        fftshift(vectors: &tempSplitComplexReal, vectorCount: tm.rows, vectorLength: tm.columns)
        fftshift(vectors: &tempSplitComplexImag, vectorCount: tm.rows, vectorLength: tm.columns)
        
        let resultMatrix = Matrix(rows: tm.rows, columns: tm.columns, grid: tempSplitComplexReal).transpose()
        return resultMatrix
    }
    
    /// Rearranges a Fourier transform by shifting the zero-frequency component to the center of the vector.
    static func fftshift(vectors : inout [Double], vectorCount: Int, vectorLength: Int) {
        // TODO: handle case where vectorLength % 2 != 0
        assert(vectorLength % 2 == 0)
        let half = vectorLength / 2
        
        vectors.withUnsafeMutableBufferPointer { ptr in
            for i in 0..<vectorCount {
                cblas_dswap(Int32(half), ptr.baseAddress?.advanced(by: i * vectorLength), 1, ptr.baseAddress?.advanced(by: i * vectorLength + half), 1)
            }
        }
    }
    
    /// Rearranges a zero-frequency-shifted Fourier transform back to the original transform. (Inverse of fftshift)
    static func ifftshift(vectors: inout [Double], vectorCount: Int, vectorLength: Int) {
        // TODO: handle case where vectorLength % 2 != 0
        assert(vectorLength % 2 == 0)
        let half = vectorLength / 2
        
        vectors.withUnsafeMutableBufferPointer { ptr in
            for i in 0..<vectorCount {
                cblas_dswap(Int32(half), ptr.baseAddress?.advanced(by: i * vectorLength), 1, ptr.baseAddress?.advanced(by: i * vectorLength + half), 1)
            }
        }
    }
    
    /// Creates a modified hamming filter by applying a modified ramp filter to the hamming window.
    /// Usefull for filtering out frequency components arround the zero-frequency.
    static func createModifiedHammingFilter(vectorLength: Int) -> [Double] {
        var hamm: [Double] = [Double](repeating: 0.0, count: vectorLength)
        var ramp = createModifiedRampFilter(vectorLength: vectorLength)
        
        hamm.withUnsafeMutableBufferPointer { ptr in
            vDSP_hamm_windowD(ptr.baseAddress!, vDSP_Length(vectorLength), 0)
            vDSP_vmulD(&ramp, 1, ptr.baseAddress!, 1, ptr.baseAddress!, 1, vDSP_Length(vectorLength))
        }
        
        return hamm
    }
    
    /// Creates a modified ramp filter.
    /// Usefull for filtering out frequency components arround the zero-frequency
    static func createModifiedRampFilter(vectorLength: Int) -> [Double] {
        var ramp: [Double] = [Double](repeating: 0.0, count: vectorLength)
        var initalValue = 1.0
        var intermediateValue = 0.0
        var endValue = 1.0
        
        let (length,remainder) = vectorLength.quotientAndRemainder(dividingBy: 2)
        
        ramp.withUnsafeMutableBufferPointer { ptr in
            let seccondHalf = ptr.baseAddress?.advanced(by: length)
            vDSP_vgenD(&initalValue, &intermediateValue, ptr.baseAddress!, 1, vDSP_Length(length + 1))
            vDSP_vgenD(&intermediateValue, &endValue, seccondHalf!, 1, vDSP_Length(length + remainder))
        }
        return ramp
    }
}


public enum Filter {
    case hamming
    case ramp
    case none
}

