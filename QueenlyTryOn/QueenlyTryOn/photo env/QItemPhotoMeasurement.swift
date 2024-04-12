//
//  QItemPhotoMeasurement.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/10/24.
//

import Foundation

struct QItemPhotoMeasurement: Codable {
    let width: CGFloat
    let height: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case width,
             height,
             x,
             y
    }
    
    init() {
        width = .zero
        height = .zero
        x = .zero
        y = .zero
    }
    
    init(width: CGFloat, 
         height: CGFloat,
         x: CGFloat,
         y: CGFloat) {
        self.width = width
        self.height = height
        self.x = x
        self.y = y
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(CGFloat.self, forKey: .width) ?? .zero
        height = try container.decodeIfPresent(CGFloat.self, forKey: .height) ?? .zero
        x = try container.decodeIfPresent(CGFloat.self, forKey: .x) ?? .zero
        y = try container.decodeIfPresent(CGFloat.self, forKey: .y) ?? .zero
        
    }
}
