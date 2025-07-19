//
//  ApiEndpoints.swift
//  lms
//
//  Created by Ivan Isaev on 17.07.2025.
//

import Foundation

struct ApiEndpoints {
    static let baseURL = URL(string: "https://shmr-finance.ru/api/v1")!
    
    static var categories: URL {
        baseURL.appendingPathComponent("categories")
    }
    
    static var accounts: URL {
        baseURL.appendingPathComponent("accounts")
    }
    
    static func account(id: Int) -> URL {
        baseURL.appendingPathComponent("accounts/\(id)")
    }
    
    static var transactions: URL {
        baseURL.appendingPathComponent("transactions")
    }
    
    static func transaction(id: Int) -> URL {
        baseURL.appendingPathComponent("transactions/\(id)")
    }
    
    static func transactionsForAccount(accountId: Int, startDate: Date, endDate: Date) -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        var components = URLComponents(url: baseURL.appendingPathComponent("transactions/account/\(accountId)/period"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "startDate", value: startDateString),
            URLQueryItem(name: "endDate", value: endDateString)
        ]
        return components.url!
    }
}
