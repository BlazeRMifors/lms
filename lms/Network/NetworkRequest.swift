//
//  Request.swift
//  lms
//
//  Created by Ivan Isaev on 17.07.2025.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequest {
    var url: URL { get }
    var httpMethod: HTTPMethod { get }
    var payload: Encodable? { get }
}

enum Request: NetworkRequest {
    case get(url: URL)
    case post(url: URL, body: Encodable?)
    case put(url: URL, body: Encodable?)
    case delete(url: URL)

    var url: URL {
        switch self {
        case .get(let url): return url
        case .post(let url, _): return url
        case .put(let url, _): return url
        case .delete(let url): return url
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .delete: return .delete
        }
    }
    
    var payload: Encodable? {
        switch self {
        case .get: return nil
        case .post(_, let body): return body
        case .put(_, let body): return body
        case .delete: return nil
        }
    }
} 
