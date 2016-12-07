//
//  ShareViewController.swift
//  KanManHuaShareExtension
//
//  Created by JingWen on 2016/11/14.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import UIKit
import Social
import MagicalRecord
import Alamofire

class ShareViewController: SLComposeServiceViewController {
    
    var manhuaURL:String?
    
    override func loadView() {
        super.loadView()
        self.setupMagicalRecord()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.analyzeURL()
    }
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    
    override func didSelectPost() {
        
        if let url = self.manhuaURL {
            if let object = BaseWebClass.sharedInstance.findWhichWebControl(url){
                object.addNewManHua(url, completionHandler: { (success) in
                    self.extensionContext!.completeRequest(returningItems: self.extensionContext?.inputItems, completionHandler: nil)
                })
            }
        }else{
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }

    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    fileprivate func analyzeURL(){
        for (_, value) in (self.extensionContext?.inputItems.enumerated())!{
            let item = value as! NSExtensionItem
            for (_, value) in (item.attachments?.enumerated())!{
                let attachment = value as! NSItemProvider
                if  attachment.hasItemConformingToTypeIdentifier("public.url") {
                    attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (item, error) in
                        if let item = item as? NSURL{
                            if let object = BaseWebClass.sharedInstance.findWhichWebControl(item.absoluteString!){
                                self.manhuaURL = object.analyzeURL(item.absoluteString)
                            }
                        }
                    })
                }
            }
        }
    }

    fileprivate func setupMagicalRecord(){
        let fileManager = FileManager.default
        let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.kanmanhua.app")
        let storeURL = containerURL?.appendingPathComponent("KanManHua.sqlite")
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStore(at: storeURL!)
    }
}
