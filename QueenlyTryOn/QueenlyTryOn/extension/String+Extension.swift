//
//  String+Extension.swift
//  QueenlyTryOnTestApp
//
//  Created by Mica Morales on 4/10/24.
//

import Foundation

extension String {
    func getUrlQueryFormattedString() -> String {
        var formattedString = self//replacingOccurrences(of: " ", with: "%20")
        if let formatted = formattedString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            formattedString = formatted
        }
        formattedString = formattedString.replacingOccurrences(of: "&", with: "%26")
        return formattedString
    }
}
