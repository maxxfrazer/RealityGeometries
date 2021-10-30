//
//  File.swift
//  
//
//  Created by Max Cobb on 30/10/2021.
//

import XCTest
@testable import RealityGeometries
import RealityFoundation

final class Path_Tests: XCTestCase {
    func testPathGeometry() throws {
        guard let (testSimpleMesh, pathLen) = try? MeshResource.generatePath(
            [.zero, [0, 0, 1], [1, 0, 1]],
            pathProperties: MeshResource.PathProperties(width: 1, curvePoints: 0)),
            let pathMesh = testSimpleMesh
        else {
            XCTFail("Could not create simple mesh")
            return
        }
        let meshBounds = pathMesh.bounds
        XCTAssertEqual(
            meshBounds.extents, [1.5, 0, 1.5],
            "Mesh bounds were incorrect"
        )
        XCTAssertEqual(
            pathLen, 2,
            "Mesh length is incorrect"
        )
    }
}
