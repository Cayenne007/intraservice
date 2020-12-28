//
//  Extension +Date.swift
//  intraservice
//
//  Created by Cayenne on 08.12.2020.
//

import Foundation

extension Date {
    
    var startOfDay: Date {
        //Calendar.current.startOfDay(for: self)
        //Calendar.current.startOfDay(for: Date())
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!

    }
    
    var endOfDay: Date {
        
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
        
    }
    
    func toString(_ dateFormat: String = "yyyy-MM-dd") -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.current
        
        return dateFormatter.string(from: self)
        
    }
    
}
