//
//  MeshResource+Torus.swift
//  
//
//  Created by Max Cobb on 25/10/2021.
//

import RealityKit

extension MeshResource {
    /// Create a new torus MeshResource 🍩
    /// - Parameters:
    ///   - sides: Number of segments in the toroidal direction (outer edge of the torus).
    ///   - csSides: Number of segments in the poloidal direction (segments in the tube)
    ///   - radius: Distance from the centre of the torus to the centre of the tube.
    ///   - csRadius: Radius of the tube.
    /// - Returns: A new torus `MeshResource`
    public static func generateTorus(
        sides: Int, csSides: Int, radius: Float, csRadius: Float
    ) throws -> MeshResource {
//        var numVertices = (sides+1) * (csSides+1)
//        var numIndices = (2*sides+4) * csSides

        let angleIncs = 360/Float(sides)
        let csAngleIncs = 360/Float(csSides)
        var currentradius: Float
        var zval: Float

        var allVertices: [CompleteVertex] = []
        var indices: [UInt32] = []
        var jAngle: Float = 0
        var iAngle: Float = 0
        let dToR: Float = .pi / 180
        while (jAngle <= 360) {
            currentradius = radius + (csRadius * cosf(jAngle * dToR))
            zval = csRadius * sinf(jAngle * dToR)
            let baseNorm: SIMD3<Float> = [cosf(jAngle * dToR), 0, sinf(jAngle * dToR)]
            iAngle = 0
            while (iAngle <= 360) {
                let normVal = simd_quatf(angle: iAngle * dToR, axis: [0, 0, 1]).act(baseNorm)
                let vertexPos: SIMD3<Float> = [
                    currentradius * cosf(iAngle * dToR),
                    currentradius * sinf(iAngle * dToR),
                    zval
                ]
                var uv: SIMD2<Float> = [iAngle / 360, 2 * jAngle / 360 - 1]
                if uv.y < 0 { uv.y *= -1 }
                allVertices.append(CompleteVertex(position: vertexPos, normal: normVal, uv: uv))
                if jAngle == 0 {
                    print(vertexPos)
                }
                iAngle += angleIncs
            }
            jAngle += csAngleIncs
        }

        /* inner ring */
        var i = 0
        let rowCount = sides + 1
        while (i < csSides)
        {
            var j = 0
            /* outer ring */
            while (j < sides)
            {
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
            }
            i += 1
        }

        let meshDesc = allVertices.generateMeshDescriptor(with: indices)
        return try .generate(from: [meshDesc])
    }
}
