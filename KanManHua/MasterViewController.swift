//
//  MasterViewController.swift
//  KanManHua
//
//  Created by JingWen on 2016/11/9.
//  Copyright © 2016年 JingWen. All rights reserved.
//

import UIKit
import Alamofire
import MagicalRecord
import Kingfisher

class MasterViewController: UITableViewController, AddDialogDelegate {

    var detailViewController: DetailViewController? = nil
    var manhuas:[ManHua]?

    override func loadView() {
        super.loadView()
        self.manhuas = ManHua.mr_findAllSorted(by: "update", ascending: false) as? [ManHua]
        self.clearNew()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupRefreshControl()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationBecameActive(notification:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        self.checkHaveNew()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMaster(segue: UIStoryboardSegue) {

    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let manhua = self.manhuas?[indexPath.row]
                manhua?.update = false
                let cell = self.tableView.cellForRow(at: indexPath) as! ContentsCell
                cell.notice.isHidden = true
//                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.manhua = manhua
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
            }
        }else if segue.identifier == "add" {
            let controller = segue.destination as! AddDialog
            controller.delegate = self
        }
    }

    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let manhuas = self.manhuas{
            return manhuas.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ContentsCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContentsCell

        if let manhuas = self.manhuas{
            let manhua = manhuas[indexPath.row]
            if let imgURL = manhua.image{
                cell.cover?.kf.setImage(with: URL(string:imgURL))
            }
            if let title = manhua.title{
                cell.title.text = title
            }
            
            cell.notice.isHidden = !manhua.update
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MagicalRecord.save({ (localContext) in
                if let manhua = self.manhuas?[indexPath.row]{
                    manhua.mr_deleteEntity(in: localContext)
                }
            }, completion: { (success, error) in
                if success{
                    self.manhuas?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })
        }
    }
    
    // MARK: - Observer
    @objc fileprivate func applicationBecameActive(notification: NSNotification){
        self.checkHaveNew()
    }
    // MARK: - file private method
    
    fileprivate func checkHaveNew(){
        if let defaults = UserDefaults.init(suiteName: "group.kanmanhua.app"){
            let haveNew = defaults.bool(forKey: "newData")
            if haveNew {
                self.manhuas = ManHua.mr_findAllSorted(by: "update", ascending: false) as? [ManHua]
                self.clearNew()
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func clearNew(){
        if let defaults = UserDefaults.init(suiteName: "group.kanmanhua.app"){
            defaults.set(false, forKey: "newData")
            defaults.synchronize()
        }
    }
    
    fileprivate func setupRefreshControl(){
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(MasterViewController.refreshManHua(_:)), for: .valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string:"Release for refresh")
    }
    
    @objc fileprivate func refreshManHua(_ sender:Any?){
        BaseWebClass.sharedInstance.checkManHuasUpdate { (success) in
            self.manhuas = ManHua.mr_findAllSorted(by: "update", ascending: false) as? [ManHua]
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    //MARK: - AddDialogDelegate
    func AddDialogClickDone() {
        self.checkHaveNew()
    }
}
