//
//  AuthorizationManager.swift
//  intraservice
//
//  Created by user184795 on 22.12.2020.
//

import Foundation

class AuthorizationManager: Codable {
    
    static var standart = AuthorizationManager()
    
    var login = ""
    var pass = ""
    
    var loginPass: String {
        "\(login):\(pass)"
    }
    
    var reportsLogin = ""
    var reportsPass = ""
    
    var reportsLoginPass: String {
        "\(reportsLogin):\(reportsPass)"
    }
    var reportsServer = ""
    
    var reportsUrl: URL {
        URL(string: reportsServer)!
    }
    
    
    private init() {
        
        let json: SettingsJson!
        
        if let data = try? Data(contentsOf: Files.authorizationFile) {
            json = try? JSONDecoder().decode(SettingsJson.self, from: data)
        } else {
            guard let defaultSettings = Bundle.main.url(forResource: "authorization", withExtension: "json"),
                  let data = try? Data(contentsOf: defaultSettings) else { return }
            json = try? JSONDecoder().decode(SettingsJson.self, from: data)
        }
    
        let authorization = json.authorization

        self.login = authorization.login
        self.pass = authorization.pass
        self.reportsLogin = authorization.reportsLogin
        self.reportsPass = authorization.reportsPass
        self.reportsServer = authorization.reportsServer
        
        if Filter.shared.settingsLoaded == false {
            Filter.shared.changedDateIsActive = json.filter.changedDateIsActive
            Filter.shared.changedBeginDate = json.filter.changedBeginDate
            Filter.shared.changedEndDate = json.filter.changedEndDate
            Filter.shared.executors = json.filter.executors
        }
        
    }
    
}


struct SettingsJson: Codable {
    let authorization: AuthorizationManager
    let filter: Filter
}

