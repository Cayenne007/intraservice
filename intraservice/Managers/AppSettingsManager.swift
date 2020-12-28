//
//  AppSettingsManager.swift
//  Intraservice
//
//  Created by Cayenne
//

import Foundation


struct AppSettingsManager {
    
    static func saveSettings() {
        let result = try? JSONEncoder().encode(Filter.shared.self)
        UserDefaults.standard.setValue(result, forKey: "Filter")
    }
    
    static func loadSettings() -> Filter? {
        guard let json = UserDefaults.standard.object(forKey: "Filter") as? Data else { return nil }
        return try? JSONDecoder().decode(Filter.self, from: json)
    }
    
}

