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
    
    
}
