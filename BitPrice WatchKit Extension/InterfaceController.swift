//
//  InterfaceController.swift
//  BitPrice WatchKit Extension
//
//  Created by Ana Neto on 31/05/2018.
//  Copyright © 2018 Ana Neto. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var bitcoinPriceLabel: WKInterfaceLabel!
    @IBOutlet var updatingLabel: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        bitcoinPriceLabel.setText(formatPrice(of: UserDefaults.standard.double(forKey: "bitcoinPrice")))
        getPrice()
        updatingLabel.setText("Updating...")
    }
    
    func getPrice() {
        if let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json") {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if data != nil && error == nil {
                    self.processBitCoinPrice(with: data!)
                } else {
                    self.updatingLabel.setText("Not updated.")
                }
                
            }.resume()
        }
    }
    
    func processBitCoinPrice(with data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                guard let bpi = json["bpi"] as? [String: Any], let usd = bpi["USD"] as? [String: Any], let rate = usd["rate_float"] as? Double else {
                    
                    self.updatingLabel.setText("Not updated.")
                    return
                }
                
                bitcoinPriceLabel.setText(formatPrice(of: rate))
                updatingLabel.setText("Updated")
                UserDefaults.standard.set(rate, forKey: "bitcoinPrice")
                
                if let complications = CLKComplicationServer.sharedInstance().activeComplications {
                    for complication in complications  {
                        CLKComplicationServer.sharedInstance().reloadTimeline(for: complication)
                    }
                }
            }
        } catch {}
    }
    
    func formatPrice(of value: Double) -> String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        
        return formatter.string(from: NSNumber(value: value))
    }
}
