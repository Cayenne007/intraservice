//
//  FilterFieldTableViewCell.swift
//  intraservice
//
//  Created by Cayenne on 10.12.2020.
//

import UIKit

class OptionTableViewCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var boolSwitch: UISwitch!
    
    private var option: OptionKey!
    private var delegate: ((OptionKey) -> ())!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func boolDidChanged() {
        option.value = boolSwitch.isOn
        delegate(option)
    }
    @IBAction func dateDidChanged() {
        option.value = datePicker.date
        delegate(option)
    }
    @IBAction func textDidChanged(_ sender: Any) {
        option.value = optionTextField.text
        delegate(option)
    }
    
    func set(propertie: OptionKey,_ didChange: @escaping (OptionKey) -> ()) {
        
        option = propertie
        delegate = didChange
        
        optionLabel.text = propertie.label
        
        optionTextField.isHidden = true
        datePicker.isHidden = true
        datePicker.timeZone = TimeZone.current
        boolSwitch.isHidden = true
        
        if let value = propertie.value as? String {
            optionTextField.text = value
            optionTextField.isHidden = false
        }
        if let value = propertie.value as? Date {
            datePicker.date = value
            datePicker.isHidden = false
        }
        if let value = propertie.value as? Bool {
            boolSwitch.isOn = value
            boolSwitch.isHidden = false
        }
        
    }
    
}
