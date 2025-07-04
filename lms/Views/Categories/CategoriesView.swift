import SwiftUI

struct CategoriesView: View {
    @State var viewModel: CategoriesViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("статьи")) {
                    ForEach(viewModel.filteredCategories) { category in
                        HStack {
                            Text(String(category.emoji))
                                .font(.title2)
                            Text(category.name)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Мои статьи")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: viewModel.searchText) { newValue in
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
