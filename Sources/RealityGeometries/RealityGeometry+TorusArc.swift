//
//  RealityGeometry+TorusArc.swift
//
//
//  Created by Shawn Coumbe on 12/03/2023.
//  Based on code by Max Cobb

import RealityKit

extension RealityGeometry {
    /// Create a new torus MeshResource 🍩
    /// - Parameters:
    ///   - sides: Number of segments in the toroidal direction (outer edge of the torus).
    ///   - csSides: Number of segments in the poloidal direction (segments in the tube)
    ///   - radius: Distance from the centre of the torus to the centre of the tube.
    ///   - csRadius: Radius of the tube.
    /// - Returns: A new torus `MeshResource`
    public static func generateTorusArc(
        startAngle: Int, endAngle: Int, allSides:Int , csSides: Int, radius: Float, csRadius: Float, isCapped: Bool = false, splitFaces: Bool = false
    ) throws -> MeshResource {
        let deltaDegrees = endAngle - startAngle
        let dtoR = Float.pi / 180.0
        let startRadians = Float(startAngle) * dtoR
        let endRadians = Float(endAngle) * dtoR
        let sides = (deltaDegrees * allSides) / 360
        
        let allVertices = addTorusVertices(radius, csRadius, startAngle, endAngle, allSides, csSides, isCapped)
        
        var indices: [UInt32] = []
        var materials: [UInt32] = []
        var i = 0
        let rowCount = sides + 1
        while i < csSides {
            var j = 0
            while j < sides {
                /*
                 1
                 |\
                 | \
                 2--3
                 */
                indices.append(UInt32(i * rowCount + j))
                indices.append(UInt32(i * rowCount + j + 1))
                indices.append(UInt32((i + 1) * rowCount + j + 1))
                /*
                 3--2
                  \ |
                   \|
                    1
                 */
                indices.append(UInt32((i + 1) * rowCount + j + 1))
                indices.append(UInt32((i + 1) * rowCount + j))
                indices.append(UInt32(i * rowCount + j))
                j += 1
                
                if splitFaces {
                    materials.append(0)
                    materials.append(0)
                }
            }
            i += 1
        }

        // Enclose the arc
        if isCapped {
            // Add the end face.
            let finalCenter = allVertices.count - 1
            i = 0
            while i < csSides {
                let v1 = UInt32(i * rowCount + (rowCount - 1))
                let v2 = UInt32((i + 1) * rowCount + (rowCount - 1))
                let v3 = UInt32(finalCenter)
                indices.append(v3)
                indices.append(v2)
                indices.append(v1)
                
                if splitFaces {
                    materials.append(2)
                }
                
                i += 1
            }
            
            // add the start face.
            let firstCenter = allVertices.count - 2
            i = 0
            while i < csSides {
                let v1 = UInt32(i * rowCount)
                let v2 = UInt32((i + 1) * rowCount)
                let v3 = UInt32(firstCenter)
                indices.append(v1)
                indices.append(v2)
                indices.append(v3)
                if splitFaces {
                    materials.append(1)
                }
                
                i += 1
            }
        }

        let meshDesc = allVertices.generateMeshDescriptor(with: indices, materials: materials)
        return try .generate(from: [meshDesc])
    }

    fileprivate static func addTorusVertices(
        _ radius: Float, _ csRadius: Float, _ startAngle: Int, _ endAngle: Int, _ allSides:Int , _ csSides: Int, _ isCapped: Bool
    ) -> [CompleteVertex] {
        let deltaDegrees = endAngle - startAngle
        let dtoR = Float.pi / 180.0
        let startRadians = Float(startAngle) * dtoR
        let endRadians = Float(endAngle) * dtoR
        let sides = (deltaDegrees * allSides) / 360
        
        let angleIncs = 360 / Float(allSides)
        let csAngleIncs = 360 / Float(csSides)
        var allVertices: [CompleteVertex] = []
        var currentradius: Float
        var jAngle: Float = 0
        var iAngle: Float = 0
        let dToR: Float = .pi / 180
        var zval: Float
        while jAngle <= 360 {
            currentradius = radius + (csRadius * cosf(jAngle * dToR))
            zval = csRadius * sinf(jAngle * dToR)
            let baseNorm: SIMD3<Float> = [cosf(jAngle * dToR), 0, sinf(jAngle * dToR)]
            iAngle = Float(startAngle)
            while iAngle <= Float(endAngle) {
                // Ensure that the last point ends at exactly the requested angle
                if iAngle + angleIncs > Float(endAngle) {
                    iAngle = Float(endAngle)
                }
                let normVal = simd_quatf(angle: iAngle * dToR, axis: [0, 0, 1]).act(baseNorm)
                let vertexPos: SIMD3<Float> = [
                    currentradius * cosf(iAngle * dToR),
                    currentradius * sinf(iAngle * dToR),
                    zval
                ]
                var uv: SIMD2<Float> = [1 - iAngle / 360, 2 * jAngle / 360 - 1]
                if uv.y < 0 { uv.y *= -1 }
                allVertices.append(CompleteVertex(position: vertexPos, normal: normVal, uv: uv))
                iAngle += angleIncs
            }
            jAngle += csAngleIncs
        }
        
        if isCapped {
            let uv: SIMD2<Float> = [0.5, 0.5]
            let normValStart: SIMD3<Float> = [ 1 / cos(startRadians), 1 / sin(startRadians), 0 ]
            let vertexPosStart: SIMD3<Float> = [
                radius * cosf(startRadians),
                radius * sinf(startRadians),
                0
            ]
            allVertices.append(CompleteVertex(position: vertexPosStart, normal: normValStart, uv: uv))
            
            let normValEnd: SIMD3<Float> = [ 1 / cos(endRadians), 1 / sin(endRadians), 0 ]
            let vertexPosEnd: SIMD3<Float> = [
                radius * cosf(endRadians),
                radius * sinf(endRadians),
                0
            ]
            allVertices.append(CompleteVertex(position: vertexPosEnd, normal: normValEnd, uv: uv))
        }
        
        return allVertices
    }
}
