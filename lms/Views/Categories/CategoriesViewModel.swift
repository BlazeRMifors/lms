//
//  CategoriesViewModel.swift
//  lms
//
//  Created by Ivan Isaev on 03.07.2025.
//

import SwiftUI

@Observable
final class CategoriesViewModel {
  var searchText: String = ""
  private(set) var allCategories: [Category] = []
  private(set) var filteredCategories: [Category] = []
  var isLoading: Bool = false
  var errorMessage: String? = nil
  
  private let categoriesService: CategoriesService
  
  init(categoriesService: CategoriesService) {
    self.categoriesService = categoriesService
    self.loadCategories()
  }
  
  private func loadCategories() {
    Task.detached { [categoriesService, weak self] in
      await self?.runLoadingCategories()
      let categories = await categoriesService.getAllCategories()
      await self?.updateCategories(categories)
    }
  }
  
  @MainActor
  private func runLoadingCategories() {
    isLoading = true
    errorMessage = nil
  }
  
  @MainActor
  private func updateCategories(_ categories: [Category]) {
    allCategories = categories
    filteredCategories = categories
    isLoading = false
    errorMessage = nil
  }

  @MainActor
  private func handleError(_ error: Error) {
    isLoading = false
    errorMessage = error.localizedDescription
  }
  
  func updateSearch(text: String) {
    searchText = text
    if text.isEmpty {
      filteredCategories = allCategories
    } else {
      filteredCategories = allCategories.filter { fuzzyMatch($0.name, text) }
    }
  }
  
  // Простая реализация fuzzy поиска (по вхождению и последовательности)
  private func fuzzyMatch(_ source: String, _ query: String) -> Bool {
    let lowerSource = source.lowercased()
    let lowerQuery = query.lowercased()
    if lowerSource.contains(lowerQuery) { return true }
    if subsequenceMatch(lowerSource, lowerQuery) { return true }
    return false
  }
  
  // Проверка: все буквы query встречаются в source в том же порядке (не обязательно подряд)
  private func subsequenceMatch(_ source: String, _ query: String) -> Bool {
    guard !query.isEmpty else { return true }
    var sourceIndex = source.startIndex
    var queryIndex = query.startIndex
    while sourceIndex < source.endIndex && queryIndex < query.endIndex {
      if source[sourceIndex] == query[queryIndex] {
        queryIndex = query.index(after: queryIndex)
      }
      sourceIndex = source.index(after: sourceIndex)
    }
    return queryIndex == query.endIndex
  }
}
