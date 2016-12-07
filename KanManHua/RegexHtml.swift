//
//  RegexPattern.swift
//  KanManHua
//
//  Created by JingWen on 2016/11/11.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import Foundation
class RegexHtml{
    
    class func regex(htmlSrc:String, pattern:String) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let matches = regex.matches(in: htmlSrc, options: [], range: NSMakeRange(0, htmlSrc.characters.count))
        var groups: [String] = []
        matches.forEach({ (textCheckingResult) in
            groups.append( (htmlSrc as NSString).substring(with: textCheckingResult.rangeAt(1)) )
        })
        if groups.count == 0{
            return "0"
        }
        return groups[0]
    }
}
