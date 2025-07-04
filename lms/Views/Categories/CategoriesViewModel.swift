import Foundation
import SwiftUI

@Observable
final class CategoriesViewModel {
    var searchText: String = ""
    private(set) var allCategories: [Category] = []
    private(set) var filteredCategories: [Category] = []
    
    private let categoriesService: CategoriesService
    
    init(categoriesService: CategoriesService) {
        self.categoriesService = categoriesService
        Task { await loadCategories() }
    }
    
    @MainActor
    func loadCategories() async {
        let categories = await categoriesService.getAllCategories()
        self.allCategories = categories
        self.filteredCategories = categories
    }
    
    func updateSearch(text: String) {
        searchText = text
        if text.isEmpty {
            filteredCategories = allCategories
        } else {
            filteredCategories = allCategories.filter { fuzzyMatch($0.name, text) }
        }
    }
    
    // Простая реализация fuzzy поиска (по вхождению и расстоянию Левенштейна <= 2)
    private func fuzzyMatch(_ source: String, _ query: String) -> Bool {
        let lowerSource = source.lowercased()
        let lowerQuery = query.lowercased()
        if lowerSource.contains(lowerQuery) { return true }
        return levenshtein(lowerSource, lowerQuery) <= 2
    }
    
    // Левенштейн для простого fuzzy поиска
    private func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a)
        let b = Array(b)
        var dist = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 0...a.count { dist[i][0] = i }
        for j in 0...b.count { dist[0][j] = j }
        for i in 1...a.count {
            for j in 1...b.count {
                dist[i][j] = a[i-1] == b[j-1] ? dist[i-1][j-1] : min(dist[i-1][j], dist[i][j-1], dist[i-1][j-1]) + 1
            }
        }
        return dist[a.count][b.count]
    }
} 
