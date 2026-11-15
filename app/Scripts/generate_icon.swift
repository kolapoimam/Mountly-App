#!/usr/bin/env swift
// Generates an original 1024x1024 app icon for Mountly: a colorful
// blue-to-purple tile with a drive silhouette and a downward "mount" chevron
// merging into it — evoking a drive becoming accessible, not any specific
// manufacturer's branding.
import AppKit
import CoreGraphics

let size = 1024
let rect = CGRect(x: 0, y: 0, width: size, height: size)

guard let ctx = CGContext(
    data: nil, width: size, height: size,
    bitsPerComponent: 8, bytesPerRow: 0,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else { fatalError("no context") }

let bgPath = CGPath(roundedRect: rect, cornerWidth: 224, cornerHeight: 224, transform: nil)
ctx.addPath(bgPath)
ctx.clip()

// Colorful blue -> purple diagonal gradient background.
let bgColors = [
    CGColor(red: 0.16, green: 0.49, blue: 0.98, alpha: 1),
    CGColor(red: 0.47, green: 0.32, blue: 0.90, alpha: 1)
]
let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors as CFArray, locations: [0, 1])!
ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])
ctx.resetClip()

// Drive silhouette.
let driveWidth: CGFloat = 600
let driveHeight: CGFloat = 340
let driveRect = CGRect(x: (CGFloat(size) - driveWidth) / 2, y: 210, width: driveWidth, height: driveHeight)
let drivePath = CGPath(roundedRect: driveRect, cornerWidth: 60, cornerHeight: 60, transform: nil)

ctx.setShadow(offset: CGSize(width: 0, height: -16), blur: 36, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.28))
ctx.addPath(drivePath)
ctx.setFillColor(CGColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1))
ctx.fillPath()
ctx.setShadow(offset: .zero, blur: 0, color: nil)

// Top ridge line.
let ridgeRect = CGRect(x: driveRect.minX + 46, y: driveRect.maxY - 62, width: driveRect.width - 92, height: 12)
ctx.addPath(CGPath(roundedRect: ridgeRect, cornerWidth: 6, cornerHeight: 6, transform: nil))
ctx.setFillColor(CGColor(red: 0.80, green: 0.83, blue: 0.90, alpha: 1))
ctx.fillPath()

// "Mount" chevron: a rounded downward arrow merging into the drive's top
// edge, in a bright accent color — the core visual metaphor (data/access
// descending onto the drive; "made accessible").
let chevronCenterX = rect.midX
let chevronTopY: CGFloat = 620
let chevronWidth: CGFloat = 220
let chevronStroke: CGFloat = 54

let chevron = CGMutablePath()
chevron.move(to: CGPoint(x: chevronCenterX - chevronWidth / 2, y: chevronTopY))
chevron.addLine(to: CGPoint(x: chevronCenterX, y: chevronTopY - 150))
chevron.addLine(to: CGPoint(x: chevronCenterX + chevronWidth / 2, y: chevronTopY))

ctx.setLineWidth(chevronStroke)
ctx.setLineCap(.round)
ctx.setLineJoin(.round)
ctx.setStrokeColor(CGColor(red: 0.20, green: 0.87, blue: 0.65, alpha: 1))
ctx.addPath(chevron)
ctx.strokePath()

// A short stem continuing the chevron down into the drive body, so the
// arrow visually "plugs into" the drive rather than floating above it.
let stemRect = CGRect(x: chevronCenterX - chevronStroke / 2, y: driveRect.maxY - 40, width: chevronStroke, height: 110)
ctx.setFillColor(CGColor(red: 0.20, green: 0.87, blue: 0.65, alpha: 1))
ctx.fill(stemRect)

// Small "verified/connected" dot, bottom-right of the drive.
let dotRadius: CGFloat = 24
let dotRect = CGRect(x: driveRect.maxX - 78, y: driveRect.minY + 36, width: dotRadius * 2, height: dotRadius * 2)
ctx.setFillColor(CGColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1))
ctx.fillEllipse(in: dotRect)

guard let image = ctx.makeImage() else { fatalError("no image") }
let rep = NSBitmapImageRep(cgImage: image)
guard let data = rep.representation(using: .png, properties: [:]) else { fatalError("no png data") }

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon-1024.png"
try! data.write(to: URL(fileURLWithPath: outputPath))
print("wrote \(outputPath)")
