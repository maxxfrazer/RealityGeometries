//
//  ContentView.swift
//  RealityGeometries+Example
//
//  Created by Max Cobb on 18/10/2021.
//

import SwiftUI
import ARKit
import RealityKit
import RealityGeometries
#if canImport(FocusEntity)
import FocusEntity
#endif

extension ForEach where Data.Element: Hashable, ID == Data.Element, Content: View {
    init(values: Data, content: @escaping (Data.Element) -> Content) {
        self.init(values, id: \.self, content: content)
    }
}

struct ContentView: View {
    enum Shape: String, Equatable, CaseIterable {
        case cone
        case cylinder
        case torus
        case path
        case tube
        case all
    }
    @State private var selection: Shape?
    func updateShape(sender: Any? = nil) {
        // update value for voicemod
        let shapeAnchor = ARViewContainer.shared.arView.scene
            .findEntity(named: "shapeAnchor")
        shapeAnchor?.children.forEach { $0.removeFromParent() }
        var simpleMat = SimpleMaterial(color: .cyan, isMetallic: false)
        if let pathTex = try? TextureResource.load(named: "uv-checker") {
            simpleMat.color = .init(
                tint: .white.withAlphaComponent(0.999),
                texture: MaterialParameters.Texture(pathTex)
            )
        }
        var newMesh: MeshResource
        switch selection {
        case .tube:
            let points: [SIMD3<Float>] = [
                [-0.2, 0, 0],
                [0, 0, 0],
                [0.2, 0.2, 0],
                [0.4, 0.2, 0],
                [0.4, 0.8, 0]
            ]
            newMesh = try! RealityGeometry.generateTube(points: points, radius: 0.025)
        case .torus:
            newMesh = try! RealityGeometry.generateTorus(sides: 128, csSides: 32, radius: 0.3, csRadius: 0.03)
        case .cone:
            newMesh = try! RealityGeometry.generateCone(radius: 0.25, height: 0.5, sides: 64)
        case .cylinder:
            newMesh = try! RealityGeometry.generateCylinder(radius: 0.25, height: 0.5, sides: 64)
        case .path:
            newMesh = try! MeshResource.generate(from: [])
        case .all:
            let newShape = Entity()
            newShape.scale = .init(repeating: 2)
            newShape.name = "currentGeometry"

            let modelTorus = ModelEntity(mesh: try! RealityGeometry.generateTorus(sides: 64, csSides: 64, radius: 0.3, csRadius: 0.1), materials: [simpleMat])
            modelTorus.position.x = -1
            newShape.addChild(modelTorus)
            let modelCone = ModelEntity(mesh: try! RealityGeometry.generateCone(radius: 0.25, height: 0.5, sides: 64), materials: [simpleMat])
            modelCone.position.x = 0
            newShape.addChild(modelCone)
            let modelCylinder = ModelEntity(mesh: try! RealityGeometry.generateCylinder(radius: 0.25, height: 0.5, sides: 64), materials: [simpleMat])
            modelCylinder.position.x = 1
            newShape.addChild(modelCylinder)
            shapeAnchor?.addChild(newShape)
            shapeAnchor?.orientation = simd_quatf(angle: .pi / 6, axis: [1, 0, 0])
            return
        case .none:
            return
        }
        #if canImport(FocusEntity)
        ARViewContainer.shared.focusEnabled = selection == .path
        #endif
        let newShape = ModelEntity(mesh: newMesh, materials: [simpleMat])
        newShape.scale = .init(repeating: 4)
        newShape.name = "currentGeometry"
        shapeAnchor?.addChild(newShape)
    }
    var body: some View {
        ZStack {
            ARViewContainer.shared.edgesIgnoringSafeArea(.all).onTapGesture {
                ARViewContainer.shared.didTap()
            }
            VStack {
                HStack {
                    Spacer()
                    Menu {
                        ForEach(values: Shape.allCases) { shape in
                            Button {
                                selection = shape
                            } label: {
                                Text(shape.rawValue)
                            }
                        }
                    } label: {
                        Text(selection?.rawValue ?? "Select a Shape")
                    }.padding(6).background(Color.black).cornerRadius(3.0)
                        .onChange(of: selection, perform: self.updateShape)
                        .onAppear { self.updateShape() }

                    Spacer()
                }
                Spacer()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    var arView = ARView(frame: .zero)
    static var shared = ARViewContainer()
    var pathPoints: [SIMD3<Float>] = [] {
        didSet {
            let currentPath = self.arView.scene.findEntity(named: "currentGeometry") as? HasModel
            if let newPath = try? RealityGeometry.generatePath(pathPoints, pathProperties: .init(curvePoints: 32)).mesh {
                currentPath?.model?.mesh = newPath
            }
        }
    }
    #if canImport(FocusEntity)
    var focusEnabled: Bool = false {
        didSet {
            focusEntity?.isEnabled = focusEnabled
            if !focusEnabled { pathPoints.removeAll() }
        }
    }
    var focusEntity: FocusEntity? {
        arView.scene.findEntity(named: "FocusEntity") as? FocusEntity
    }
    #endif
    mutating func didTap() {
        #if canImport(FocusEntity)
        if focusEnabled, let focus = focusEntity {
            switch focus.state {
            case .initializing:
                break
            case .tracking(let raycastResult, _):
                let newpoint = Transform(matrix: raycastResult.worldTransform).translation + [0, 0, 1]
                pathPoints.append(newpoint)
            }
        }
        #endif
    }
    func makeUIView(context: Context) -> ARView {

        let arView = arView
        let arConfig = ARWorldTrackingConfiguration()
        arView.debugOptions = [.showPhysics]
        arConfig.planeDetection = [.horizontal]
        arView.session.run(arConfig, options: [])
        #if canImport(FocusEntity)
        let focusEnt = FocusEntity(on: arView, focus: .classic)
        focusEnt.isEnabled = focusEnabled
        #endif
        let anchor = AnchorEntity(world: [0, -1, -0.25])
        anchor.name = "shapeAnchor"
        arView.scene.addAnchor(anchor)
        let camAnchor = AnchorEntity(.camera)
        let newLight = PointLight()
        camAnchor.addChild(newLight)
        arView.scene.addAnchor(camAnchor)
        return arView

    }

    func updateUIView(_ uiView: ARView, context: Context) {
        #if canImport(FocusEntity)
        focusEntity?.isEnabled = focusEnabled
        #endif
    }

}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
