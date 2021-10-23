//
//  SIMD3+Extension.swift
//  
//
//  Created by Max Cobb on 15/10/2021.
//

import simd

internal extension SIMD3 where SIMD3.Scalar: Comparable {
    /// Scalar distance between two vectors
    ///
    /// - Parameter vector: vector to compare
    /// - Returns: Scalar distance
    func distance(vector: SIMD3<Scalar>) -> Float where Scalar == Float {
        return (self - vector).length
    }

    /// Normalizes the SCNVector
    ///
    /// - Returns: SCNVector3 of length 1.0
    func normalized() -> SIMD3<Scalar> where Scalar == Float {
        return self / self.length
    }

    /// Dot product of two vectors
    ///
    /// - Parameter vector: vector to compare
    /// - Returns: Scalar dot product
    func dot(vector: SIMD3<Scalar>) -> Scalar where Scalar == Float {
        return x * vector.x + y * vector.y + z * vector.z
    }


    // SIMD3<Scalar> operator functions

    static func + (
        left: SIMD3<Scalar>, right: SIMD3<Scalar>
    ) -> SIMD3<Scalar> where Scalar: FloatingPoint {
        return SIMD3<Scalar>(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    static func - (left: SIMD3<Scalar>, right: SIMD3<Scalar>
    ) -> SIMD3<Scalar> where Scalar: FloatingPoint {

        return SIMD3<Scalar>(left.x - right.x, left.y - right.y, left.z - right.z)
    }

    static func * (vector: SIMD3<Scalar>, scalar: Float
    ) -> SIMD3<Scalar> where Scalar == Float {
        return SIMD3<Scalar>(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }

    static func *= (vector: inout SIMD3<Scalar>, scalar: Float
    ) where Scalar == Float {
        vector = (vector * scalar)
    }

    static func / (left: SIMD3<Scalar>, right: SIMD3<Scalar>
    ) -> SIMD3<Scalar> where Scalar: FloatingPoint {
        return SIMD3<Scalar>(left.x / right.x, left.y / right.y, left.z / right.z)
    }

    static func / (vector: SIMD3<Scalar>, scalar: Float
    ) -> SIMD3<Scalar> where Scalar == Float {
        return SIMD3<Scalar>(vector.x / scalar, vector.y / scalar, vector.z / scalar)
    }
}

