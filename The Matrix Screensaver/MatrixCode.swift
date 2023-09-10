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
    var wSpacing : UInt32 = 20
    var vSpacing : UInt32 = 15
    var numViews :Int = 0
    let changingNums : Int = 20
    private var w : UInt32 = 0
    private var v : UInt32 = 0
    //private let arrayOfLetters = ["ｦ","ｧ","ｨ","ｩ","ｪ","ｫ","ｬ","ｭ","ｮ","ｯ","ｱ","ｲ","ｳ","ｴ","ｵ","ｶ","ｷ","ｸ","ｹ","ｺ","ｻ","ｼ","ｽ","ｾ","ｿ","ﾀ","ﾁ","ﾂ","ﾃ","ﾄ","ﾅ","ﾆ","ﾇ","ﾈ","ﾉ","ﾊ","ﾋ","ﾌ","ﾍ","ﾎ","ﾏ","ﾐ","ﾑ","ﾒ","ﾓ","ﾔ","ﾕ","ﾖ","ﾗ","ﾘ","ﾙ","ﾚ","ﾛ","ﾜ","ﾝ"]
    private let arrayOfLetters = ["1", "0"]

    // MARK: - Initialization

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        screenW = UInt32(NSScreen.main!.frame.width)
        screenH = UInt32(NSScreen.main!.frame.height)
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func animateOneFrame() {
        //self.subviews.remove(at: 0)
        self.createCharacter()
    }

    // MARK: - Helper Functions

    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }
    
    private func selectCharacter() -> String {
        let selectedLetter = self.arrayOfLetters[Int.random(in: 0..<arrayOfLetters.count)]
        return selectedLetter
    }
    
    private func numbersToChange(maxNum:UInt32) -> [Int] {
        var numbersArray = [Int]()
        var itr : Int = 0
        while itr < changingNums {
            numbersArray.append(Int.random(in: 0..<Int(maxNum)))
            itr+=1
        }
        return numbersArray
    }
    
    private func createCharacter() {
        //var arrayOfLetters = [NSTextField]()
        let maxViews = ((UInt32(bounds.width)/wSpacing)+1) * ((UInt32(bounds.height)/vSpacing)+1)
        let charsToChange = numbersToChange(maxNum: maxViews)
        //let charsToChange : [Int] = [1, 4, 10, 30, 40, 50, 60, 80, 55, 65]
        var newIterator : Int = 0
        while w <= UInt32(bounds.width) {
            while v <= UInt32(bounds.height) {
                if charsToChange.contains(newIterator) {
                    let chosenChar = selectCharacter()
                    let letter : NSTextField = NSTextField(
                        frame: NSMakeRect(
                            CGFloat(w),
                            CGFloat(v),
                            20,
                            15))
                    // config
                    letter.isEditable         = false
                    letter.isBordered         = false
                    letter.alignment          = .left
                    letter.usesSingleLineMode = false
                    letter.backgroundColor    = NSColor.black
                    letter.font               = NSFont(name: "Raleway-Medium", size: CGFloat(30))
                    letter.stringValue        = chosenChar
                    letter.textColor          = NSColor.green
                    
                    
                    DispatchQueue.main.async {
                        //self.subviews.remove(at: 0)
                        
                        self.numViews+=1
                        if self.numViews > maxViews {
                            self.subviews.remove(at: 0)
                        }
                        self.addSubview(letter)
                        
                        // refresh only the letter rect
                        self.setNeedsDisplay(letter.frame)
                    }
                }
                v += vSpacing
                newIterator += 1
            }
            v = 0
            w += wSpacing
        }
        w = 0
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
