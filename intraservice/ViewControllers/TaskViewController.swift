//
//  TaskViewController.swift
//  intraservice
//
//  Created by Cayenne on 04.12.2020.
//

import UIKit
import QuickLook

class TaskViewController: UIViewController {

    var task: Task!
    @IBOutlet weak var tableView: UITableView!
    var options: OptionKeys = OptionKeys()
    
    var previewUrls: [URL] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let status = StorageManager.shared.fetchProperty(type: String.self, data: task, name: "status", property: "name") ?? ""

        title = "Заявка №\(task.id)"
        
        options.add(label: "Заголовок", value: task.name, section: "Заголовок", type: .title)
        options.add(label: "Дата создания", value: task.created, section: "Реквизиты")
        options.add(label: "Автор", value: task.creator, section: "Реквизиты")
        options.add(label: "Статус", value: status, section: "Реквизиты")
        options.add(label: "Тип", value: task.type, section: "Реквизиты")
        options.add(label: "Исполнители", value: task.executorsText, section: "Реквизиты")
        options.add(label: "Текст", value: task.text, section: "Текст", type: .body)
        
        options.registerCell(tableView: tableView)
        
        loadTaskFiles()
        
        tableView.reloadData()
        
    }
    
    func loadTaskFiles() {
        
        guard let idsString = task.fileIds, !idsString.isEmpty else { return }
        
        let ids = idsString.array(by: ",")
        let names = task.fileNames!.array(by: ",")
        
        for i in 0...ids.count - 1 {
            
            guard let id = Int32(ids[i]) else { continue }
            
            let name = names[i]
            
            if let file = StorageManager.shared.fetch(TaskFile.self, id: id),
               let data = file.data {
                addFile(name: file.name, data: data)
                tableView.reloadData()
            } else {
                NetworkManager.shared.fetchTaskFile(id: id, name: name) { data in
                    self.addFile(name: name, data: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                }
            }
        }
                
    }
    
    func addFile(name: String?, data: Data) {
        let file = OptionFile(name: name ?? "file.txt", data: data)
        options.add(label: "Картинка",
                    value: file,
                    section: "Картинка",
                    type: .file)
        if let url = file.write() {
            previewUrls.append(url)
        }
    }

}

extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        options.sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        options.sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.properties(section: section).count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let propertie = options.propertie(indexPath: indexPath)
        
        if propertie.section == "Текст" || propertie.section == "Заголовок" {
    
            let cell = options.cellText(tableView, indexPath)
            
            if propertie.section == "Заголовок" {
                cell.textView.font = UIFont(name: cell.textView.font!.fontName, size: 18)
                cell.set(propertie: propertie, showLabel: false)
            } else {
                cell.set(propertie: propertie)
            }
            
            return cell
            
        } else if propertie.section == "Картинка" {
            
            let cell = options.cellImage(tableView, indexPath)
            if let file = propertie.value as? OptionFile {
                cell.set(propertie: file)
            }
                
            return cell
            
        } else {
            
            let cell = options.cellOption(tableView, indexPath)
            cell.set(propertie: propertie) { option in
                
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let propertie = options.propertie(indexPath: indexPath)
        
        if propertie.section == "Заголовок" {
            return 80
        } else if propertie.section == "Текст", let value = propertie.value as? String {
            return value.heightWithConstrainedWidth(width: tableView.frame.width, font: UIFont.systemFont(ofSize: 14)) + 45
        } else if propertie.section == "Картинка" {
            return 60
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
        
        guard let file = options.propertie(indexPath: indexPath).value as? OptionFile else { return }
        
        guard let index = previewUrls.firstIndex(where: {$0 == file.url}) else { return }
        
        let quickLookViewController = QLPreviewController()
        quickLookViewController.dataSource = self
        quickLookViewController.currentPreviewItemIndex = index
        self.present(quickLookViewController, animated: true)
        
    }
    
}


//MARK: NSFetchedResultsControllerDelegate
extension TaskViewController: QLPreviewControllerDataSource {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        previewUrls.count
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        return previewUrls[index] as QLPreviewItem
    }
}
