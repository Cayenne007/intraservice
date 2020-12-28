//
//  TaskListTableViewCell.swift
//  intraservice
//
//  Created by Cayenne on 11.12.2020.
//

import UIKit

class TaskListTableViewCell: UITableViewCell {

    @IBOutlet weak var dateNumberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var filesImageView: UIImageView!
    
    
    @IBOutlet weak var creatorStackView: UIStackView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(task: Task, searchType: String) {
        let status = StorageManager.shared.fetchProperty(type: String.self,
                                                         data: task,
                                                         name: "status",
                                                         property: "name")
        
        dateNumberLabel.text = "№\(task.id) от \(task.created!.toString())"
        statusLabel.text = status
        if searchType == "creator" {
            creatorStackView.isHidden = true
        } else {
            creatorStackView.isHidden = false
            creatorLabel.text = task.creator
        }
        
        filesImageView.image = (task.fileIds?.isEmpty ?? true) ? nil : UIImage(systemName: "paperclip")
        
        titleLabel.text = task.name
        bodyLabel.text = task.text
    
    }
    
}
