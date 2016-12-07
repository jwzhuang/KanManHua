//
//  DetailViewController.swift
//  KanManHua
//
//  Created by JingWen on 2016/11/9.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import UIKit
import MagicalRecord
import PKHUD

class DetailViewController: UIViewController, UIWebViewDelegate{

    @IBOutlet weak var webView: UIWebView!
    
    var manhua:ManHua?{
        didSet{
            self.loadURL()
        }
    }
    
    var getLastURL:Bool = false

    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.loadURL()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationBecameActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidEnterBackground(notification:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        getLastURL = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        getLastURL = false
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        super.viewDidDisappear(animated)
    }
    
    //MARK: - UIWebViewDelegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let host = request.url?.host{
            if host.hasPrefix("tw.ikanman.com"){
                return true
            }
        }
        return false
    }
    
    // MARK: - Observer
    @objc fileprivate func applicationBecameActive(notification: NSNotification){
        getLastURL = true
    }
    
    @objc fileprivate func applicationDidEnterBackground(notification: NSNotification){
        getLastURL = false
    }
    
    //MARK: - file private method
    fileprivate func loadURL() {
        self.navigationItem.title = self.manhua?.title
        // Update the user interface for the detail item.
        if let webView = self.webView{
            self.navigationItem.title = self.manhua?.title
            if let last = self.manhua?.last{
                if last.characters.count > 0{
                    webView.loadRequest(URLRequest(url:URL(string:last)!))
                }else{
                    webView.loadRequest(URLRequest(url:URL(string:(self.manhua?.url)!)!))
                }
            }else if let url = self.manhua?.url{
                webView.loadRequest(URLRequest(url:URL(string:url)!))
            }
        }
    }
    
    fileprivate func saveLastURL(){
        let script = "document.URL"
        if let url = self.webView.stringByEvaluatingJavaScript(from: script){
            MagicalRecord.save({ (localContext) in
                if let localManHua = self.manhua?.mr_(in: localContext){
                    localManHua.last = url
                }
            })
        }
    }
    
    fileprivate func saveLastChapter(){
        let script = "document.body.innerHTML"
        if let html = self.webView.stringByEvaluatingJavaScript(from: script){
            if html.characters.count > 0{
                if let object = BaseWebClass.sharedInstance.findWhichWebControl((self.manhua?.url)!){
                    let chapter = Int16(RegexHtml.regex(htmlSrc: html, pattern: object.RegexChapter))
                    if let chapter = chapter{
                        MagicalRecord.save({ (localContext) in
                            if let localManHua = self.manhua?.mr_(in: localContext){
                                localManHua.chapter = chapter
                                localManHua.update = false
                            }
                        })
                    }
                }
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func clickRemember(_ sender:Any?){
        HUD.show(.progress)
        self.saveLastChapter()
        self.saveLastURL()
        HUD.flash(.success, delay: 0.0)
    }
}

