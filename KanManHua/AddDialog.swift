//
//  AddDialog.swift
//  KanManHua
//
//  Created by JingWen on 2016/11/25.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

@objc protocol AddDialogDelegate{
    @objc optional func AddDialogClickDone()
}

class AddDialog: UIViewController {
    @IBOutlet var dialog:UIView?
    @IBOutlet var textView:UITextView?
    var delegate:AddDialogDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dialog?.layer.cornerRadius = 5.0
        
        self.textView?.layer.borderWidth = 1.0
        self.textView?.layer.borderColor = UIColor.black.cgColor
        self.textView?.layer.cornerRadius = 5.0
    }
    
    @IBAction func clickDone(_ sender:Any){
        self.textView?.resignFirstResponder()
        var url = self.textView?.text
        if (url?.characters.count)! > 0 {
            if let object = BaseWebClass.sharedInstance.findWhichWebControl(url!){
                url = object.analyzeURL(url)
                object.addNewManHua(url!, completionHandler: { (success) in
                    if let delegate = self.delegate{
                        delegate.AddDialogClickDone?()
                        self.performSegue(withIdentifier: "leave", sender: nil)
                    }
                })
            }
        }
    }
}
