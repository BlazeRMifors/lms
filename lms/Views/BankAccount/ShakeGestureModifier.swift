//
//  ShakeGestureModifier.swift
//  lms
//
//  Created by Ivan Isaev on 26.06.2025.
//

import SwiftUI
import CoreMotion

extension View {
  func onShake(perform action: @escaping () -> Void) -> some View {
    modifier(ShakeGestureHandler(action: action))
  }
}

private struct ShakeGestureHandler: ViewModifier {
  let action: () -> Void
  
  func body(content: Content) -> some View {
    content
      .onAppear {
        let motionManager = CMMotionManager()
        motionManager.startDeviceMotionUpdates(to: .main) { data, error in
          guard let data = data, error == nil else { return }
          if abs(data.userAcceleration.x) > 1.5 ||
              abs(data.userAcceleration.y) > 1.5 ||
              abs(data.userAcceleration.z) > 1.5 {
            action()
          }
        }
      }
  }
}
