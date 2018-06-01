//
//  ComplicationController.swift
//  BitPrice WatchKit Extension
//
//  Created by Ana Neto on 31/05/2018.
//  Copyright © 2018 Ana Neto. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        let template = CLKComplicationTemplateModularLargeTallBody()
        
        if let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json") {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                if let data = data, error == nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            guard let bpi = json["bpi"] as? [String: Any], let usd = bpi["USD"] as? [String: Any], let rate = usd["rate_float"] as? Double else {
                                
                                template.headerTextProvider = CLKSimpleTextProvider(text: "Bit")
                                template.bodyTextProvider = CLKSimpleTextProvider(text: "---")
                                return
                            }
                            
                            template.headerTextProvider = CLKSimpleTextProvider(text: "Bit")
                            template.bodyTextProvider = CLKSimpleTextProvider(text: "$ \(Int(rate))")
                            UserDefaults.standard.set(rate, forKey: "bitcoinPrice")
                        }
                    } catch {}
                    
                } else {
                    template.headerTextProvider = CLKSimpleTextProvider(text: "Bit")
                    template.bodyTextProvider = CLKSimpleTextProvider(text: "---")
                }
                
                let timeEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
                handler(timeEntry)
                
                }.resume()
        }
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        
        let template = CLKComplicationTemplateModularLargeTallBody()
        template.headerTextProvider = CLKSimpleTextProvider(text: "Bit")
        template.bodyTextProvider = CLKSimpleTextProvider(text: "---")
        
        handler(template)
    }
    
}
