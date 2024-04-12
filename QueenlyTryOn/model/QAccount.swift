//
//  QAccount.swift
//  QueenlyTryOn
//
//  Created by Mica Morales on 4/4/24.
//

import Foundation

struct QAccount: Codable {
    let accountId: String
    let accountName: String
    let companyUrlString: String
    let authKey: String
    let accountLogo: String
    
    var accountLogoUrl: URL? {
        return URL(string: accountLogo)
    }
    
    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case accountName = "account_name"
        case companyUrlString = "account_company_url"
        case authKey = "current_authentication_key"
        case accountLogo = "account_logo"
    }
    
    init() {
        accountId = ""
        accountName = ""
        companyUrlString = ""
        authKey = ""
        accountLogo = ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountId = try container.decodeIfPresent(String.self, forKey: .accountId) ?? ""
        accountName = try container.decodeIfPresent(String.self, forKey: .accountName) ?? "Queenly"
        companyUrlString = try container.decodeIfPresent(String.self, forKey: .companyUrlString) ?? ""
        authKey = try container.decodeIfPresent(String.self, forKey: .authKey) ?? ""
        accountLogo = try container.decodeIfPresent(String.self, forKey: .accountLogo) ?? ""
    }
    
}
