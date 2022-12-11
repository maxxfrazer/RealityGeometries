//
//  SIMD3+Extension.swift
//  
//
//  Created by Max Cobb on 15/10/2021.
//

import simd

internal extension SIMD3 where SIMD3.Scalar: Comparable {
    // SIMD3<Scalar> operator functions

    static func * (vector: SIMD3<Scalar>, scalar: Float
    ) -> SIMD3<Scalar> where Scalar == Float {
        return SIMD3<Scalar>([vector.x, vector.y, vector.z].map { $0 * scalar })
    }

    static func *= (vector: inout SIMD3<Scalar>, scalar: Float
    ) where Scalar == Float {
        vector = vector * scalar
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
