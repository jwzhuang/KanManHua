//
//  BaseWebClass.swift
//  KanManHua
//
//  Created by JingWen on 2016/12/7.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import Foundation
import MagicalRecord

class BaseWebClass{
    
    static let sharedInstance = BaseWebClass()
    
    private init(){}

    func checkManHuasUpdate(_ completionHandler: @escaping (Bool) -> Void){
        if let manhuas = ManHua.mr_findAll() as? [ManHua]?{
            let queue = DispatchQueue.global(qos: .background)
            let group = DispatchGroup()
            
            for manhua in manhuas!{
                group.enter()
                queue.async(group: group, execute: {
                    if let object = self.findWhichWebControl(manhua.url!){
                        object.checkManHuaUpdate(manhua.url!, completionHandler: { (updateChapter) in
                            group.leave()
                        })
                    }
                })
            }
            
            group.notify(queue: .main, execute: {
                completionHandler(true)
            })
        }
    }
    
    func findWhichWebControl(_ url:String) -> BaseWebProtocol? {
        if url.contains(find: "ikanman"){
            return IKanMan.sharedInstance
        }
        return nil
    }
}
