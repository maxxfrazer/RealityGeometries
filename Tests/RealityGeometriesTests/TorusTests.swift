//
//  TorusTests.swift
//  
//
//  Created by Max Cobb on 29/10/2021.
//

import XCTest
@testable import RealityGeometries
import RealityFoundation

final class Torus_Tests: XCTestCase {
    func testTorusGeometry() throws {
        guard let testSimpleMesh = try? RealityGeometry.generateTorus(
            sides: 32, csSides: 32, radius: 1, csRadius: 0.1
        ) else {
            XCTFail("Could not create simple mesh")
            return
        }
        let meshBounds = testSimpleMesh.bounds
        XCTAssert(
            meshBounds.extents == [2.2, 2.2, 0.2],
            "Mesh bounds were incorrect, returned \(meshBounds.extents)"
        )
    }
}
