import SwiftUI

struct CategoriesView: View {
    @State var viewModel: CategoriesViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("статьи")
                  .font(.subheadline)
                  .padding(.leading, 0)
                ) {
                    ForEach(viewModel.filteredCategories) { category in
                        HStack {
                            Text(String(category.emoji))
                            .font(.footnote)
                            .padding(4)
                            .background(
                              Circle().fill(Color.accent.opacity(0.2))
                            )
                            Text(category.name)
                            .padding(.leading, 6)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          40
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Мои статьи")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.updateSearch(text: newValue)
            }
            .onAppear {
                Task { await viewModel.loadCategories() }
            }
        }
    }
}

#Preview {
  let viewModel = CategoriesViewModel(categoriesService: CategoriesService())
  CategoriesView(viewModel: viewModel)
}
