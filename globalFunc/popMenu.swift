//
//  pop.swift
//  slide
//
//  Created by Admin on 28/1/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit

class popMenu: UIViewController {
    var theParrent: AnyClass? = nil;


    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.frame =  CGRect(x:0, y:50, width:100, height:200);
       showAnimate()
        //self.view.alpha = 1
        //self.view.frame.size.width = 100;
    }


@IBAction func Close_popupView(_ sender: Any) {
    removeAnimate()
}

func showAnimate()
{
    self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    self.view.alpha = 0.0
    UIView.animate(withDuration: 0.25, animations: {
        self.view.alpha = 1.0
        self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    })
}

func removeAnimate()
{
    UIView.animate(withDuration: 0.25, animations: {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
    }, completion: {(finished : Bool) in
        if(finished)
        {
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    })
}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
