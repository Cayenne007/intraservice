//
//  Extension +String.swift
//  intraservice
//
//  Created by Cayenne on 08.12.2020.
//

import Foundation
import UIKit

extension String {
    
    var utf8: String {
        return String(utf8String: self.cString(using: .utf8)!) ?? ""
    }
    
    func toDate(_ dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss") -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        //    dateFormat.locale
        dateFormatter.dateFormat = dateFormat
        
        let str = "\(self.prefix(19))"
        
        let date: Date? = dateFormatter.date(from: str)
        return date
        
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func array(by: String) -> [String] {
        let trimmedString = self.replacingOccurrences(of: " ",
                                                     with: "",
                                                     options: .literal)
        
        return trimmedString.components(separatedBy: by)
        
    }
    
    func arrayInt32(by: String) -> [Int32] {
        self.array(by: by).map({Int32($0)!})
    }
    
}
