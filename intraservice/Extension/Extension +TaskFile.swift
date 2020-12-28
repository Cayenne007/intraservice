//
//  Extension +TaskFile.swift
//  intraservice
//
//  Created by Vladlen Sukhov on 27.12.2020.
//

import SwiftUI

extension TaskFile {
    
    func getImage() -> Image {
        guard let data = data,
              let uiImage = UIImage(data: data) else { return Image(systemName: "photo") }
        return Image(uiImage: uiImage)
                
    }
        
}
