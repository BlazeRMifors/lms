//
//  MainView.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI

struct MainTabView: View {
  
  var body: some View {
    TabView {
      TransactionsListView(direction: .outcome, currency: .rub)
        .tabItem {
          Label("Расходы", image: "downtrend-icon")
        }
      
      TransactionsListView(direction: .income, currency: .rub)
        .tabItem {
          Label("Доходы", image: "uptrend-icon")
        }
      
      NavigationStack {
        Text("Экран в разработке")
          .navigationTitle("Мой счет")
      }
        .tabItem {
          Label("Счет", image: "account-icon")
        }
      
      NavigationStack {
        Text("Экран в разработке")
          .navigationTitle("Мои статьи")
      }
        .tabItem {
          Label("Статьи", image: "categories-icon")
        }
      
      NavigationStack {
        Text("Экран в разработке")
          .navigationTitle("Настройки")
      }
        .tabItem {
          Label("Настройки", image: "settings-icon")
        }
    }
  }
}

#Preview {
  MainTabView()
}
