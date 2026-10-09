//
//  APIRequest.swift
//  AIKnowledgePlatform1
//
//  Created by Pranjal Singh on 04/10/26.
//

import Foundation

struct APIRequest
{
    let path : String
    let method : HTTPMethod
    let body : Data?
    let headers : [String : String]
    let authenticationPolicy : AuthenticationPolicy
    let unauthorizedRetryPolicy : UnauthorizedRetryPolicy
    
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case PATCH
        case DELETE
    }
    
    enum AuthenticationPolicy {
        
        case none
        case optional
        case required
    }
    
    enum UnauthorizedRetryPolicy {
        
        case never
        case  refreshAccessTokenOnce
    }
   
    init(path: String, method: HTTPMethod = .GET, body: Data? = nil , headers: [String : String] = [:] ,  authenticationPolicy: AuthenticationPolicy, unauthorizedRetryPolicy: UnauthorizedRetryPolicy) {
        self.path = path
        self.method = method
        self.body = body
        self.headers = headers
        self.authenticationPolicy = authenticationPolicy
        self.unauthorizedRetryPolicy = unauthorizedRetryPolicy 
    }
}
