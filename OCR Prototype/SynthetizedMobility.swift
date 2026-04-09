//
//  SynthetizedMobility.swift
//  OCR Prototype
//
//  Created by Mathieu Dubart on 26/03/2026.
//

import Foundation

struct SynthetizedMobility: Identifiable {
    let id = UUID()
    let text: String
    let boundingBox: CGRect
}
