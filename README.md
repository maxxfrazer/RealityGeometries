# RealityGeometries

> Add more geometries to your RealityKit projects

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20macCatalyst-lightgrey"/>
  <img src="https://img.shields.io/github/v/release/maxxfrazer/RealityGeometries?color=orange&label=SwiftPM&logo=swift"/>
  <img src="https://img.shields.io/badge/Swift-5.5-orange?logo=swift"/>
  <img src="https://github.com/maxxfrazer/RealityGeometries/workflows/swiftlint/badge.svg"/>
  <img src="https://github.com/maxxfrazer/RealityGeometries/workflows/build/badge.svg"/>
  <img src="https://img.shields.io/github/license/maxxfrazer/RealityGeometries"/>
</p>

By default, the only shapes available in RealityKit are a Sphere, Cuboid and Plane (with 4 vertices). Until iOS 15 the only clean way to include more geometries in your project is to load them from a USDZ file, which could unnecessarily increase the size of your app, especially when the shape you want to add is a basic one such as a cylinder or cone.

<p align="center">
  <img src="media/Cylinder_Cone_Normals.gif"/>
</p>

RealityGeometries is a solution to increase the basic mesh offering from RealityKit.

## Included in RealityGeometries
- Cylinder
- Cone
- Plane (with more vertices)
- Path
- Torus

This repository is open to pull requests as well as feature requests.

## More Images

<p align="center">
  <img src="media/Torus_Cone_Cylinder_above.png"/>
  <img src="media/Torus_Cone_Cylinder_below.png"/>
</p>