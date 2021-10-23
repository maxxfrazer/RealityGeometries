//
//  MeshResource+Planes.swift
//  
//
//  Created by Max Cobb on 11/06/2021.
//

import RealityKit

extension MeshResource {
    /// Creates a new plane mesh with the specified values.
    /// - Parameters:
    ///   - width: Width of the output plane
    ///   - depth: Depth of the output plane
    ///   - vertices: Vertex count in the x and z axis
    /// - Returns: A plane mesh
    public static func generateDetailedPlane(
        width: Float, depth: Float, vertices: (Int, Int)
    ) throws -> MeshResource {
        var descr = MeshDescriptor()
        var meshPositions: [SIMD3<Float>] = []
        var indices: [UInt32] = []
        var textureMap: [SIMD2<Float>] = []
        for x_v in 0..<(vertices.0) {
            let vertexCounts = meshPositions.count
            print(vertexCounts)
            for y_v in 0..<(vertices.1) {
                meshPositions.append([
                    (Float(x_v) / Float(vertices.0 - 1) - 0.5) * width,
                    0,
                    (0.5 - Float(y_v) / Float(vertices.1 - 1)) * depth
                ])
                textureMap.append([Float(x_v) / Float(vertices.0 - 1), Float(y_v) / Float(vertices.1 - 1)])
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
        descr.textureCoordinates = MeshBuffers.TextureCoordinates(textureMap)
        return try .generate(from: [descr])
    }
}
