//
//  QueenlyItemModel.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/3/24.
//

import UIKit

struct QItem: Codable {
    let productId: String
    let fullImageSignature: String
    let fullTryOnImageSignature: String
    let hemline: String
    let neckline: String
    let sleeveLength: String
    let waistPosition: String
    let styleTags: [String]
    
    var tryOnImage: UIImage?
    var tryOnImageUrl: URL? {
        return URL(string: "\(fullTryOnImageSignature)?p")
    }
    
    enum CodingKeys: String, CodingKey {
        case hemline, neckline
        case productId = "product_id"
        case fullImageSignature = "full_image_signature"
        case fullTryOnImageSignature = "full_try_on_signature"
        case sleeveLength = "sleeve_length"
        case waistPosition = "waist_position"
        case styleTags = "style_category_tags"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try container.decodeIfPresent(String.self, forKey: .productId) ?? ""
        fullImageSignature = try container.decodeIfPresent(String.self, forKey: .fullImageSignature) ?? ""
        fullTryOnImageSignature = try container.decodeIfPresent(String.self, forKey: .fullTryOnImageSignature) ?? ""
        hemline = try container.decodeIfPresent(String.self, forKey: .hemline) ?? ""
        neckline = try container.decodeIfPresent(String.self, forKey: .neckline) ?? ""
        sleeveLength = try container.decodeIfPresent(String.self, forKey: .sleeveLength) ?? ""
        waistPosition = try container.decodeIfPresent(String.self, forKey: .waistPosition) ?? ""
        styleTags = try container.decodeIfPresent([String].self, forKey: .styleTags) ?? []
    }
    
    func styleTagsToEncodedJSON() -> String {
        if let jsonData = try? JSONSerialization.data(withJSONObject: styleTags, options: []) {
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            let encodedJSONString = jsonString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return encodedJSONString
        }
        return styleTags.joined(separator: ",").replacingOccurrences(of: " ", with: "%20")
    }
}
