//
//  SplashScene.swift
//  MusicNotepad
//
//  Created by Eryk Mroczko on 07/01/2022.
//

import SwiftUI

struct SplashScene: View {
    
    @State private var isContentReady = false
    
    var body: some View {
        ZStack {
            if self.isContentReady {
                ContentView()
            } else {
                VStack(spacing: 0) {
                    Image("splashIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(0.3)
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.3)
                        
                }
            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main
                .asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeInOut(duration: 1.0)) {
                    self.isContentReady.toggle()
                }
            }
        }
        
    }
}

struct SplashScene_Previews: PreviewProvider {
    static var previews: some View {
        SplashScene()
    }
}
