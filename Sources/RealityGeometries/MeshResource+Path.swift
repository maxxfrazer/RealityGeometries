//
//  MeshResource+Path.swift
//  
//
//  Created by Max Cobb on 15/10/2021.
//

import RealityKit
import CoreGraphics
import os

extension MeshResource {

    /// Create your path (triangle strip) from a series of `SIMD3<Float>` points
    ///
    /// This path is assumed all normals facing directly up
    /// in the positive Y axis for now.
    ///
    /// - Parameters:
    ///   - path: Point from which to make the path.
    ///   - pathProperties: Properties of the path, including width and corner behaviour.
    /// - Returns: A new MeshResource representing the path for use with any RealityKit Application, and path length.
    public static func generatePath(
        _ points: [SIMD3<Float>], pathProperties: PathProperties = .init()
    ) throws -> (mesh: MeshResource?, pathLength: Float) {
        let (meshDesc, length) = self.pathDescriptor(
            path: points, pathProperties: pathProperties
        )
        guard let meshDesc = meshDesc else {
            return (nil, length)
        }
        return try (MeshResource.generate(from: [meshDesc]), length)
    }

    /// Properties relating to the path being created by MeshResource.generatePath
    public struct PathProperties {
        /// Width of your path (default 0.5).
        public var width: Float
        /// Number of points to make the curve at any turn in the path, default to 8. 0 will make sharp corners.
        public var curvePoints: Float
        /// Distance from the centre of the path to the inner edge of the curve radius.
        public var curveDistance: Float
        /// Type of texture mapping for the path. Default `.zeroToOne`
        public var textureMapping: PathTextureMapping

        /// Initialise the PathProperties for a generated Path
        public init(
            width: Float = 0.5,
            curvePoints: Float = 8,
            curveDistance: Float = 1.5,
            textureMapping: PathTextureMapping = .zeroToOne
        ) {
            self.width = width
            self.curvePoints = curvePoints
            self.curveDistance = curveDistance
            self.textureMapping = textureMapping
        }
    }
    /// Type of texture mapping for the path.
    public enum PathTextureMapping {
        /// Path texture mapping in y axis goes from zero at the beginning, one at the end.
        case zeroToOne
        /// Path texture mapping in y axis is equal to the lenght of the path
        case repeating
    }

    fileprivate static func generatePathVerts(
        _ path: [SIMD3<Float>], properties: PathProperties
    ) -> (vertices: [CompleteVertex], indices: [UInt32]) {
        var vertices: [CompleteVertex] = []
        var indices: [UInt32] = []
        let maxIndex = path.count - 1
        var bentBy: Float = 0
        for (index, vert) in path.enumerated() {
            var addVector: SIMD3<Float>!
            if index == 0 {
                // first point
                addVector = SIMD3<Float>(path[index + 1].z - vert.z, 0, vert.x - path[index + 1].x)
            } else if index < maxIndex {
                let toThis = simd.normalize((vert - path[index - 1]).flattened())
                let fromThis = simd.normalize((path[index + 1] - vert).flattened())
                bentBy = fromThis.angleChange(to: toThis)
                let resultant = (toThis + fromThis) / 2
                addVector = SIMD3<Float>(resultant.z, 0, -resultant.x)
            } else {
                // last point
                addVector = SIMD3<Float>(vert.z - path[index - 1].z, 0, path[index - 1].x - vert.x)
            }
            addVector = simd.normalize(addVector) * (properties.width / 2)
            if properties.curvePoints > 0, path.count >= index + 2, bentBy > 0.001 {
                let edge1 = vert - addVector
                let edge2 = vert + addVector
                var bendAround = vert - (addVector * properties.curveDistance)

                // replace this with quaternions when possible
                if MeshResource.newTurning(points: Array(path[(index-1)...(index+1)])) < 0 { // left turn
                    bendAround = vert + (addVector * properties.curveDistance)
                    bentBy *= -1
                }
                for val in 0...Int(properties.curvePoints) {
                    let firstPoint = edge2.rotate(
                        about: bendAround, by: (-0.5 + Float(val) / properties.curvePoints) * bentBy
                    )
                    let secondPoint = edge1.rotate(
                        about: bendAround,
                        by: (-0.5 + Float(val) / properties.curvePoints) * bentBy
                    )
                    vertices.append(contentsOf: [
                        CompleteVertex(position: firstPoint, normal: [0, 1, 0], uv: [0, 0]),
                        CompleteVertex(position: secondPoint, normal: [0, 1, 0], uv: [0, 0])
                    ])
                    addTriangleIndices(indices: &indices, at: UInt32(vertices.count - 2))
                }
            } else {
                // assuming the path is just flat for now, even though it can be angled.
                // the turning part doesn't do anything nice with sloped paths yet.
                vertices.append(CompleteVertex(position: vert + addVector, normal: [0, 1, 0], uv: .zero))
                vertices.append(CompleteVertex(position: vert - addVector, normal: [0, 1, 0], uv: .zero))
                if index > 0 {
                    addTriangleIndices(indices: &indices, at: UInt32(vertices.count - 2))
                }
            }
        }
        return (vertices, indices)
    }

