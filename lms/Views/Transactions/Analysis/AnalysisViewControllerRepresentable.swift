import SwiftUI

struct AnalysisViewControllerRepresentable: UIViewControllerRepresentable {
  var viewModel: TransactionsListViewModel
  
  @Bindable var analysisVM: AnalysisViewModel
  
  init(viewModel: TransactionsListViewModel) {
    self.viewModel = viewModel
    self.analysisVM = AnalysisViewModel(viewModel: viewModel)
  }
  
  func makeUIViewController(context: Context) -> AnalysisViewController {
    let vc = AnalysisViewController(viewModel: analysisVM)
    return vc
  }
  
  func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
    // TODO: Обновить данные при необходимости
  }
}
