//
//  ApiEndpoints.swift
//  lms
//
//  Created by Ivan Isaev on 17.07.2025.
//

import Foundation

struct ApiEndpoints {
    static let baseURL = URL(string: "https://shmr-finance.ru")!
    
    static var transactionsURL: URL {
        baseURL.appendingPathComponent("/api/transactions")
    }
    
    static func transactionURL(id: Int) -> URL {
        baseURL.appendingPathComponent("/api/transactions/\(id)")
    }
    
    static var accountURL: URL {
        baseURL.appendingPathComponent("/api/account")
    }

    static var categoriesURL: URL {
        baseURL.appendingPathComponent("/api/categories")
    }
} 
