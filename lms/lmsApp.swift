//
//  lmsApp.swift
//  lms
//
//  Created by Ivan Isaev on 17.06.2025.
//

import SwiftUI

@main
struct lmsApp: App {
  
  init() {
    // Настройка общего стиля NavigationBar
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
//      .configureWithDefaultBackground()
    
    // Цвет кнопок навигации (включая стрелку назад)
    appearance.backButtonAppearance.normal.titleTextAttributes[.foregroundColor] = UIColor.red
    
    // Также можно задать цвет значков
//    appearance.backButtonAppearance.normal.iconColor = UIColor.red
    
    // Установка как для всех навигационных баров
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    
    // Для поддержки iOS 15 и ниже
    UINavigationBar.appearance().tintColor = .red
  }
  
  var body: some Scene {
    WindowGroup {
      MainTabView()
    }
  }
}
