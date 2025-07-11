import SwiftUI

struct AnalysisViewControllerRepresentable: UIViewControllerRepresentable {
    var viewModel: TransactionsListViewModel

    func makeUIViewController(context: Context) -> AnalysisViewController {
        let vc = AnalysisViewController()
        let analysisVM = AnalysisViewModel(baseViewModel: viewModel)
        vc.configure(with: analysisVM)
        return vc
    }

    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
        // TODO: Обновить данные при необходимости
    }
} 