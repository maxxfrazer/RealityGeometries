import XCTest
@testable import RealityGeometries
import RealityFoundation

final class RealityGeometriesTests: XCTestCase {
    func testPlaneGeometry() throws {
        guard let testSimpleMesh = try? MeshResource.generateDetailedPlane(width: 1, depth: 1, vertices: (2, 2)) else {
            XCTFail("Could not create simple mesh")
            return
        }
        let meshBounds = testSimpleMesh.bounds
        XCTAssert(meshBounds.extents == [1, 0, 1], "Mesh bounds were incorrect")
    }
}
