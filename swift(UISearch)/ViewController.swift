//
//  ViewController.swift
//  swift(UISearch)
//
//  Created by 范云飞 on 2017/8/4.
//  Copyright © 2017年 范云飞. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
       override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 30))
        
        button.backgroundColor = UIColor.black
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        
    }
    
    func click() {
        
        let search:SearchController = SearchController()
        search.array = ["卜卜芥", "卜人参", "卜卜人发", "儿茶", "八角", "三卜七", "广白", "大黄", "大黄", "广卜卜卜丹"]
        
        let nav = UINavigationController(rootViewController: search)
        
        self.present(nav, animated: true) {
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
