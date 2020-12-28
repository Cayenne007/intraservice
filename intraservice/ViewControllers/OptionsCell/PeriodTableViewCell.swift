//
//  TaskLabelTableViewCell.swift
//  intraservice
//
//  Created by Cayenne on 10.12.2020.
//

import UIKit


class PeriodTableViewCell: UITableViewCell {

    
    @IBOutlet weak var isActiveSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var beginDataPicker: UIDatePicker!
    @IBOutlet weak var dateToDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    private var valueChanged: ((OptionPeriod) -> ())!
    private var period: OptionPeriod!

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func isActiveChanged() {
        updatePeriod()
        valueChanged(period)
    }
    @IBAction func beginDateChanged() {
        updatePeriod()
        valueChanged(period)
    }
    @IBAction func endDateChanged() {
        updatePeriod()
        valueChanged(period)
    }
    
    
    private func updatePeriod() {
        period.isActive = isActiveSwitch.isOn
        period.begin = beginDataPicker.date.startOfDay
        period.end = endDatePicker.date.endOfDay
        setEnabled()
    }
    
    
    func set(propertie: OptionKey,_ didChange: @escaping (OptionPeriod) -> ()) {
        
        valueChanged = didChange
        
        period = propertie.period
        titleLabel.text = propertie.label
        isActiveSwitch.isOn = period.isActive
        beginDataPicker.date = period.begin.startOfDay
        beginDataPicker.timeZone = TimeZone.current
        endDatePicker.date = period.end.endOfDay
        endDatePicker.timeZone = TimeZone.current
        
        beginDataPicker.isEnabled = period.isActive
        dateToDateLabel.isEnabled = period.isActive
        endDatePicker.isEnabled = period.isActive
        
    }
    
    private func setEnabled() {
        beginDataPicker.isEnabled = period.isActive
        dateToDateLabel.isEnabled = period.isActive
        endDatePicker.isEnabled = period.isActive
    }
    
}

