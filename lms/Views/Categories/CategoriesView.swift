//
//  CategoriesView.swift
//  lms
//
//  Created by Ivan Isaev on 03.07.2025.
//

import SwiftUI

struct CategoriesView: View {
  
  private enum Constants {
    static let emojiPadding: CGFloat = 4
    static let emojiBackgroundOpacity: Double = 0.2
    static let nameLeadingPadding: CGFloat = 6
    static let listRowSeparatorLeading: CGFloat = 40
  }
  
  @State var viewModel: CategoriesViewModel
  
  var body: some View {
    NavigationStack {
      ZStack {
        List {
          Section(header: Text("статьи")
            .font(.subheadline)
          ) {
            ForEach(viewModel.filteredCategories) { category in
              HStack {
                Text(String(category.emoji))
                  .font(.footnote)
                  .padding(Constants.emojiPadding)
                  .background(
                    Circle().fill(.accent.opacity(Constants.emojiBackgroundOpacity))
                  )
                Text(category.name)
                  .padding(.leading, Constants.nameLeadingPadding)
              }
              .alignmentGuide(.listRowSeparatorLeading) { _ in
                Constants.listRowSeparatorLeading
              }
            }
          }
        }
        if viewModel.isLoading {
          Color.black.opacity(0.2).ignoresSafeArea()
          ProgressView().scaleEffect(1.5)
        }
      }
      .alert(isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
        Alert(title: Text("Ошибка"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
      }
      .navigationTitle("Мои статьи")
      .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
      .onChange(of: viewModel.searchText) { _, newValue in
        viewModel.updateSearch(text: newValue)
      }
    }
  }
}

#Preview {
  let viewModel = CategoriesViewModel(categoriesService: CategoriesService())
  CategoriesView(viewModel: viewModel)
}
