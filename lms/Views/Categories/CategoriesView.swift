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
        if viewModel.isLoading {
          ProgressView()
        }
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
        .opacity(viewModel.isLoading ? 0 : 1)
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
