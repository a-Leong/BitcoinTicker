//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Alex Leong on 10/18/18.


import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    enum priceType {
        case ask
        case bid
    }
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbols = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]
    var finalURL = ""
    var askPrice : Double?
    var bidPrice : Double?
    var curCurrencySymbol : String?
    var curPriceType : priceType?

    //Pre-setup IBOutlets
    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var priceToggle: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        priceToggle.setTitle("Ask Price", for: .normal)
        curPriceType = .ask
    }

    @IBAction func priceTogglePressed(_ sender: Any) {
        if curPriceType == .ask {
            priceToggle.setTitle("Bid Price", for: .normal)
            curPriceType = .bid
        } else if curPriceType == .bid {
            priceToggle.setTitle("Ask Price", for: .normal)
            curPriceType = .ask
        }
        updateUIWithValueData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        curCurrencySymbol = currencySymbols[row]
        finalURL = "\(baseURL)\(currencyArray[row])"
        getBTCData(url : finalURL)
    }
    
    
    
//    //MARK: - Networking
//    /***************************************************************/
    
    func getBTCData(url: String) {
        
        Alamofire.request(url, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {

                    print("Success! Got Bitcoin data")
                    let BTCJSON : JSON = JSON(response.result.value!)

                    self.updateBTCData(json: BTCJSON)

                } else {
                    print("Error: \(String(describing: response.result.error))")
                    self.bitcoinPriceLabel.text = "Connection Issues"
                }
            }

    }
    
    
//    //MARK: - JSON Parsing
//    /***************************************************************/
    
    func updateBTCData(json : JSON) {
        
        if let askValue = json["ask"].double {
            askPrice = askValue
            bidPrice = json["bid"].double
            updateUIWithValueData()
        } else {
            bitcoinPriceLabel.text = "Value Unavailable"
        }
    }
    
    func updateUIWithValueData() {
        if curPriceType == .ask {
            bitcoinPriceLabel.text = "\(curCurrencySymbol!)\(askPrice!)"
        } else if curPriceType == .bid {
            bitcoinPriceLabel.text = "\(curCurrencySymbol!)\(bidPrice!)"
        }
    }
}