    /// Create your path (triangle strip) from a series of `SIMD3<Float>` points
    ///
    /// This path is assumed all normals facing directly up
    /// in the positive Y axis for now.
    ///
    /// - Parameters:
    ///   - path: Point from which to make the path.
    ///   - pathProperties: Properties of the path, including width and corner behaviour.
    /// - Returns: A new MeshDescriptor representing the path for use with any RealityKit Application, and path length.
    public class func pathDescriptor(
        path: [SIMD3<Float>], pathProperties: PathProperties
    ) -> (MeshDescriptor?, Float) {
        if path.count < 2 {
            return (nil, 0)
        }
        if pathProperties.curveDistance < 1 {
            os_log(.error, "curve distance is too low, minimum value is 1")
        }
        var (vertices, indices) = generatePathVerts(path, properties: pathProperties)
        let (arr, pathLength) = MeshResource.distancesBetweenValues(of: vertices)
        let texDivY = pathProperties.textureMapping == .zeroToOne ? pathLength : 1

        for (idx, lenVal) in arr.enumerated() {
            vertices[idx * 2].uv = [0, lenVal / texDivY]
            vertices[idx * 2 + 1].uv = [1, lenVal / texDivY]
        }

        let meshDescr = vertices.generateMeshDescriptor(with: indices)
        return (meshDescr, pathLength)
    }

    fileprivate static func addTriangleIndices(indices: inout [UInt32], at index: UInt32) {
        indices.append(contentsOf: [
            index - 2, index - 1, index,
            index, index - 1, index + 1
        ])
    }

    fileprivate static func distancesBetweenValues(
        of arr: [CompleteVertex]
    ) -> ([Float], Float) {
        var totalDistance: Float = 0
        let myarr = Array(0...Int(arr.count / 2 - 1))
        let vals = myarr.map { (val) -> Float in
            if val == 0 {
                return 0
            }
            let count = val * 2 + 1
            let lCenter = (arr[count].position + arr[count - 1].position) / 2
            let llCenter = (arr[count - 2].position + arr[count - 3].position) / 2
            let newDistance = simd.distance(lCenter, llCenter)
            totalDistance += Float(newDistance)
            return totalDistance
        }
        return (vals, totalDistance)
    }
    fileprivate static func newTurning(points: [SIMD3<Float>]) -> Float {
        guard points.count == 3 else {
            return 0
        }
        let vec1 = points[1] - points[0]
        let vec2 = points[2] - points[1]
        return atan2(vec1.x * vec2.z - vec1.z * vec2.x, vec1.x * vec2.x + vec1.z * vec2.z)
    }
}

fileprivate extension SIMD3 where SIMD3.Scalar == Float {
    /// Angle change between two vectors
    ///
    /// - Parameter vector: vector to compare
    /// - Returns: angle between the vectors
    func angleChange(to vector: SIMD3<Scalar>) -> Float {

        let dot = simd.dot(simd.normalize(self), simd.normalize(vector))

        return acos(dot / sqrt(simd.length_squared(self) * simd.length_squared(vector)))
    }

    /// Given a point and origin, rotate along X/Z plane by radian amount
    ///
    /// - parameter origin: Origin for the start point to be rotated about
    /// - parameter by: Value in radians for the point to be rotated by
    ///
    /// - returns: New SCNVector3 that has the rotation applied
    func rotate(
        about origin: SIMD3<Scalar>, by rotation: Float
    ) -> SIMD3<Scalar> {
        let pointRepositionedXY = [self.x - origin.x, self.z - origin.z]
        let sinAngle = sin(rotation)
        let cosAngle = cos(rotation)
        return SIMD3<Scalar>(
            x: pointRepositionedXY[0] * cosAngle - pointRepositionedXY[1] * sinAngle + origin.x,
            y: self.y,
            z: pointRepositionedXY[0] * sinAngle + pointRepositionedXY[1] * cosAngle + origin.z
        )
    }
}

fileprivate extension SIMD3 where SIMD3.Scalar: Comparable {
    /// As I'm assuming the path is mostly flat for now, needed this to make the rotations easier
    ///
    /// - Returns: the same vector with the y value set to 0
    func flattened() -> SIMD3<Scalar> where Scalar == Float {
        return SIMD3<Scalar>(self.x, 0, self.z)
    }
}
