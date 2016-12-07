//
//  IKanMan.swift
//  KanManHua
//
//  Created by JingWen on 2016/12/7.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import MagicalRecord

class IKanMan: BaseWebProtocol {
    var RegexContentsURL:String = "(http:\\/\\/\\D+\\d+.)"
    var RegexTitle: String = "book-title.+<h1>(.+)<\\/h1>"
    var RegexImage: String = "<img src=\"(.+?)\".+\\/>"
    var RegexChapter:String = "<h2>\\D*([0-9]+)\\D+<\\/h2>"
    var RegexUpdate:String = "<span class=\"text\">\\D+([0-9]+)\\D+<\\/span>"
    
    static let sharedInstance = IKanMan()
    
    private init(){}
    
    func prevPage(_ webview: UIWebView) {
        let script = "document.getElementById('prev').click()"
        webview.stringByEvaluatingJavaScript(from: script)
    }
    
    func prevChapter(_ webview: UIWebView) {
        let script = "document.getElementsByClassName('prevC')[0].click()"
        webview.stringByEvaluatingJavaScript(from: script)
    }
    
    func nextPage(_ webview:UIWebView){
        let script = "document.getElementById('next').click()"
        webview.stringByEvaluatingJavaScript(from: script)
    }
    
    func nextChapter(_ webview:UIWebView){
        let script = "document.getElementsByClassName('nextC')[0].click()"
        webview.stringByEvaluatingJavaScript(from: script)
    }
    
    func addNewManHua(_ url: String, completionHandler: @escaping (Bool) -> Void) {
        Alamofire.request(url).responseString { response in
            if response.result.isFailure{
                completionHandler(false)
                return
            }
            
            if let result = response.result.value{
                let title = RegexHtml.regex(htmlSrc: result, pattern: self.RegexTitle)
                let image = RegexHtml.regex(htmlSrc: result, pattern: self.RegexImage)
                
                MagicalRecord.save({ (localContext) in
                    let manhua = ManHua.mr_findFirstOrCreate(byAttribute: "url", withValue: url, in: localContext)
                    manhua.title = title
                    manhua.url = url
                    manhua.image = image
                    manhua.prepare = true
                }, completion: { (success, error) in
                    self.tagNew()
                    completionHandler(true)
                })
            }
        }
    }
    
    func analyzeURL(_ url:String?) -> String?{
        if let url = url {
            var fixed = RegexHtml.regex(htmlSrc: url, pattern: self.RegexContentsURL)
            if fixed.hasPrefix("http://m.ikanman.com") {
                fixed = fixed.replace(target: "http://m.ikanman.com", withString: "http://tw.ikanman.com")
            }
            
            if fixed.hasPrefix("http://www.ikanman.com") {
                fixed = fixed.replace(target: "http://www.ikanman.com", withString: "http://tw.ikanman.com")
            }
            return fixed
        }
        return nil
    }
    
    func tagNew(){
        if let defaults = UserDefaults.init(suiteName: "group.kanmanhua.app"){
            defaults.set(true, forKey: "newData")
            defaults.synchronize()
        }
    }
    
    func checkManHuaUpdate(_ url:String, completionHandler: @escaping (_ updateChapter:Int) -> Void){
        Alamofire.request(url).responseString { response in
            if response.result.isFailure{
                completionHandler(-1)
                return
            }
            
            if let result = response.result.value{
                let update = RegexHtml.regex(htmlSrc: result, pattern: self.RegexUpdate)
                MagicalRecord.save({ (localContext) in
                    let manhua = ManHua.mr_findFirstOrCreate(byAttribute: "url", withValue: url, in: localContext)
                    manhua.update = Int16(update)! > manhua.chapter
                }, completion: { (success, error) in
                    completionHandler(1)
                })
            }
        }
    }
}
