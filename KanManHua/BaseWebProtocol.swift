//
//  BaseWebProtocol.swift
//  KanManHua
//
//  Created by JingWen on 2016/12/7.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import Foundation
import UIKit

protocol BaseWebProtocol {
    var RegexContentsURL:String{get}
    var RegexTitle:String{get}
    var RegexImage:String{get}
    var RegexChapter:String{get}
    var RegexUpdate:String{get}
    
    func prevPage(_ webview:UIWebView)
    func prevChapter(_ webview:UIWebView)
    func nextPage(_ webview:UIWebView)
    func nextChapter(_ webview:UIWebView)
    func addNewManHua(_ url:String, completionHandler: @escaping (_ success:Bool) -> Void)
    func analyzeURL(_ url:String?) -> String?
    func checkManHuaUpdate(_ url:String, completionHandler: @escaping (_ updateChapter:Int) -> Void)
}

extension BaseWebProtocol{
    func prevPage(_ webview:UIWebView){
        
    }
    
    func prevChapter(_ webview:UIWebView){
        
    }
    
    func nextPage(_ webview:UIWebView){
       
    }
    
    func nextChapter(_ webview:UIWebView){
      
    }
}

extension String{
    func replace(target: String, withString: String) -> String{
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
}
