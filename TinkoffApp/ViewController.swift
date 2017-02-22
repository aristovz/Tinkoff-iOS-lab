//
//  ViewController.swift
//  TinkoffApp
//
//  Created by Pavel Aristov on 22.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fromCurrencyField: UITextField!
    @IBOutlet weak var toCurrencyField: UITextField!
    
    @IBOutlet weak var fromValueField: UITextField!
    @IBOutlet weak var toValueLabel: UILabel!
    
    @IBOutlet weak var currentRateLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var currencies = Array<String>()
    var currenciesExceptBase: Array<String> {
        get {
            var _currenciesExceptBase = currencies
            _currenciesExceptBase.remove(at: fromPickerView.selectedRow(inComponent: 0))
            return _currenciesExceptBase
        }
    }
    
    var currentRate = 1.0
    
    var fromPickerView = UIPickerView()
    var toPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePicker))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        fromPickerView.delegate = self
        fromPickerView.showsSelectionIndicator = true
        fromCurrencyField.inputView = fromPickerView
        fromCurrencyField.inputAccessoryView = toolBar
        
        toPickerView.delegate = self
        toPickerView.showsSelectionIndicator = true
        toCurrencyField.inputView = toPickerView
        toCurrencyField.inputAccessoryView = toolBar
        
        API.getListOfCurrency { (value, error) in
            if let currentError = error {
                print(currentError)
            } else {
                self.currencies = value
                
                DispatchQueue.main.async(execute: {
                    if self.currencies.count > 1 {
                        self.fromPickerView.reloadAllComponents()
                        self.toPickerView.reloadAllComponents()
                        
                        self.pickerView(self.fromPickerView, didSelectRow: 0, inComponent: 0)
                        self.pickerView(self.toPickerView, didSelectRow: 0, inComponent: 0)
                    }
                })
            }
        }
    }

    func donePicker() {
        self.view.endEditing(true)
    }
    
    @IBAction func changeFromValue(_ sender: UITextField) {
        if let inputValue = Double(fromValueField.text!.replacingOccurrences(of: ",", with: ".")) {
            toValueLabel.text = "\(inputValue * currentRate)"
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == fromPickerView ? currencies.count : currenciesExceptBase.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == fromPickerView ? currencies[row] : currenciesExceptBase[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let baseCurrencyIndex = self.fromPickerView.selectedRow(inComponent: 0)
        let toCurrencyIndex = self.toPickerView.selectedRow(inComponent: 0)
        
        let baseCurrency = currencies[baseCurrencyIndex]
        let toCurrency = currenciesExceptBase[toCurrencyIndex]
        
        fromCurrencyField.text = baseCurrency
        toCurrencyField.text = toCurrency
        activityIndicator.startAnimating()
        currentRateLabel.isHidden = true
        
        API.getCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) { (value) in
            DispatchQueue.main.async(execute: {
                self.activityIndicator.stopAnimating()
                self.currentRateLabel.isHidden = false
                
                self.currentRateLabel.text = "1 \(baseCurrency) = \(value) \(toCurrency)"

                if let doubleValue = Double(value) {
                    self.currentRate = doubleValue
                }
                
                if let inputValue = Double(self.fromValueField.text!.replacingOccurrences(of: ",", with: ".")) {
                    self.toValueLabel.text = "\(inputValue * self.currentRate)"
                }
            })
        }
    }
}
