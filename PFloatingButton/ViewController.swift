//
//  ViewController.swift
//  PFloatingButton
//
//  Created by 邓杰豪 on 2016/9/2.
//  Copyright © 2016年 邓杰豪. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let bbbbbbbbbbb = PFloatingButton()
        bbbbbbbbbbb.initInKeyWindowWithFrame(CGRectMake(0, 100, 100, 100))
        bbbbbbbbbbb.backgroundColor = UIColor.redColor()
        self.view.addSubview(bbbbbbbbbbb)

        print(bbbbbbbbbbb.version())

        bbbbbbbbbbb.longPressBlock = {(button: PFloatingButton!) -> Void in
            NSLog("long")
        }
        bbbbbbbbbbb.doubleTapBlock = {(button: PFloatingButton!) -> Void in
            NSLog("double")
        }
        bbbbbbbbbbb.setTapBlocks {(button: PFloatingButton!) -> Void in
            NSLog("tap")
        }
        bbbbbbbbbbb.draggingBlock =  {(button: PFloatingButton!) -> Void in
            NSLog("dragging")
        }
        bbbbbbbbbbb.dragDoneBlock =  {(button: PFloatingButton!) -> Void in
            NSLog("dragDoneBlock")
        }
        bbbbbbbbbbb.autoDockingBlock =  {(button: PFloatingButton!) -> Void in
            NSLog("autoDockingBlock")
        }
        bbbbbbbbbbb.autoDockingDoneBlock =  {(button: PFloatingButton!) -> Void in
            NSLog("autoDockingDoneBlock")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

