//
//  TransactionsService.swift
//  lms
//
//  Created by Ivan Isaev on 11.06.2025.
//

import Foundation

protocol TransactionsServiceProtocol {
    func getTransactions(for direction: Direction, in period: DateInterval) async -> [Transaction]
    func create(transaction: Transaction) async throws
    func update(transaction: Transaction) async throws
    func delete(withId id: Int) async throws
}

final class TransactionsService: TransactionsServiceProtocol {
    private let networkClient: NetworkClient
    private var cache = TransactionsFileCache()
    private let cacheName = "defaultTransactionCache"
    
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
        cache.load(from: cacheName)
    }
    
    func getTransactions(for direction: Direction, in period: DateInterval) async -> [Transaction] {
        let formatter = ISO8601DateFormatter()
        let from = formatter.string(from: period.start)
        let to = formatter.string(from: period.end)
        let queryItems = [
            URLQueryItem(name: "direction", value: direction.rawValue),
            URLQueryItem(name: "from", value: from),
            URLQueryItem(name: "to", value: to)
        ]
        struct Empty: Encodable {}
        do {
            let transactions: [Transaction] = try await networkClient.request(
                path: "/api/transactions",
                method: "GET",
                requestBody: Optional<Empty>.none,
                queryItems: queryItems
            )
            cache.transactions = transactions
            cache.save(to: cacheName)
            return transactions.filter {
                $0.category.direction == direction && period.contains($0.transactionDate)
            }
        } catch {
            // В случае ошибки возвращаем кэшированные данные
            return cache.transactions.filter {
                $0.category.direction == direction && period.contains($0.transactionDate)
            }
        }
    }
    
    func create(transaction: Transaction) async throws {
        let created: Transaction = try await networkClient.request(
            path: "/api/transactions",
            method: "POST",
            requestBody: transaction,
            queryItems: nil
        )
        cache.insert(created)
        cache.save(to: cacheName)
    }
    
    func update(transaction: Transaction) async throws {
        let updated: Transaction = try await networkClient.request(
            path: "/api/transactions/\(transaction.id)",
            method: "PUT",
            requestBody: transaction,
            queryItems: nil
        )
        cache.insert(updated)
        cache.save(to: cacheName)
    }
    
    func delete(withId id: Int) async throws {
        struct Empty: Encodable {}
        _ = try await networkClient.request(
            path: "/api/transactions/\(id)",
            method: "DELETE",
            requestBody: Optional<Empty>.none,
            queryItems: nil
        ) as Transaction
        cache.remove(withId: id)
        cache.save(to: cacheName)
    }
}
