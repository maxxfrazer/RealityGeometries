//
//  File.swift
//  
//
//  Created by Max Cobb on 14/03/2023.
//

import RealityKit

public extension MeshResource {
    @available(*, deprecated, renamed: "RealityGeometry.generateCone")
    static func generateCone(
        radius: Float, height: Float, sides: Int = 24, splitFaces: Bool = false,
        smoothNormals: Bool = false
    ) throws -> MeshResource {
        try RealityGeometry.generateCone(
            radius: radius, height: height, sides: sides,
            splitFaces: splitFaces, smoothNormals: smoothNormals
        )
    }

    @available(*, deprecated, renamed: "RealityGeometry.generateCylinder")
    static func generateCylinder(
        radius: Float, height: Float, sides: Int = 24, splitFaces: Bool = false,
        smoothNormals: Bool = false
    ) throws -> MeshResource {
        try RealityGeometry.generateCylinder(
            radius: radius, height: height, sides: sides,
            splitFaces: splitFaces, smoothNormals: smoothNormals
        )
    }

    @available(*, deprecated, renamed: "RealityGeometry.generatePath")
    static func generatePath(
        _ points: [SIMD3<Float>], pathProperties: RealityGeometry.PathProperties = .init()
    ) throws -> (mesh: MeshResource?, pathLength: Float) {
        try RealityGeometry.generatePath(points, pathProperties: pathProperties)
    }

    @available(*, deprecated, renamed: "RealityGeometry.generateDetailedPlane")
    static func generateDetailedPlane(
        width: Float, depth: Float, vertices: (Int, Int)
    ) throws -> MeshResource {
        try RealityGeometry.generateDetailedPlane(width: width, depth: depth, vertices: vertices)
    }

    @available(*, deprecated, renamed: "RealityGeometry.generateTorus")
    static func generateTorus(
        sides: Int, csSides: Int, radius: Float, csRadius: Float
    ) throws -> MeshResource {
        try RealityGeometry.generateTorus(sides: sides, csSides: csSides, radius: radius, csRadius: csRadius)
    }

    @available(*, deprecated, renamed: "RealityGeometry.PathProperties")
    typealias PathProperties = RealityGeometry.PathProperties
}
