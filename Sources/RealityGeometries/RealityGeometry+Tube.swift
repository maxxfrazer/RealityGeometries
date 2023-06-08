//
//  RealityGeometry+Tube.swift
//
//
//  Created by Max Cobb on 13/03/2023.
//

import Foundation
import RealityKit

private extension simd_quatf {
    func split(by factor: Float = 2) -> simd_quatf {
        if self.angle == 0 {
            return self
        } else {
            return simd_quatf(angle: self.angle / factor, axis: self.axis)
        }
    }
    static func zero() -> simd_quatf {
        return simd_quatf(angle: 0, axis: [1, 0, 0])
    }
}

public extension RealityGeometry {

    /// Create a thick line following a series of points in 3D space.
    ///
    /// - Parameters:
    ///   - points: Points that the tube will follow through
    ///   - radius: Radius of the line or tube
    ///   - edges: Number of edges the extended shape should have, recommend at least 3, default is 12.
    /// - Returns: Returns a MeshResource of the new tube!
    static func generateTube(
        points: [SIMD3<Float>], radius: Float, edges: Int = 12
    ) throws -> MeshResource {
        try self.line(points: points, radius: radius, edges: edges).0
    }
    static func line(
        points: [SIMD3<Float>], radius: Float, edges: Int = 12
    ) throws -> (MeshResource, Float) {

        guard let ((geomParts, indices), lineLength) = getAllLineParts(
            points: points, radius: radius,
            edges: edges
        ) else { throw MeshError.invalidInput }
        if geomParts.isEmpty {
            return (try MeshResource.generate(from: []), lineLength)
        }
        let meshDescr = geomParts.generateMeshDescriptor(with: indices)
        return (try MeshResource.generate(from: [meshDescr]), lineLength)
    }

    /// Get the quaternion that converts the start vector to the end vector.
    /// - Parameters:
    ///   - start: Current direction of the vector
    ///   - end: Desired vector direction
    /// - Returns: Quaternion to be applied to the start to get the end.
    fileprivate static func vectorQuatDiff(start: SIMD3<Float>, end: SIMD3<Float>) -> simd_quatf {
        let angle = acos(simd.dot(start, end))
        let axis = simd.normalize(simd.cross(start, end))
        return simd_quatf(angle: angle, axis: axis)
    }

    fileprivate static func getCircularPoints(
        radius: Float, edges: Int,
        orientation: simd_quatf = simd_quatf(angle: 0, axis: SIMD3<Float>([1, 0, 0]))
    ) -> [SIMD3<Float>] {
        var angle: Float = 0
        var verts = [SIMD3<Float>]()
        let angleAdd = Float.pi * 2 / Float(edges)
        for index in 0..<edges {
            let vert = SIMD3<Float>(radius * cos(angle), 0, radius * sin(angle))
            angle += angleAdd
            verts.append(orientation.act(vert))
            if index > 0 {
                verts.append(verts.last!)
            }
        }
        verts.append(verts.first!)
        return verts
    }

    fileprivate static func runAllPoints(
        _ points: [SIMD3<Float>], _ radius: Float, _ edges: Int, _ lineLength: inout Float
    ) -> ([CompleteVertex], [UInt32])? {
        var trueNormals = [SIMD3<Float>](); var trueUVMap = [SIMD2<Float>]()
        var trueVs = [SIMD3<Float>](); var trueInds = [UInt32](); var lastforward = SIMD3<Float>(0, 1, 0)
        guard var lastLocation = points.first else { return nil }
        var lineLength: Float = 0
        var cPoints = self.getCircularPoints(radius: radius, edges: edges)
        let textureXs = cPoints.enumerated().map { (val) -> Float in
            return Float(val.offset) / Float(edges - 1)
        }

        for (index, point) in points.enumerated() {
            let newRotation: simd_quatf!
            if index == 0 {
                let startDirection = simd.normalize(points[index + 1] - point)
                cPoints = self.getCircularPoints(
                    radius: radius, edges: edges,
                    orientation: vectorQuatDiff(start: lastforward, end: startDirection))
                lastforward = simd.normalize(startDirection)
                newRotation = simd_quatf.init()
            } else if index < points.count - 1 {
                trueVs.append(contentsOf: Array(trueVs[(trueVs.count - edges * 2)...]))
                trueUVMap.append(contentsOf: Array(trueUVMap[(trueUVMap.count - edges * 2)...]))
                trueNormals.append(contentsOf: cPoints.map(simd.normalize))
                newRotation = vectorQuatDiff(
                    start: lastforward, end: simd.normalize(points[index + 1] - points[index]))
            } else {
                newRotation = vectorQuatDiff(
                    start: lastforward, end: simd.normalize(points[index] - points[index - 1]))
            }

            if index > 0 {
                let halfRotation = newRotation.split(by: 2)
                // fallback and just apply the half rotation for the turn
                if index < points.count - 1 { cPoints = cPoints.map { halfRotation.normalized.act($0) } }
                lastforward = simd.normalize(simd.cross(cPoints[1], cPoints[0]))

                lineLength += simd.distance(lastLocation, point)
                trueNormals.append(contentsOf: cPoints.map(simd.normalize))
                trueVs.append(contentsOf: cPoints.map { $0 + point })
                lastLocation = point
                trueUVMap.append(contentsOf: textureXs.map { [$0, lineLength] })
                addCylinderVerts(to: &trueInds, startingAt: trueVs.count - edges * 4, edges: edges)
                cPoints = cPoints.map { halfRotation.normalized.act($0) }
                lastforward = simd.normalize(simd.cross(cPoints[1], cPoints[0]))
            } else {
                cPoints = cPoints.map { newRotation.act($0) }
                lastforward = simd.normalize(simd.cross(cPoints[1], cPoints[0]))
                trueNormals.append(contentsOf: cPoints.map(simd.normalize))
                trueUVMap.append(contentsOf: textureXs.map { [$0, lineLength] })
                trueVs.append(contentsOf: cPoints.map { $0 + point })
            }
        }
        return (zip(zip(trueVs, trueNormals), trueUVMap).map {
            CompleteVertex(position: $0.0.0, normal: $0.0.1, uv: $0.1)
        }, trueInds)
    }

    /// This function takes in all the geometry parameters to get the vertices, normals etc
    /// It's currently grossly long, needs cleaning up as a priority.
    ///
    /// - Parameters:
    ///   - points: points for the line to be created
    ///   - radius: radius of the line
    ///   - edges: edges around each point
    /// - Returns: All the bits to create the geometry from and the length of the result
    internal static func getAllLineParts(
        points: [SIMD3<Float>], radius: Float, edges: Int = 12
    ) -> ((vertices: [CompleteVertex], indices: [UInt32]), length: Float)? {
        if points.count < 2 { return nil }

        var lineLength: Float = 0
        guard let (allVertices, trueInds) = runAllPoints(points, radius, edges, &lineLength) else {
            return nil
        }
        return ((allVertices, trueInds), lineLength)
    }

    static private func addCylinderVerts(
        to array: inout [UInt32], startingAt: Int, edges: Int
    ) {
        for i in 0..<edges {
            let fourI = 2 * i + startingAt
            let rv = Int(edges * 2)
            array.append(UInt32(1 + fourI + rv))
            array.append(UInt32(1 + fourI))
            array.append(UInt32(0 + fourI))
            array.append(UInt32(0 + fourI))
            array.append(UInt32(0 + fourI + rv))
            array.append(UInt32(1 + fourI + rv))
        }

    }
}
