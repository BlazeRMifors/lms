//
//  OperationsListView.swift
//  lms
//
//  Created by Ivan Isaev on 18.06.2025.
//

import SwiftUI

struct OperationListView: View {
  var operations: [OperationItemViewModel]
  
  var body: some View {
    Section(header: Text("Операции").font(.subheadline).padding(.leading, 0)) {
      ForEach(operations) { operation in
        NavigationLink(destination: Text("Экран в разработке")) {
          OperationItemView(operation: operation)
            .frame(height: 44)
            .alignmentGuide(.listRowSeparatorLeading) { _ in
              42
            }
        }
      }
    }
  }
}

#Preview {
  NavigationStack {  
    List {
      OperationListView(operations: MockOperation.allCases)
    }
  }
}
