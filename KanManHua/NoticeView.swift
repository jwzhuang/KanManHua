//
//  NoticeView.swift
//  KanManHua
//
//  Created by JingWen on 2016/11/25.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class NoticeView: UIView {
    
    @IBInspectable var text:String = ""{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var textSize:CGFloat = 12.0{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        StyleKit.drawNotice(self.bounds, text: self.text, textSize: self.textSize)
    }
}
