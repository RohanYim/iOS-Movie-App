//
//  LoadingView.swift
//  HaoranSong-Lab4
//
//  Created by Haoran Song on 10/22/22.
//  Reference: https://github.com/HanHan120766/LoadingDemo/tree/master

import UIKit
import Foundation

class LoadingView: UIView {

    public var lineWidth: Int = 4

    public var lineColor: UIColor = UIColor(red: 0.00, green: 0.42, blue: 0.46, alpha: 1.00)

    fileprivate var timer: Timer?

    fileprivate var originStart: CGFloat = CGFloat(Double.pi / 2 * 3)

    fileprivate var originEnd: CGFloat = CGFloat(Double.pi / 2 * 3 )

    fileprivate var isDraw: Bool = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(LoadingView.updateLoading), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: RunLoop.Mode.default)
        self.timer?.fire()

    }

    @objc func updateLoading () {
        if (self.originEnd == CGFloat(Double.pi / 2 * 3) && isDraw) {
            self.originStart += CGFloat(Double.pi / 10)
            if (self.originStart == CGFloat(Double.pi / 2 * 3 + 2 * Double.pi)) {
                self.isDraw = false
                self.setNeedsDisplay()
                return
            }
        }

        if (self.originStart == CGFloat(Double.pi / 2 * 3 + 2 * Double.pi) && !self.isDraw) {
            self.originEnd += CGFloat(Double.pi / 10)
            if (self.originEnd == CGFloat(Double.pi / 2 * 3 + 2 * Double.pi)) {
                self.isDraw = true
                self.originStart = CGFloat(Double.pi / 2 * 3)
                self.originEnd = CGFloat(Double.pi / 2 * 3)
                self.setNeedsDisplay()
                return
            }
        }
        self.setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let center: CGPoint = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        let radius = min(self.frame.size.width, self.frame.size.height) / 2 - CGFloat(self.lineWidth) - 20;
        let path: UIBezierPath = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: self.originStart, endAngle: self.originEnd, clockwise: false)
        context?.addPath(path.cgPath)
        context?.setLineWidth(CGFloat(self.lineWidth))
        context?.setStrokeColor(self.lineColor.cgColor)
        context?.strokePath()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

