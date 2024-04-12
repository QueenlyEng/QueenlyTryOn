//
//  QItemARMeasurement.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/10/24.
//

import Foundation

struct QItemARMeasurement: Codable {
    let width: CGFloat
    let height: CGFloat
    let itemRefJointName: String
    let itemYRefOffset: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case width,
             height,
             itemRefJointName = "item_ref_joint_name",
             itemYRefOffset = "item_y_ref_offset"
    }
    
    init() {
        width = .zero
        height = .zero
        itemRefJointName = ""
        itemYRefOffset = .zero
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        width = try container.decodeIfPresent(CGFloat.self, forKey: .width) ?? .zero
        height = try container.decodeIfPresent(CGFloat.self, forKey: .height) ?? .zero
        itemRefJointName = try container.decodeIfPresent(String.self, forKey: .itemRefJointName) ?? ""
        itemYRefOffset = try container.decodeIfPresent(CGFloat.self, forKey: .itemYRefOffset) ?? .zero
        
    }
}
