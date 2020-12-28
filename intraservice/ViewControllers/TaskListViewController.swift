//
//  TaskListViewController.swift
//  intraservice
//
//  Created by Cayenne on 04.12.2020.
//

import UIKit
import SwiftUI
import QuickLook
import MessageUI


class TaskListViewController: UITableViewController {
    

    var reportFileUrl: URL?
    
    var searchController: UISearchController!
    var searchBar: UISearchBar {
        searchController.searchBar
    }
    var searchText: String {
        (searchController.isActive ? searchBar.text ?? "" : "").lowercased()
    }
    var searchType: String {
        switch searchBar.selectedScopeButtonIndex {
        case 1:
            return "creator"
        case 2:
            return "executorsText"
        default:
            return ""
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupViewController()
        updateTable()
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let taskVC = segue.destination as? TaskViewController, let sender = sender as? Task {
            taskVC.task = sender
        }
    }
    
    private func setupViewController() {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self

        searchBar.scopeButtonTitles = ["Списком", "По автору", "По исполнителю"]
        searchBar.autocapitalizationType = .none
        searchBar.placeholder = "Поиск"
        searchBar.showsScopeBar = true
        (searchBar.value(forKey: "cancelButton") as! UIButton).setTitle("Отмена", for: .normal)
        searchBar.delegate = self

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = false
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControllRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        let sendButton = UIBarButtonItem(image: UIImage(systemName: "mail"),
                                         style: .done,
                                         target: self,
                                         action: #selector(sendButtonClick(_:)))
        navigationItem.leftBarButtonItems?.append(sendButton)
        
        let nib = UINib(nibName: "TaskListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "byAuthor")
        
        registerTableViewUpdateNotification()
        
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AuthorizationManager.standart.login.isEmpty {
            showAlert(alertText: "Настройки не найдены!", alertMessage: "Поместите файл authorization.json в папку приложения")
        }
    }
    
    @objc func refreshControllRefresh() {
        
        NetworkManager.shared.fetchData { (page, pages) in
            DispatchQueue.main.async {
                self.refreshControl?.attributedTitle = NSAttributedString(string: "Загрузка \(page) из \(pages)")
            }
        } _: {            
            self.updateTable()
            self.refreshControl?.endRefreshing()
            self.refreshControl?.attributedTitle = nil
        }
        
    }
    
    @IBAction func shareButtonClick(_ sender: Any) {
        
        NetworkManager.shared.getReport { result, error in
            guard let result = result else {
                self.showAlert(alertText: "Результат", alertMessage: error!)
                return
            }
            
            self.reportFileUrl = result
            
            DispatchQueue.main.async {
                let quickLookViewController = QLPreviewController()
                quickLookViewController.dataSource = self
                quickLookViewController.currentPreviewItemIndex = 0
                self.present(quickLookViewController, animated: true)
            }
            
        }

    }
    
    @IBAction func openFilter(_ sender: Any) {
        var filterView = FilterView()
        filterView.dismiss = {
            self.dismiss(animated: true)
        }
        let hostingView = UIHostingController(rootView: filterView)
        present(hostingView, animated: true)
        //performSegue(withIdentifier: "toFilter", sender: nil)
    }
    
    func updateTable() {
        
        Filter.shared.searchType = searchType
        Filter.shared.searchText = searchText
        DataSource.shared.reloadData {
            self.tableView.reloadData()
            self.title = "Задачи \(DataSource.shared.rows.count)"
        }
        
    }
    
}

//MARK: NSFetchedResultsControllerDelegate
extension TaskListViewController: QLPreviewControllerDataSource {
  
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return reportFileUrl! as QLPreviewItem
    }
}


//MARK: UITableViewDataSource
extension TaskListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        DataSource.shared.sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        DataSource.shared.sectionName(section: section)
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchType.isEmpty {
            return DataSource.shared.rows.count
        } else {
            return DataSource.shared.sections[section].numberOfObjects
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let task = DataSource.shared.task(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "byAuthor", for: indexPath) as! TaskListTableViewCell
        
        if let task = task {
            cell.set(task: task, searchType: searchType)
        }
        
        return cell
    }
    
}

//MARK: UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let task = DataSource.shared.task(indexPath: indexPath) else { return }
        
        let view = TaskView(task: task)
        let vc = UIHostingController(rootView: view)
        
        navigationController?.pushViewController(vc, animated: true)
    
//        performSegue(withIdentifier: "toTask", sender: task)
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
}


//MARK: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate
extension TaskListViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        updateTable()
    }
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        updateTable()
    }
    
}



//MARK: Отправка отчета по почте
extension TaskListViewController : MFMailComposeViewControllerDelegate{
    
    func sendEmail() {
        
        guard let url = reportFileUrl else {
            showAlert(alertText: "Ошибка", alertMessage: "Необходимо получить отчет")
            return
        }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Отчет по заявкам за период: \(Filter.shared.changedBeginDate.toString("dd.MM.yy")) по \(Filter.shared.changedEndDate.toString("dd.MM.yy"))")
            
            guard let data = try? Data(contentsOf: url) else { return }
            
                mail.addAttachmentData(data, mimeType: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", fileName: "Отчет.xlsx")
            
            
            let count = StorageManager.shared.count(Filter.shared.predicate(filter: ""))
            
            mail.setMessageBody("""
                <p>Всего заявок в выбранных статусах: \(count)</p>
                """, isHTML: true)

            present(mail, animated: true)
        } else {
            showAlert(alertText: "Почтовый клиент", alertMessage: "Не настроен!")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @objc func sendButtonClick(_ sender: Any) {
        sendEmail()
        
    }
    
}



//MARK: Обновление таблицы для фоновых задач
extension TaskListViewController {
    
    func registerTableViewUpdateNotification() {
      NotificationCenter.default.addObserver(
        forName: .refresh,
        object: nil,
        queue: nil) { (notification) in
          
          if let uInfo = notification.userInfo,
             let result = uInfo["result"] as? Bool,
             result {
           
            DispatchQueue.main.async {
                self.updateTable()
            }
          }
      }
    }
    
}


