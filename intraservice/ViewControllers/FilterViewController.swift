//
//  FilterViewController.swift
//  intraservice
//
//  Created by Cayenne on 06.12.2020.
//

import UIKit

class FilterViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var options: OptionKeys = OptionKeys()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        options.add(label: "Исполнители", value: Filter.shared.executors)
        options.add(label: "Авторы кроме", value: Filter.shared.creatorExclude)
        options.add(label: "Уведомлять", value: Filter.shared.newTaskNotification)

        let createdPeriod = OptionPeriod(isActive: Filter.shared.dateIsActive,
                                         label: "Создана",
                                         begin: Filter.shared.beginDate,
                                         end: Filter.shared.endDate)
        let changedPeriod = OptionPeriod(isActive: Filter.shared.changedDateIsActive,
                                         label: "Изменена",
                                         begin: Filter.shared.changedBeginDate,
                                         end: Filter.shared.changedEndDate)

        options.add(label: "Создана", value: createdPeriod, section: "Создана", type: .period)
        options.add(label: "Изменена", value: changedPeriod, section: "Изменена", type: .period)

        options.add(label: "Открыта", value: Filter.shared.status(.open), section: "")
        options.add(label: "На согласовании", value: Filter.shared.status(.approval), section: "")
        options.add(label: "Отменена", value: Filter.shared.status(.cancel), section: "")
        options.add(label: "Выполнена", value: Filter.shared.status(.ready), section: "")
        options.add(label: "Запрос данных", value: Filter.shared.status(.queue), section: "")
        options.add(label: "В процессе", value: Filter.shared.status(.process), section: "")
        options.add(label: "Закрыта", value: Filter.shared.status(.close), section: "")
        
        options.registerCell(tableView: tableView)
        
        hideKeyboardWhenTappedAround()
        
        
        
//        let printToConsole = UIMenuItem(title: "1С", action: #selector(printToConsole(_:)))
//        UIMenuController.shared.menuItems = [printToConsole]

    }
    
    @IBAction func confirmClicked() {
        
        Filter.shared.save()
        DataSource.shared.reloadData{
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}


extension FilterViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                         action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func hideKeyboard() {
        
        view.endEditing(true)
    }
    
//    @objc func executorsTurnBack(_ sender: Any) {
//        executorsTextField.text = "Сухов,Голубенко,Тюхтин,Ищук,Гаврилюк,Биленко"
//    }
}


extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        options.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.properties(section: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let propertie = options.propertie(indexPath: indexPath)
        
        if propertie.type == .period {
            let cell = options.cellPeriod(tableView, indexPath)
            cell.set(propertie: propertie) { period in
                
                if period.label == "Создана" {
                    Filter.shared.dateIsActive = period.isActive
                    Filter.shared.beginDate = period.begin
                    Filter.shared.endDate = period.end
                } else if period.label == "Изменена" {
                    Filter.shared.changedDateIsActive = period.isActive
                    Filter.shared.changedBeginDate = period.begin
                    Filter.shared.changedEndDate = period.end
                }
            }
            return cell
        } else {
            let cell = options.cellOption(tableView, indexPath)
            cell.set(propertie: propertie) { option in
                if option.label == "Исполнители" {
                    Filter.shared.executors = option.string
                }
                if option.label == "Авторы кроме" {
                    Filter.shared.creatorExclude = option.string
                }
                
                if option.label == "Уведомлять" {
                    Filter.shared.newTaskNotification = option.bool
                }
                
                if option.label == "Создана" {
                    Filter.shared.beginDate = option.period?.begin ?? Date()
                    Filter.shared.endDate = option.period?.end ?? Date()
                }
                if option.label == "Изменена" {
                    Filter.shared.changedBeginDate = option.period?.begin ?? Date()
                    Filter.shared.changedEndDate = option.period?.end ?? Date()
                }
                
                if option.label == "Открыта" {
                    Filter.shared.status[.open] = option.bool
                }
                if option.label == "На согласовании" {
                    Filter.shared.status[.approval] = option.bool
                }
                if option.label == "Отменена" {
                    Filter.shared.status[.cancel] = option.bool
                }
                if option.label == "Запрос данных" {
                    Filter.shared.status[.queue] = option.bool
                }
                if option.label == "В процессе" {
                    Filter.shared.status[.process] = option.bool
                }
                if option.label == "Выполнена" {
                    Filter.shared.status[.ready] = option.bool
                }
                if option.label == "Закрыта" {
                    Filter.shared.status[.close] = option.bool
                }
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let propertie = options.propertie(indexPath: indexPath)
        
        if propertie.type == .period {
            return 90
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        options.sections[section]
//    }
    
    
}
