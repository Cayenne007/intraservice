//
//  Option.swift
//  intraservice
//
//  Created by Cayenne on 10.12.2020.
//

import UIKit

struct OptionKeys {
    
    var options: [OptionKey] = []
    
    var sections: [String] {
        var array:[String] = []
        options.forEach { (element) in
            if !array.contains(element.section) {
                array.append(element.section)
            }
        }
        return array
    }
    
    func propertie(indexPath: IndexPath) -> OptionKey {
        let sectionName = sections[indexPath.section]
        let properties = options.filter({$0.section == sectionName})
        return properties[indexPath.row]
    }
    
    func propertie(name: String) -> OptionKey {
        options.first { (optionKey) -> Bool in
            optionKey.label == name
        } ?? OptionKey(label: "", value: nil, section: "")
    }
    
    func properties(section: Int) -> [OptionKey] {
        let sectionName = sections[section]
        var array:[OptionKey] = []
        options.forEach { (element) in
            if element.section == sectionName {
                array.append(element)
            }
        }
        return array
    }
    
    mutating func add(label: String, value: Any?, section: String = "", type: OptionKeyType = .option) {
        let option = OptionKey(label: label, value: value, section: section, type: type)
        options.append(option)
    }
    
    func registerCell(tableView: UITableView) {
        let nibOption = UINib(nibName: "OptionTableViewCell", bundle: nil)
        tableView.register(nibOption, forCellReuseIdentifier: "option")
        let nibText = UINib(nibName: "TextTableViewCell", bundle: nil)
        tableView.register(nibText, forCellReuseIdentifier: "text")
        let nibPeriod = UINib(nibName: "PeriodTableViewCell", bundle: nil)
        tableView.register(nibPeriod, forCellReuseIdentifier: "period")
        let nibImage = UINib(nibName: "ImageTableViewCell", bundle: nil)
        tableView.register(nibImage, forCellReuseIdentifier: "image")
    }
    
    func cellOption(_ tableView: UITableView,_ indexPath: IndexPath) -> OptionTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "option", for: indexPath) as! OptionTableViewCell
    }
    func cellText(_ tableView: UITableView,_ indexPath: IndexPath) -> TextTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as! TextTableViewCell
    }
    func cellPeriod(_ tableView: UITableView,_ indexPath: IndexPath) -> PeriodTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "period", for: indexPath) as! PeriodTableViewCell
    }
    func cellImage(_ tableView: UITableView,_ indexPath: IndexPath) -> ImageTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as! ImageTableViewCell
    }
    
}

struct OptionKey {
    
    var label: String
    var value: Any?
    var section = ""
    var type = OptionKeyType.option
    
    var date: Date {
        return value as? Date ?? Date()
    }
    var string: String {
        return value as? String ?? ""
    }
    var int: Int {
        return value as? Int ?? 0
    }
    var bool: Bool {
        return value as? Bool ?? false
    }
    var period: OptionPeriod? {
        return value as? OptionPeriod
    }
    var image: UIImage? {
        guard let data = value as? Data,
              let image = UIImage(data: data) else { return nil }
        return image
    }
    
    var data: Data? {
        return value as? Data
    }
    
    init(label: String, value: Any?, section: String = "", type: OptionKeyType = .option) {
        self.label = label
        self.value = value
        self.section = section
        self.type = type
    }
    
}

struct OptionPeriod {
    
    var isActive: Bool
    var label: String
    var begin: Date
    var end: Date
    
}

struct OptionFile {
    var name: String
    var url: URL
    var data: Data?
    
    init(name: String, data: Data) {
        
        let names = name.array(by: "|")
        self.name = names.count > 1 ? names[1] : "file.txt"
        
        self.url = Files.newTempFile(name: self.name)
        
        self.data = data
    }
    
    func write() -> URL? {
        guard let data = data, let _ = try? data.write(to: url) else { return nil }
        return url
    }
}

enum OptionKeyType {
    case title
    case body
    case option
    case text
    case period
    case file
}
