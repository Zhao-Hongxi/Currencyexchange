//
//  ViewController.swift
//  Currencyexchange
//
//  Created by ivan on 2021/10/18.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftSpinner
import PromiseKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    
    
    let baseURL = "http://api.exchangeratesapi.io/v1/"
    let apiKEY = "ce6c3739104f2530f7a4d7e2a29e7e89"
    var exchangeRates = [String: JSON]()
    var pickerFromList :[String] = []
    var pickerToList :[String] = []
    
    
    @IBOutlet weak var pickerFrom: UIPickerView!
    
    @IBOutlet weak var pickerTo: UIPickerView!
    
    @IBOutlet weak var lblRate: UILabel!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return self.pickerFromList.count
        } else {
            return self.pickerToList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return self.pickerFromList[row]
        } else {
            return self.pickerToList[row]
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        loadData().done { rates in
            self.exchangeRates = rates
            self.pickerFromList = Array(self.exchangeRates.keys).sorted()
            self.pickerToList = Array(self.exchangeRates.keys).sorted()
            self.computeRate()
            self.pickerTo.reloadAllComponents()
            self.pickerFrom.reloadAllComponents()
            self.pickerFrom.selectRow(0, inComponent: 0, animated: true)
            self.pickerTo.selectRow(0, inComponent: 0, animated: true)
        }.catch { error in
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func loadData() -> Promise<[String:JSON]> {
        SwiftSpinner.show("Loading")
        return Promise<[String:JSON]> { seal -> Void in
                
            let url = baseURL + "latest?access_key=" + apiKEY
            
            AF.request(url).responseJSON{ response in
                
                if response.error != nil {
                    seal.reject(response.error!)
                }
                
                let res = JSON(response.data!).dictionary
                let rates = res!["rates"]!.dictionary
//                let fromRate = rates!["USD"]?.number
                SwiftSpinner.hide()
                seal.fulfill(rates!)
                print("yes")
                
            }

       }
   }
 
        

    @IBAction func refreshButton(_ sender: Any) {
        loadData().done { rates in
            self.exchangeRates = rates
            self.pickerFromList = Array(self.exchangeRates.keys).sorted()
            self.pickerToList = Array(self.exchangeRates.keys).sorted()
            self.computeRate()
            self.pickerTo.reloadAllComponents()
            self.pickerFrom.reloadAllComponents()
            self.pickerFrom.selectRow(0, inComponent: 0, animated: true)
            self.pickerTo.selectRow(0, inComponent: 0, animated: true)
        }.catch { error in
            print(error)
        }
    }
    
    @IBAction func rateButton(_ sender: Any) {
        computeRate()
    }
    
    func computeRate() -> Void {
        
        let fromCurrency = self.pickerFromList[self.pickerFrom.selectedRow(inComponent: 0)]
        let toCurrency = self.pickerToList[self.pickerTo.selectedRow(inComponent: 0)]
        let fromRate = self.exchangeRates[fromCurrency]!.doubleValue
        let toRate = self.exchangeRates[toCurrency]!.doubleValue
        let rate = toRate / fromRate
        lblRate.text = "1 \(fromCurrency) = \(rate) \(toCurrency)"
    }
}


