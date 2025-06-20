//
//  Untitled.swift
//  lms
//
//  Created by Ivan Isaev on 18.06.2025.
//

import SwiftUI

struct TransactionsListItemView: View {
  var body: some View {
    HStack {
      Text("🛒")
      VStack(alignment: .leading) {
        Text("На собачку")
        Text("Джек")
      }
      Spacer()
      Text("100 000 ₽")
    }
    .padding()
  }
}

#Preview {
  TransactionsListItemView()
}

struct TransactionsListItemViewModel: Hashable, Identifiable {
  let id: UUID
  let icon: String
  let title: String
  let subtitle: String
  let amount: String
}

