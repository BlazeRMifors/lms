//
//  OperationsListItemView.swift
//  lms
//
//  Created by Ivan Isaev on 18.06.2025.
//

import SwiftUI

struct OperationItemView: View {
  var operation: OperationItemViewModel
  
  var body: some View {
    HStack {
      Text(operation.icon)
        .padding(6)
        .background(
          Circle().fill(Color.accent.opacity(0.2))
        )
      
      VStack(alignment: .leading) {
        Text(operation.title)
          .background()
        
        if let comment = operation.comment {
          Text(comment)
            .font(.callout)
            .foregroundColor(Color.gray)
            .lineLimit(1)
        }
      }
      
      Spacer()
      
      VStack(alignment: .trailing) {
        Text(operation.sum)
        
        if let time = operation.time {
          Text(time)
        }
      }
    }
  }
}



#Preview {
  List {
    ForEach(MockOperation.allCases) { item in
      OperationItemView(operation: item)
    }
  }
}
