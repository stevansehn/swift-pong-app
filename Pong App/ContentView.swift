//
//  ContentView.swift
//  Pong App
//
//  Created by Stevan Sehn on 30/08/24.
//

import SwiftUI

struct PongGameView: View {

    @State private var ballPosition = CGPoint.zero
    @State private var ballVelocity = CGSize(width: 10, height: 10)
    @State private var leftPaddlePosition = CGPoint.zero
    @State private var rightPaddlePosition = CGPoint.zero

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let paddleWidth = screenWidth * 0.02
            let paddleHeight = screenHeight * 0.2
            let ballSize = screenWidth * 0.04
            
            ZStack {
                // Background color
                Color.black
                    .edgesIgnoringSafeArea(.all)

                // Left Paddle
                Rectangle()
                    .fill(Color.white)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(leftPaddlePosition)
                    .gesture(DragGesture().onChanged { value in
                        self.leftPaddlePosition.y = min(max(value.location.y, paddleHeight / 2), screenHeight - paddleHeight / 2)
                    })

                // Right Paddle
                Rectangle()
                    .fill(Color.white)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(rightPaddlePosition)
                    .gesture(DragGesture().onChanged { value in
                        self.rightPaddlePosition.y = min(max(value.location.y, paddleHeight / 2), screenHeight - paddleHeight / 2)
                    })

                // Ball
                Circle()
                    .fill(Color.white)
                    .frame(width: ballSize, height: ballSize)
                    .position(ballPosition)
                    .onAppear {
                        self.startGameLoop(screenSize: geometry.size)
                    }
            }
            .onAppear {
                // Initialize positions based on screen size
                self.leftPaddlePosition = CGPoint(x: paddleWidth * 2, y: screenHeight / 2)
                self.rightPaddlePosition = CGPoint(x: screenWidth - paddleWidth * 2, y: screenHeight / 2)
                self.ballPosition = CGPoint(x: screenWidth / 2, y: screenHeight / 2)
            }
        }
    }

    func startGameLoop(screenSize: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            self.moveBall(screenSize: screenSize)
            self.checkCollisions(screenSize: screenSize)
        }
    }

    func moveBall(screenSize: CGSize) {
        ballPosition.x += ballVelocity.width
        ballPosition.y += ballVelocity.height
    }

    func checkCollisions(screenSize: CGSize) {
        let paddleWidth = screenSize.width * 0.02
        let ballRadius = screenSize.width * 0.04 / 2

        if ballPosition.x <= leftPaddlePosition.x + paddleWidth / 2 + ballRadius || ballPosition.x >= rightPaddlePosition.x - paddleWidth / 2 - ballRadius {
            ballVelocity.width = -ballVelocity.width
        }
        if ballPosition.y <= ballRadius || ballPosition.y >= screenSize.height - ballRadius {
            ballVelocity.height = -ballVelocity.height
        }
    }
}

#Preview {
    PongGameView()
}
