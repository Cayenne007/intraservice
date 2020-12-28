//
//  ImageTableViewCell.swift
//  intraservice
//
//  Created by Cayenne on 12.12.2020.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var fileView: UIImageView!
    
    @IBOutlet weak var fileName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(propertie: OptionFile) {
        
        fileName.text = propertie.name
        
        if let data = propertie.data, let image = UIImage(data: data) {
            imageView?.image = image
        } else {
            imageView?.image = UIImage(systemName: "folder")
            imageView?.sizeToFit()
        }
    
    }
    
}
