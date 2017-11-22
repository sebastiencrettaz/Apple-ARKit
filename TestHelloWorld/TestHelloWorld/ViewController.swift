//
//  ViewController.swift
//  TestHelloWorld
//
//  Created by Lin on 13.10.17.
//  Copyright © 2017 Human Tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var countClick = 0

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClic: UIButton!
    @IBAction func btnAction(_ sender: UIButton) {
        lblTitle.text = "Click"+String(countClick)
        countClick = countClick + 1
        lblTitle.sizeToFit()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

