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
  @State private var motionManager = CMMotionManager()
  @State private var lastShakeTime: Date = Date.distantPast
  
  func body(content: Content) -> some View {
    content
      .onAppear {
        startMotionDetection()
      }
      .onDisappear {
        stopMotionDetection()
      }
  }
  
  private func startMotionDetection() {
    guard motionManager.isDeviceMotionAvailable else { 
      print("Device motion not available")
      return 
    }
    
    print("Starting motion detection")
    motionManager.deviceMotionUpdateInterval = 0.1
    motionManager.startDeviceMotionUpdates(to: .main) { data, error in
      guard let data = data, error == nil else { return }
      
      // Проверяем, прошло ли достаточно времени с последнего shake
      let now = Date()
      guard now.timeIntervalSince(lastShakeTime) > 1.0 else { return }
      
      // Проверяем ускорение по всем осям
      let acceleration = sqrt(
        pow(data.userAcceleration.x, 2) +
        pow(data.userAcceleration.y, 2) +
        pow(data.userAcceleration.z, 2)
      )
      
      if acceleration > 2.0 {
        print("Real device shake detected with acceleration: \(acceleration)")
        lastShakeTime = now
        action()
      }
    }
  }
  
  private func stopMotionDetection() {
    if motionManager.isDeviceMotionActive {
      print("Stopping motion detection")
      motionManager.stopDeviceMotionUpdates()
    }
  }
}
