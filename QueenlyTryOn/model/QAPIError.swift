//
//  QAPIError.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/9/24.
//

import Foundation

@objc
public class QAPIError: NSObject {
    
    let type: QAPIError.QAPIErrorType
    
    enum QAPIErrorType: String {
        case invalidAuthKey = "Invalid authentication key",
             unknown = "Unknown error"
    }
    
    init(type: QAPIError.QAPIErrorType) {
        self.type = type
    }
}
