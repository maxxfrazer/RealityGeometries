//
//  File.swift
//  
//
//  Created by Max Cobb on 11/06/2021.
//

import RealityKit

extension MeshResource {
    static func generateDetailedPlane(
        width: Float, depth: Float, vertices: (Int, Int)
    ) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        for x_v in 0..<(vertices.0) { // 5
            let vertexCounts = meshPositions.count
            print(vertexCounts)
            for y_v in 0..<(vertices.1) { // 4
                meshPositions.append([
                    (Float(x_v) / Float(vertices.0 - 1) - 0.5) * width, 0, (0.5 - Float(y_v) / Float(vertices.1 - 1)) * depth
                ])
                if x_v > 0 && y_v > 0 {
                    indices.append(
                        contentsOf: [
                            vertexCounts - vertices.1, vertexCounts, vertexCounts - vertices.1 + 1,
                            vertexCounts - vertices.1 + 1, vertexCounts, vertexCounts + 1
                        ].map { UInt32($0 + y_v - 1) })
                }
            }
        }
        descr.primitives = .triangles(indices)
        descr.positions = MeshBuffer(meshPositions)
        // - TODO: Add Texture Map
//        descr.textureCoordinates = MeshBuffers.TextureCoordinates([])
        return try .generate(from: [descr])
    }
}
