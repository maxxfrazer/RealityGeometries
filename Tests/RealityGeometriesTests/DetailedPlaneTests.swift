//
//  DetailedPlaneTests.swift
//
//
//  Created by Max Cobb on 29/10/2021.
//

import XCTest
@testable import RealityGeometries
import RealityFoundation

final class DetailedPlane_Tests: XCTestCase {
    func testPlaneGeometry() throws {
        guard let testSimpleMesh = try? MeshResource.generateDetailedPlane(width: 1, depth: 1, vertices: (2, 2)) else {
            XCTFail("Could not create detailed plane")
            return
        }
        let meshBounds = testSimpleMesh.bounds
        XCTAssertEqual(
            meshBounds.extents, [1, 0, 1],
            "Mesh bounds were incorrect")
    }
}
