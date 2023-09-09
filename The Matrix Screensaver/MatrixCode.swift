//
//  PongView.swift
//  The Matrix Screensaver
//
//  Created by Siddhant Tandon on 9/9/2023.
//

import ScreenSaver

class PongView: ScreenSaverView {
    
    var screenW : UInt32 = 0
    var screenH : UInt32 = 0
    var wSpacing : UInt32 = 15
    var vSpacing : UInt32 = 10
    private var w : UInt32 = 0
    private var v : UInt32 = 0
    private let arrayOfLetters = ["ｦ","ｧ","ｨ","ｩ","ｪ","ｫ","ｬ","ｭ","ｮ","ｯ","ｱ","ｲ","ｳ","ｴ","ｵ","ｶ","ｷ","ｸ","ｹ","ｺ","ｻ","ｼ","ｽ","ｾ","ｿ","ﾀ","ﾁ","ﾂ","ﾃ","ﾄ","ﾅ","ﾆ","ﾇ","ﾈ","ﾉ","ﾊ","ﾋ","ﾌ","ﾍ","ﾎ","ﾏ","ﾐ","ﾑ","ﾒ","ﾓ","ﾔ","ﾕ","ﾖ","ﾗ","ﾘ","ﾙ","ﾚ","ﾛ","ﾜ","ﾝ"]
    private var ballPosition: CGPoint = .zero
    private var ballVelocity: CGVector = .zero
    private var paddlePosition: CGFloat = 0
    private let ballRadius: CGFloat = 15
    private let paddleBottomOffset: CGFloat = 100
    private let paddleSize = NSSize(width: 60, height: 20)

    // MARK: - Initialization

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        screenW = UInt32(NSScreen.main!.frame.width)
        screenH = UInt32(NSScreen.main!.frame.height)
        
        ballPosition = CGPoint(x: frame.width / 2, y: frame.height / 2)
        ballVelocity = initialVelocity()
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func draw(_ rect: NSRect) {
        drawBackground(.black)
        drawBall()
        drawPaddle()
    }

    override func animateOneFrame() {
        super.animateOneFrame()

        let oobAxes = ballIsOOB()
        if oobAxes.xAxis {
            ballVelocity.dx *= -1
        }
        if oobAxes.yAxis {
            ballVelocity.dy *= -1
        }

        let paddleContact = ballHitPaddle()
        if paddleContact {
            ballVelocity.dy *= -1
        }

        ballPosition.x += ballVelocity.dx
        ballPosition.y += ballVelocity.dy
        paddlePosition = ballPosition.x

        setNeedsDisplay(bounds)
    }

    // MARK: - Helper Functions

    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }

    private func drawBall() {
        let ballRect = NSRect(x: ballPosition.x - ballRadius,
                              y: ballPosition.y - ballRadius,
                              width: ballRadius * 2,
                              height: ballRadius * 2)
        let ball = NSBezierPath(roundedRect: ballRect,
                                xRadius: ballRadius,
                                yRadius: ballRadius)
        NSColor.white.setFill()
        ball.fill()
    }
    
    private func selectCharacter() -> String {
        let selectedLetter = self.arrayOfLetters[Int.random(in: 1..<arrayOfLetters.count)]
        return selectedLetter
    }
    
    private func createCharacter() -> [NSTextField] {
        let chosenChar = selectCharacter()
        var arrayOfLetters = [NSTextField]()
        var i : Int = 0
        while w < UInt32(bounds.height) {
            while v < UInt32(bounds.width) {
                let letter : NSTextField = NSTextField(
                    frame: NSMakeRect(
                        CGFloat(w),
                        CGFloat(v),
                        30,
                        35))
                v += vSpacing
                // config
                letter.isEditable         = false
                letter.isBordered         = false
                letter.alignment          = .center
                letter.usesSingleLineMode = false
                letter.backgroundColor    = NSColor.clear
                letter.font               = NSFont(name: "Raleway-Medium", size: CGFloat(50))
                letter.stringValue        = chosenChar
                letter.textColor          = NSColor.green
                
                arrayOfLetters[i] = letter
                i += 1
            }
            v=0
            w += wSpacing
        }
        w=0
        return arrayOfLetters
    }
    
    private func drawPaddle() {
        let paddleRect = NSRect(x: paddlePosition - paddleSize.width / 2,
                                y: paddleBottomOffset - paddleSize.height / 2,
                                width: paddleSize.width,
                                height: paddleSize.height)
        let paddle = NSBezierPath(rect: paddleRect)
        NSColor.white.setFill()
        paddle.fill()
        DispatchQueue.global(qos: .background).async {
            var arrOfLetters = self.createCharacter()
//            DispatchQueue.main.async {
//                let rows = arrOfLetters.count
//                let columns = arrOfLetters[0].count
//                var r = 0
//                var c = 0
//                while r < rows {
//                    while c < columns {
//                        self.addSubview(arrOfLetters[r][c])
//                        // refresh only the letter rect
//                        self.setNeedsDisplay(arrOfLetters[r][c].frame)
//                        c+=1
//                    }
//                    r+=1
//                }
//            }
        }
    }

    private func initialVelocity() -> CGVector {
        let desiredVelocityMagnitude: CGFloat = 10
        let xVelocity = CGFloat.random(in: 2.5...7.5)
        let xSign: CGFloat = Bool.random() ? 1 : -1
        let yVelocity = sqrt(pow(desiredVelocityMagnitude, 2) - pow(xVelocity, 2))
        let ySign: CGFloat = Bool.random() ? 1 : -1
        return CGVector(dx: xVelocity * xSign, dy: yVelocity * ySign)
    }

    private func ballIsOOB() -> (xAxis: Bool, yAxis: Bool) {
        let xAxisOOB = ballPosition.x - ballRadius <= 0 ||
            ballPosition.x + ballRadius >= bounds.width
        let yAxisOOB = ballPosition.y - ballRadius <= 0 ||
            ballPosition.y + ballRadius >= bounds.height
        return (xAxisOOB, yAxisOOB)
    }

    private func ballHitPaddle() -> Bool {
        let xBounds = (lower: paddlePosition - paddleSize.width / 2,
                       upper: paddlePosition + paddleSize.width / 2)
        let yBounds = (lower: paddleBottomOffset - paddleSize.height / 2,
                       upper: paddleBottomOffset + paddleSize.height / 2)
        return ballPosition.x >= xBounds.lower &&
            ballPosition.x <= xBounds.upper &&
            ballPosition.y - ballRadius >= yBounds.lower &&
            ballPosition.y - ballRadius <= yBounds.upper
    }

}


extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}
