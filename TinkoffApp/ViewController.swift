//
//  ViewController.swift
//  TinkoffApp
//
//  Created by Pavel Aristov on 22.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var fromCurrencyLabel: UILabel!
    @IBOutlet weak var toCurrencyLabel: UILabel!
    
    @IBOutlet weak var fromValueField: UITextField!
    @IBOutlet weak var toValueLabel: UILabel!
    
    @IBOutlet weak var currentRateLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func changeCurrencyButtonAction(_ sender: UIButton) {
        
    }
    
    
}

