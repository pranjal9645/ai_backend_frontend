//
//  TokenStore.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation
import Security

final class TokenStore
{
    static let shared = TokenStore()
    
    private let service =  "com.aiknowledgeplatform.auth"
    private let account = "accessToken"
    
    private init(){}
    
    func save(token : String) throws
    {
        let data = Data(token.utf8)
        
        let query : [String : Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String : service,
            kSecAttrAccount as String : account
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let attributes : [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
       let status = SecItemAdd(attributes as CFDictionary, nil)
        
        guard status == errSecSuccess else
        {
            throw TokenStoreError.saveFailed(status)
        }
    }
    
    func readToken() -> String?
    {
        let query: [String: Any] = [
                  kSecClass as String: kSecClassGenericPassword,
                  kSecAttrService as String: service,
                  kSecAttrAccount as String: account,
                  kSecReturnData as String: true,
                  kSecMatchLimit as String: kSecMatchLimitOne
              ]
        
        var result : AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess , let data = result as? Data else
        {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func deleteToken()
    {
        let query: [String: Any] = [
                  kSecClass as String: kSecClassGenericPassword,
                  kSecAttrService as String: service,
                  kSecAttrAccount as String: account
              ]
              
        SecItemDelete(query as CFDictionary)
    }
}

 enum TokenStoreError : Error
{
    case saveFailed(OSStatus)
}
