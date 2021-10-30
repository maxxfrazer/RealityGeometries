//
//  MeshResource+Cone.swift
//  
//
//  Created by Max Cobb on 12/06/2021.
//

import RealityKit

extension MeshResource {
    fileprivate static func coneIndices(
        _ sides: Int, _ lowerCenterIndex: UInt32, _ splitFaces: Bool
    ) -> ([UInt32], [UInt32]) {
        var indices: [UInt32] = []
        var materialIndices: [UInt32] = []
        for side in 0..<sides {
            let bottomLeft = UInt32(side)
            let bottomRight = UInt32(side + 1)
            let topVertex = UInt32(side + sides + 1)

            // First triangle of side
            indices.append(contentsOf: [bottomLeft, topVertex, bottomRight])

            // Add bottom cap triangle
            indices.append(contentsOf: [0, UInt32(side) + 1, UInt32(side) + 2].map { $0 + lowerCenterIndex })

            if splitFaces {
                materialIndices.append(0)
                materialIndices.append(1)
            }
        }
        return (indices, materialIndices)
    }

    fileprivate struct ConeVertices {
        var lowerEdge: [CompleteVertex]
        var upperEdge: [CompleteVertex]
        var lowerCap: [CompleteVertex]
        var combinedVerts: [CompleteVertex]?
        var indices: [UInt32]?
        var materialIndices: [UInt32]?

        mutating func calculateDetails(
            height: Float, sides: Int, splitFaces: Bool
        ) -> Bool {
            let halfHeight = height / 2
            var vertices = lowerEdge
            vertices.append(contentsOf: upperEdge)

            let lowerCenterIndex = UInt32(vertices.count)
            vertices.append(CompleteVertex(
                position: [0, -halfHeight, 0], normal: [0, -1, 0], uv: [0.5, 0.5]
            ))

            vertices.append(contentsOf: lowerCap)
            self.combinedVerts = vertices
            (self.indices, self.materialIndices) = coneIndices(
                sides, lowerCenterIndex, splitFaces
            )
            return true
        }
    }

    fileprivate static func coneVertices(
        _ sides: Int, _ radius: Float, _ height: Float
    ) -> ConeVertices {
        var theta: Float = 0
        let thetaInc = 2 * .pi / Float(sides)
        let uStep: Float = 1 / Float(sides)
        // first vertices added will be bottom edges
        var vertices = [CompleteVertex]()
        // all top edge vertices of the cylinder
        var upperEdgeVertices = [CompleteVertex]()
        // bottom edge vertices
        var lowerCapVertices = [CompleteVertex]()

        let hyp = sqrtf(radius * radius + height * height)
        let coneNormX = radius / hyp
        let coneNormY = height / hyp
        // create vertices for all sides of the cylinder
        for side in 0...sides {
            let cosTheta = cos(theta)
            let sinTheta = sin(theta)

            let lowerPosition: SIMD3<Float> = [radius * cosTheta, -height / 2, radius * sinTheta]
            let coneBottomNormal: SIMD3<Float> = [coneNormY * cosTheta, coneNormX, coneNormY * sinTheta]

            let bottomVertex = CompleteVertex(
                position: lowerPosition,
                normal: coneBottomNormal,
                uv: [uStep * Float(side), 0]
            )

            // add vertex for bottom side of cone
            vertices.append(bottomVertex)

            // add vertex for bottom side facing down
            lowerCapVertices.append(CompleteVertex(
                position: bottomVertex.position,
                normal: [0, -1, 0], uv: [cosTheta + 1, sinTheta + 1] / 2)
            )

            let coneTopNormal: SIMD3<Float> = [
                coneNormY * cos(theta + thetaInc / 2), coneNormX,
                coneNormY * sin(theta + thetaInc / 2)
            ]

            // add vertex for top of the cone
            let topVertex = CompleteVertex(
                position: [0, height / 2, 0],
                normal: coneTopNormal, uv: [0.5, 1]
            )
            upperEdgeVertices.append(topVertex)

            theta += thetaInc
        }
        return .init(
            lowerEdge: vertices, upperEdge: upperEdgeVertices, lowerCap: lowerCapVertices
        )
    }

    /// Creates a new cone mesh with the specified values 🍦
    /// - Parameters:
    ///   - radius: Radius of the code base
    ///   - height: Height of the code from base to tip
    ///   - sides: How many sides the cone should have, default is 24, minimum is 3
    ///   - splitFaces: A Boolean you set to true to indicate that vertices shouldn’t be merged.
    /// - Returns: A cone mesh
    public static func generateCone(
        radius: Float, height: Float, sides: Int = 24, splitFaces: Bool = false
    ) throws -> MeshResource {
        assert(sides > 2, "Sides must be an integer above 2")
        // first vertices added to vertices will be bottom edges
        // upperEdgeVertices are all top edge vertices of the cylinder
        // lowerCapVertices are the bottom edge vertices
        var coneVerties = coneVertices(sides, radius, height)
        if !coneVerties.calculateDetails(
            height: height, sides: sides, splitFaces: splitFaces
        ) {
            assertionFailure("Could not calculate cone")
        }
        let meshDescr = coneVerties.combinedVerts!.generateMeshDescriptor(
            with: coneVerties.indices!, materials: coneVerties.materialIndices!
        )
        return try MeshResource.generate(from: [meshDescr])
    }
}
