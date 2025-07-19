//
//  TransactionsAPI.swift
//  lms
//
//  Created by Ivan Isaev on 18.07.2025.
//

import Foundation

protocol TransactionsAPIProtocol {
    func createTransaction(accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?) async throws -> Transaction
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction
    func deleteTransaction(id: Int) async throws
    func getTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction]
}

final class TransactionsAPI: TransactionsAPIProtocol {
    private let networkClient: NetworkClient
    
    init(client: NetworkClient) {
        self.networkClient = client
    }
    
    private let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    func createTransaction(accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?) async throws -> Transaction {
        let amountString = String(format: "%.2f", NSDecimalNumber(decimal: amount).doubleValue)
        let dto = TransactionCreateDTO(
            accountId: accountId,
            categoryId: categoryId,
            amount: amountString,
            transactionDate: iso8601Formatter.string(from: transactionDate),
            comment: comment ?? ""
        )
        let request = Request.post(url: ApiEndpoints.transactions, body: dto)
        let response: TransactionResponseDTO = try await networkClient.send(request)
        guard let transaction = response.toDomain() else {
            throw NetworkError.decodingError(NSError(domain: "TransactionsAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка создания транзакции"]))
        }
        return transaction
    }
    
    func updateTransaction(_ transaction: Transaction) async throws -> Transaction {
        let dto = TransactionUpdateDTO.from(transaction)
        let request = Request.put(url: ApiEndpoints.transaction(id: transaction.id), body: dto)
        let response: TransactionResponseDTO = try await networkClient.send(request)
        guard let updated = response.toDomain() else {
            throw NetworkError.decodingError(NSError(domain: "TransactionsAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка обновления транзакции"]))
        }
        return updated
    }
    
    func deleteTransaction(id: Int) async throws {
        let request = Request.delete(url: ApiEndpoints.transaction(id: id))
        _ = try await networkClient.send(request) as EmptyResponse
    }
    
    func getTransactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        let request = Request.get(url: ApiEndpoints.transactionsForAccount(accountId: accountId, startDate: startDate, endDate: endDate))
        let dtos: [TransactionResponseDTO] = try await networkClient.send(request)
        return dtos.compactMap { $0.toDomain() }
    }
}
