//
//  LaunchAnimationView.swift
//  lms
//
//  Created by Ivan Isaev on 25.07.2025.
//

import SwiftUI
import Lottie

struct LaunchAnimationView: View {
    @Binding var isAnimationCompleted: Bool
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            LottieAnimationUIView(isAnimationCompleted: $isAnimationCompleted)
                .frame(width: 315, height: 280)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        if !isAnimationCompleted {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isAnimationCompleted = true
                            }
                        }
                    }
                }
        }
    }
}

struct LottieAnimationUIView: UIViewRepresentable {
    @Binding var isAnimationCompleted: Bool
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        
        if let animation = LottieAnimation.named("launch-lottie") {
            animationView.animation = animation
            animationView.loopMode = .playOnce
            animationView.contentMode = .scaleAspectFit
            
            animationView.play { finished in
                if finished {
                    DispatchQueue.main.async {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isAnimationCompleted = true
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isAnimationCompleted = true
                }
            }
        }
        
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        //
    }
}

#Preview {
    LaunchAnimationView(isAnimationCompleted: .constant(false))
} 