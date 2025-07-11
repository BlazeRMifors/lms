import SwiftUI

struct AnalysisViewControllerRepresentable: UIViewControllerRepresentable {
  var viewModel: TransactionsListViewModel
  var onTransactionSelected: ((Transaction) -> Void)?
  
  func makeUIViewController(context: Context) -> AnalysisViewController {
    let analysisVM = AnalysisViewModel(viewModel: viewModel)
    let vc = AnalysisViewController(viewModel: analysisVM)
    vc.onTransactionSelected = onTransactionSelected
    return vc
  }
  
  func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
    // TODO: Обновить данные при необходимости
  }
}
