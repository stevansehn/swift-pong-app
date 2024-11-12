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
    @State private var leftScore = 0
    @State private var rightScore = 0
    @State private var leftPaddleControlled = false
    @State private var rightPaddleControlled = false
    @State private var isResetting = false

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

                // Scoreboard
                HStack(spacing: 50) {
                    Text("\(leftScore)")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                    Text("\(rightScore)")
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                }
                .position(x: screenWidth / 2, y: 50)

                // Left Paddle
                Rectangle()
                    .fill(Color.white)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(leftPaddlePosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !leftPaddleControlled {
                                    // Check if the touch is near the paddle
                                    let touchPoint = value.location
                                    if abs(touchPoint.x - leftPaddlePosition.x) < paddleWidth * 2 &&
                                       abs(touchPoint.y - leftPaddlePosition.y) < paddleHeight {
                                        leftPaddleControlled = true
                                    }
                                }
                                
                                if leftPaddleControlled {
                                    self.leftPaddlePosition.y = min(max(value.location.y, paddleHeight / 2), screenHeight - paddleHeight / 2)
                                }
                            }
                            .onEnded { _ in
                                leftPaddleControlled = false
                            }
                    )

                // Right Paddle (similar changes as left paddle)
                Rectangle()
                    .fill(Color.white)
                    .frame(width: paddleWidth, height: paddleHeight)
                    .position(rightPaddlePosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !rightPaddleControlled {
                                    let touchPoint = value.location
                                    if abs(touchPoint.x - rightPaddlePosition.x) < paddleWidth * 2 &&
                                       abs(touchPoint.y - rightPaddlePosition.y) < paddleHeight {
                                        rightPaddleControlled = true
                                    }
                                }
                                
                                if rightPaddleControlled {
                                    self.rightPaddlePosition.y = min(max(value.location.y, paddleHeight / 2), screenHeight - paddleHeight / 2)
                                }
                            }
                            .onEnded { _ in
                                rightPaddleControlled = false
                            }
                    )

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
        let paddleHeight = screenSize.height * 0.2
        let ballRadius = screenSize.width * 0.04 / 2

        // Only check for scoring if we're not currently resetting
        if !isResetting {
            // Check for scoring (ball hitting left or right walls)
            if ballPosition.x <= ballRadius {
                // Right player scores
                rightScore += 1
                resetBall(screenSize: screenSize)
            } else if ballPosition.x >= screenSize.width - ballRadius {
                // Left player scores
                leftScore += 1
                resetBall(screenSize: screenSize)
            }
        }

        // Check for paddle collisions
        if ballPosition.x <= leftPaddlePosition.x + paddleWidth / 2 + ballRadius &&
           ballPosition.y >= leftPaddlePosition.y - paddleHeight / 2 &&
           ballPosition.y <= leftPaddlePosition.y + paddleHeight / 2 {
            ballVelocity.width = -ballVelocity.width
        }
        
        if ballPosition.x >= rightPaddlePosition.x - paddleWidth / 2 - ballRadius &&
           ballPosition.y >= rightPaddlePosition.y - paddleHeight / 2 &&
           ballPosition.y <= rightPaddlePosition.y + paddleHeight / 2 {
            ballVelocity.width = -ballVelocity.width
        }

        // Check for top/bottom wall collisions
        if ballPosition.y <= ballRadius || ballPosition.y >= screenSize.height - ballRadius {
            ballVelocity.height = -ballVelocity.height
        }
    }

    func resetBall(screenSize: CGSize) {
        isResetting = true
        // Hide the ball by moving it off screen
        ballPosition = CGPoint(x: -100, y: -100)
        
        // Wait 1 second before respawning the ball
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Reset ball to center
            ballPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
            
            // Randomize the ball direction while maintaining the same speed
            let speed = sqrt(pow(ballVelocity.width, 2) + pow(ballVelocity.height, 2))
            let angle = Double.random(in: -Double.pi/4...Double.pi/4) + (ballVelocity.width < 0 ? 0 : Double.pi)
            ballVelocity = CGSize(
                width: speed * CGFloat(cos(angle)),
                height: speed * CGFloat(sin(angle))
            )
            isResetting = false
        }
    }
}

#Preview {
    PongGameView()
}
