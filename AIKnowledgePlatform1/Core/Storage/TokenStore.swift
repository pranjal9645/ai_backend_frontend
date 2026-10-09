//
//  TokenStore.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation
import Security

nonisolated
final class TokenStore : Sendable
{
    static let shared = TokenStore()
    
    private let service =  "com.aiknowledgeplatform.auth"
    private let accessTokenAccount = "accessToken"
    private let refreshTokenAccount = "refreshToken"
    
    
    private init(){}
    
    private func save(token : String , account : String) throws
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
    
    private func readToken(account : String) -> String?
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
    
    func deleteAllTokens()
    {
        let accounts = [
            accessTokenAccount , refreshTokenAccount
        ]
        
        for account in accounts {
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            
            SecItemDelete(query as CFDictionary)
        }
    }
    
    func saveAccessToken(_ token : String) throws
    {
        try save(token: token , account : accessTokenAccount)
    }
    
    func readAccessToken() -> String?
    {
        return readToken(account : accessTokenAccount)
    }
    
    func saveRefreshToken(_ token : String) throws
    {
        try save(token: token, account: refreshTokenAccount)
    }
    
    func readRefreshToken() -> String?
    {
        readToken(account: refreshTokenAccount)
    }
}

 enum TokenStoreError : Error
{
    case saveFailed(OSStatus)
}
