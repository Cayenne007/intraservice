//
//  FilterView.swift
//  intraservice
//
//  Created by Vladlen Sukhov on 27.12.2020.
//

import SwiftUI

struct FilterView: View {
    
    var dismiss: (()->())?
        
    @State private var executors = Filter.shared.executors
    @State private var creatorExclude = Filter.shared.creatorExclude
    @State private var newTaskNotification = Filter.shared.newTaskNotification
    
    @State private var statusGroupOpened = false
    var statusGroupTitle: String {
        if statusOpen || statusApproval || statusQueue ||
            statusProcess || statusReady || statusClose ||
            statusCancel {
            return "(выбрано)"
        } else {
            return "(не выбрано)"
        }
    }
    
    
    @State private var statusOpen = Filter.shared.status(.open)
    @State private var statusApproval = Filter.shared.status(.approval)
    @State private var statusQueue = Filter.shared.status(.queue)
    @State private var statusProcess = Filter.shared.status(.process)
    @State private var statusReady = Filter.shared.status(.ready)
    @State private var statusClose = Filter.shared.status(.close)
    @State private var statusCancel = Filter.shared.status(.cancel)
        
    @State private var changedDateIsActive = Filter.shared.changedDateIsActive
    @State private var changedBeginDate = Filter.shared.changedBeginDate
    @State private var changedEndDate = Filter.shared.changedEndDate
    
    var body: some View {
        
        
        VStack {
                
            HStack (alignment: .center) {
                //Spacer()
                Text("Фильтры")
                .font(.largeTitle)
                Spacer()
                Button("Сохранить") { saveData() }
            }.padding()
            
            Form {
                Section(header: Toggle("Дата изменения", isOn: $changedDateIsActive)) {
                    ScrollView (.horizontal) {
                        HStack {
                            DatePicker(
                                "c",
                                selection: $changedBeginDate,
                                displayedComponents: [.date]
                            ).disabled(!changedDateIsActive)
                            DatePicker(
                                "по",
                                selection: $changedEndDate,
                                displayedComponents: [.date]
                            ).disabled(!changedDateIsActive)
                        }
                    }
                }
                Section(header: Text("Исполнители")) {
                    TextField("Имена через запятую", text: $executors)
                }
                Section(header: Text("Авторы кроме")) {
                    TextField("Имена через запятую", text: $creatorExclude)
                }
                                    
                
                Section(header: Text("Статусы")) {
                                        
                    DisclosureGroup(
                        statusGroupTitle,
                        isExpanded: $statusGroupOpened) {
                        
                        Toggle("Открыта", isOn: $statusOpen)
                        Toggle("На согласовании", isOn: $statusApproval)
                        Toggle("В процессе", isOn: $statusProcess)
                        Toggle("Выполнена", isOn: $statusReady)
                        Toggle("Закрыта", isOn: $statusClose)
                        Toggle("Отменена", isOn: $statusCancel)
                    }
                }
                                                                    
                
                
                Section(header: Text("Дополнительно")) {
                    Toggle("Уведомлять", isOn: $newTaskNotification)
                }
                
                
            }
        }
        .onAppear() {
            
        }
    }
    
    func saveData() {
        
        Filter.shared.executors = executors
        Filter.shared.creatorExclude = creatorExclude
        Filter.shared.newTaskNotification = newTaskNotification
        
        Filter.shared.status[.open] = statusOpen
        Filter.shared.status[.approval] = statusApproval
        Filter.shared.status[.queue] = statusQueue
        Filter.shared.status[.process] = statusProcess
        Filter.shared.status[.ready] = statusReady
        Filter.shared.status[.close] = statusClose
        Filter.shared.status[.cancel] = statusClose
            
        Filter.shared.changedDateIsActive = changedDateIsActive
        Filter.shared.changedBeginDate = changedBeginDate
        Filter.shared.changedEndDate = changedEndDate
        
        Filter.shared.save()
        
        Notifications.updateTaskList()
        dismiss?()
    }
    
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView()
    }
}
