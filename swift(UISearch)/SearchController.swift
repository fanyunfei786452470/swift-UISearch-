//
//  SearchController.swift
//  swift(UISearch)
//
//  Created by 范云飞 on 2017/8/7.
//  Copyright © 2017年 范云飞. All rights reserved.
//

import UIKit

let ScreentWith = UIScreen.main.bounds.size.width
let ScreentHeight = UIScreen.main.bounds.size.height

let filePath:String = NSHomeDirectory() + "/Documents/fruit.plist"




class SearchController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    var array:[NSString]!//数据源
    var searchBar:UISearchBar?//searchBar
    var dataSource:NSMutableArray?
    var tableView:UITableView?//tableView
    var tagsView:UIView?//热门搜索的view
    var heaerView:UIView?//头视图
    
    var searchHistoriesCount:NSInteger?//搜索历史的数量
    
    
    var searchHistoryies = NSMutableArray()//搜索历史数据
    var searchHistoriesCachePath:String!// 缓存路径
//    var searchSuggestionVC:SearchResultsController?
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchBar?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchBar?.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        self.searchHistoriesCount = 20
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.plain)
        self.tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.view.addSubview(self.tableView!)
        
        let titleView = UIView(frame: CGRect(x: 10, y: 7, width: ScreentWith - 64 - 20, height: 30))
        let searchBar = UISearchBar(frame: CGRect(x: -10, y: 0, width: titleView.frame.size.width, height: 30))
        searchBar.placeholder = "搜索内容"
        searchBar.delegate = self
        searchBar.backgroundColor = UIColor.white
        searchBar.layer.cornerRadius = 12
        searchBar.layer.masksToBounds = true
        searchBar.layer.borderWidth = 8
        searchBar.layer.borderColor = UIColor.white.cgColor
        titleView.addSubview(searchBar)
        
        self.searchBar = searchBar
        self.navigationItem.titleView = titleView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(cancelDidClick))
        
        self.heaerView = UIView(frame: CGRect(x: 0, y: 0, width: ScreentWith, height: 0))
        
        
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 20, width: ScreentWith - 20, height: 30))
        titleLabel.text = "热门搜索"
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor.gray
        titleLabel.sizeToFit()
        self.heaerView?.addSubview(titleLabel)
        
        self.tagsView = UIView(frame: CGRect(x: 10, y: titleLabel.frame.origin.y + 30, width: ScreentWith - 20, height: 0))
        self.heaerView?.addSubview(self.tagsView!)
        
        
        self.tableView?.tableHeaderView = self.heaerView
        
        
        let footView = UIView(frame: CGRect(x: 0, y: 0, width: ScreentWith, height: 30))
        let footLabel = UILabel(frame: footView.frame)
        footLabel.textColor = UIColor.gray
        footLabel.font = UIFont.systemFont(ofSize: 13)
        footLabel.isUserInteractionEnabled = true
        footLabel.text = "清空搜索记录"
        footLabel.textAlignment = NSTextAlignment.center
        footLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptySearchHistoryDicClick)))
        footView.addSubview(footLabel)
        
        self.tableView?.tableFooterView = footView
        tagsViewWithTag()

    }
    
    //热门搜索
    
    func tagsViewWithTag() {
        var allLabelWidth = CGFloat(0)
        var allLableHeight = CGFloat(0)
        var rowHeight = CGFloat(0)
    
        
        for i in 0..<self.array.count {
            
            if i != self.array.count - 1 {
                
                let width:CGFloat = getWidthWithTitle(self.array[i+1], UIFont.systemFont(ofSize: 14))
                if (allLabelWidth + width + CGFloat(10)) > (self.tagsView?.frame.size.width)! {
                    rowHeight += CGFloat(1)
                    allLabelWidth = 0.0
                    allLableHeight = rowHeight * 40
                }
            }
            else{
                let width:CGFloat = getWidthWithTitle(self.array[self.array.count - 1], UIFont.systemFont(ofSize: 14))
                if (allLabelWidth + width + CGFloat(10)) > (self.tagsView?.frame.size.width)! {
                    rowHeight += CGFloat(1)
                    allLabelWidth = 0.0
                    allLableHeight = rowHeight * 40
                }
            }
            
            let rectangTagLabel = UILabel()
            rectangTagLabel.isUserInteractionEnabled = true
            rectangTagLabel.font = UIFont.systemFont(ofSize: 14)
            rectangTagLabel.textColor = UIColor.white
            rectangTagLabel.backgroundColor = UIColor.lightGray
            rectangTagLabel.text = self.array[i] as String
            rectangTagLabel.textAlignment = NSTextAlignment.center
            rectangTagLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tagDidCLick(_:))))
            
            let lebelWidth = getWidthWithTitle(self.array[i], UIFont.systemFont(ofSize: 14))
            rectangTagLabel.layer.cornerRadius = 5
            rectangTagLabel.layer.masksToBounds = true
            rectangTagLabel.frame = CGRect(x: allLabelWidth, y: allLableHeight, width: lebelWidth, height: 25)
            self.tagsView?.addSubview(rectangTagLabel)
            
            allLabelWidth = allLabelWidth + CGFloat(10) + lebelWidth
            
        }
        self.tagsView?.frame.size.height = rowHeight * 40 + 40
        self.heaerView?.frame.size.height = (self.tagsView?.frame.origin.y)! + (self.tagsView?.frame.size.height)! + 10
    }
    
    //点击热门搜索
    
    func tagDidCLick(_ sender:UITapGestureRecognizer) {
        
        let label = sender.view as! UILabel
        self.searchBar?.text = label.text
        
        saveSearchCacheAndRefreshView()
        
        self.tableView?.tableFooterView?.isHidden = false
        
        self.searchSuggestionVC.view.isHidden = false
        self.tableView?.isHidden = true
        self.view.bringSubview(toFront: self.searchSuggestionVC.view)
        
        
        NotificationCenter.default.post(NSNotification.init(name: NSNotification.Name(rawValue: "searchBarDidChange"), object: nil, userInfo:["searchText":label.text!] ) as Notification)
        
    }
    
    //标签的大小自适应
    func getWidthWithTitle(_ title:NSString, _ font:UIFont) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 1000, height: 0))
        label.text = title as String
        label.font = font
        label.sizeToFit()
        return label.frame.size.width + CGFloat(10)
    }
    
    //点击右上角的取消按钮
    
    func cancelDidClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //清空搜索的历史数据
    
    func emptySearchHistoryDicClick() {
        self.tableView?.tableFooterView?.isHidden = true
        self.searchHistories .removeAllObjects()
        NSKeyedArchiver .archiveRootObject(self.searchHistories, toFile:self.CachePath as String)
        self.tableView?.reloadData()
    }
    
    //刷新搜索历史界面
    func saveSearchCacheAndRefreshView() {
        let searchBar = self.searchBar
        searchBar?.resignFirstResponder()
        
        
        self.searchHistories.remove(searchBar?.text! as Any)
        self.searchHistories.insert(searchBar?.text! as Any, at: 0)
        
        if self.searchHistories.count > self.searchHistoriesCount! {
            self.searchHistories.remove(lastlogx.self)
        }
        
        NSKeyedArchiver .archiveRootObject(self.searchHistories, toFile: self.CachePath as String)
        
        self.tableView?.reloadData()
    }
    
    
    //tableView的代理方法
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView?.tableFooterView?.isHidden = self.searchHistories.count == 0
        return (self.searchHistories.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let closeBtn  = UIButton()
        closeBtn.frame = cell.frame
        closeBtn.setTitle("X", for: UIControlState.normal)
        closeBtn.addTarget(self, action: #selector(Click(_:)), for: .touchUpInside)
        
        cell.textLabel?.textColor = UIColor.gray
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.textLabel?.text = searchHistories[indexPath.row] as? String
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView .cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: true)
        self.searchBar?.text = cell.textLabel?.text
        
        saveSearchCacheAndRefreshView()
        searchBarSearchButtonClicked(self.searchBar!)
        self.searchSuggestionVC.view.isHidden = false
        self.tableView?.isHidden = true
        self.view.bringSubview(toFront: self.searchSuggestionVC.view)
        
        NotificationCenter.default.post(NSNotification.init(name: NSNotification.Name(rawValue: "searchBarDidChange"), object: nil, userInfo: ["searchText":cell.textLabel?.text! as Any]) as Notification)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchHistories.count != 0 {
            return "搜索历史"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 10, y: 0, width: ScreentWith - 10, height: 60))
        view.backgroundColor = UIColor.white
        
        let titleLabel = UILabel(frame: view.frame)
        titleLabel.text = "搜搜历史"
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.sizeToFit()
        
        view.addSubview(titleLabel)
        
        return view
        
    }
    
    //searchBar的代理方法
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.searchSuggestionVC.view.isHidden = true
            self.tableView?.isHidden = false
        }
        else{
            self.searchSuggestionVC.view.isHidden = false
            self.tableView?.isHidden = true
            self.view.bringSubview(toFront: self.searchSuggestionVC.view)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchBarDidChange"), object: nil, userInfo: ["searchText":searchText])
        }
    }
    
    
    //点击搜索结果的cell
    
    func Click(_ sender:UIButton) {
        
        let cell:UITableViewCell = sender.superview as! UITableViewCell
        
        self.searchHistories.remove(cell.textLabel?.text! as Any)
        
        NSKeyedArchiver .archiveRootObject(self.searchHistories, toFile: filePath)
        if self.searchHistories.count == 0 {
            self.tableView?.tableFooterView?.isHidden = true
        }
        
        self.tableView?.reloadData()
    }
    
    
    //滚动列表收起键盘searchBar变成已响应者
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar?.resignFirstResponder()
    }
    
    
    // searchHistoriesCachePath的setter和getter方法
    var CachePath: NSString {
        get {
            return self.searchHistoriesCachePath! as NSString
        }
        set {
            self.searchHistoriesCachePath = newValue as String!
            self.tableView?.reloadData()
        }
    }
    
    //缓存历史数据的数组的懒加载
    
    
    lazy var searchHistories:NSMutableArray = {
        self.CachePath = filePath as NSString
        var searchHistories = NSKeyedUnarchiver.unarchiveObject(withFile: self.CachePath as String)
        if searchHistories == nil{
            searchHistories = NSMutableArray ()
        }
        return searchHistories as! NSMutableArray
    }()
    
    //搜索结果的控制器的懒加载
    lazy var searchSuggestionVC: SearchResultsController = {
        let searchResultVC = SearchResultsController()
        searchResultVC.closure = {
            (value) in
            if value == ""{
                self.searchBar?.resignFirstResponder()
            }
            else{
                self.searchBar?.text = value
                self.saveSearchCacheAndRefreshView()
            }
        }
        
        searchResultVC.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: searchResultVC.view.frame.size.height)
        searchResultVC.view.backgroundColor = UIColor.white
        self.view.addSubview(searchResultVC.view)
        self.addChildViewController(searchResultVC)
        
        return searchResultVC
    }()
    
    //销毁通知
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
