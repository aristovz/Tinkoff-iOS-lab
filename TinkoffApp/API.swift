//
//  API.swift
//  TinkoffApp
//
//  Created by Pavel Aristov on 22.02.17.
//  Copyright © 2017 aristovz. All rights reserved.
//

import Foundation
import SystemConfiguration

class API {
    //MARK: - getListOfCurrency()
    static open func getListOfCurrency(completion: @escaping (Array<String>, String?) -> Void) {
        self.requestListCurrency() { (data, error) in
            var _error: String? = nil
            var currencies = Array<String>()
            
            if let currentError = error {
                _error = currentError.localizedDescription
            } else {
                self.parseListCurrencyResponse(data: data, completion: { (value, error) in
                    if let parseError = error {
                        _error = parseError
                    }
                    else {
                        currencies = value
                    }
                })
            }
            
            completion(currencies, _error)
        }
    }
    
    fileprivate static func parseListCurrencyResponse(data: Data?, completion: @escaping (Array<String>, String?) -> Void) {
        var value = Array<String>()
        var _error: String? = nil
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    if let base = parsedJSON["base"] as? String {
                        value.append(base)
                    }
                    
                    for (rate, _) in rates {
                        value.append(rate)
                    }
                    completion(value, nil)
                } else {
                    _error = "No \"rates\" field found"
                }
            } else {
                _error = "No JSON value parsed"
            }
        } catch { _error = error.localizedDescription }
        
        completion(value, _error)
    }
    
    fileprivate static func requestListCurrency(parseHandler: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "https://api.fixer.io/latest")
        
        let dataTask = URLSession.shared.dataTask(with: url!) {
            (dataReceived, response, error) in
            parseHandler(dataReceived, error)
        }
        
        dataTask.resume()
    }

    //MARK: - getCurrencyRates()
    static open func getCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (String) -> Void) {
        self.requestCurrencyRates(baseCurrency: baseCurrency) { (data, error) in
            var string = "No currency retrieved!"
            
            if let currentError = error {
                string = currentError.localizedDescription
            } else {
                string = self.parseCurrencyRatesResponse(data: data, toCurrency: toCurrency)
            }
            
            completion(string)
        }
    }
    
    fileprivate static func parseCurrencyRatesResponse(data: Data?, toCurrency: String) -> String {
        var value = ""
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                    } else {
                        value = "No rate for currency \"\(toCurrency)\" found"
                    }
                } else {
                    value = "No \"rates\" field found"
                }
            } else {
                value = "No JSON value parsed"
            }
        } catch { value = error.localizedDescription }
        
        return value
    }
    
    fileprivate static func requestCurrencyRates(baseCurrency: String, parseHandler: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "https://api.fixer.io/latest?base=\(baseCurrency)")
        
        let dataTask = URLSession.shared.dataTask(with: url!) {
            (dataReceived, response, error) in
            parseHandler(dataReceived, error)
        }
        
        dataTask.resume()
    }
}

class Support {
    static open func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
