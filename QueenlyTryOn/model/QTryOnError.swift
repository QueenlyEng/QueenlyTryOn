//
//  QTryOnError.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/1/24.
//

import Foundation

@objc
public class QTryOnError: NSObject {
    
    let type: QTryOnError.QTryOnErrorType
    
    enum QTryOnErrorType: String {
        case unsupportedDevice = "Unsupported device",
             cameraAccessDenied = "Camera access denied",
             photoAccessDenied = "Photo access denied"
    }
    
    init(type: QTryOnError.QTryOnErrorType) {
        self.type = type
    }
}
