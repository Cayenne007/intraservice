//
//  TaskView.swift
//  intraservice
//
//  Created by Vladlen Sukhov on 27.12.2020.
//

import SwiftUI
import QuickLook

struct TaskView: View {
    
    let task: Task
    @State private var files: [TaskFile] = []
    
    @State private var currentStatus = 0
    var statusList: [TaskStatus] = StorageManager.shared.fetch(TaskStatus.self)
    
    @State private var currentExecutor = 0
    var executors: [User] = StorageManager.shared.fetch(User.self)
    
    
    var body: some View {
        VStack {
                    
            Form {
                Section(header: Text("Заголовок")) {
                    VStack (alignment: .leading) {
                        Text(task.name!)
                    }
                }
                
                Section(header: Text("Реквизты")) {
                    HStack {
                        Text("Дата создания")
                        Spacer()
                        Text(task.created!.toString())
                    }
                    
                    Picker(selection: $currentStatus, label: Text("Статус")) {
                        ForEach(0..<statusList.count) {
                            Text(self.statusList[$0].name!)
                        }
                    }
                    
                    HStack {
                        Text("Автор")
                        Spacer()
                        Text(task.creator!)
                    }
                                        
                }
                
                
                Picker("Исполнитель", selection: $currentExecutor) {
                    ForEach(0..<executors.count) {
                        Text(self.executors[$0].name!)
                    }
                }
                
                
                Section(header: Text("Текст")) {
                    Text(task.text!)
                }
                                       
                List (files, id: \.self) { file in
                    
                    NavigationLink(
                        destination:
                            file.getImage()
                            .resizable()
                            .scaledToFit()
                        ,
                        label: {
                            Text(file.name!)
                        })
                }
                
            }
            .navigationTitle("№\(String(task.id))")
                              
        }
        .onAppear() {
            Files.loadFiles(task) { self.files = $0 }
                    
            let status = statusList.first(where: {$0.id == task.statusId})!
            currentStatus = statusList.firstIndex(of: status)!
            
            if let taskExecutors = task.executorIds?.array(by: ","),
               let taskExecutor = taskExecutors.first,
               let id = Int32(taskExecutor),
               let executor = executors.first(where: {$0.id == id}) {
                
                
                currentExecutor = executors.firstIndex(of: executor)!
            }
            
        }
    }
    
    
    
    func getStatus(id: Int32) -> String {
        guard let status = statusList.first(where: {$0.id == id}),
              let name = status.name else { return ""}
        return name
    }
    

    
}


struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        
        TaskView(task: TaskView_Previews.getTestTask())
    }
    
    static func getTestTask() -> Task {
        let task = Task(context: StorageManager.shared.context)
        task.id = 12345
        task.statusId = 11
        task.name = "Владлен, привет!"
        task.created = Date()
        task.creator = "Мамадашвили Илона Зазаевна"
        task.creatorEmail = "ilona@me.com"
        task.fileIds = "123,1232"
        task.text = """
            Владлен, я соскучилась по тебе....
            жду тебя в кабинете, приходи скорее, целую
            """
        
        return task
    }
        
}


struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {}
}

class Coordinator: QLPreviewControllerDataSource {
    
    let parent: PreviewController
    
    init(parent: PreviewController) {
        self.parent = parent
    }
    
    func numberOfPreviewItems(
        in controller: QLPreviewController
    ) -> Int {
        return 1
    }
    
    func previewController(
        _ controller: QLPreviewController, previewItemAt index: Int
    ) -> QLPreviewItem {
        return parent.url as NSURL
    }
    
}
