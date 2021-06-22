//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Emile Wong on 21/6/2021.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    // MARK: - PROPERTIES
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    
    var title: String {
        switch filter {
            case .none:
                return "Everyone"
            case .contacted:
                return "Contacted people"
            case .uncontacted:
                return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
            case .none:
                return prospects.people
            case .contacted:
                return prospects.people.filter { $0.isContacted }
            case .uncontacted:
                return prospects.people.filter { !$0.isContacted }
        }
    }
    
    // MARK: - FUNCTIONS
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
            case .success(let code):
                let details = code.components(separatedBy: "\n")
                guard details.count == 2 else { return }
                
                let person = Prospect()
                person.name = details[0]
                person.emailAddress = details[1]
                
                self.prospects.add(person)
            case .failure(let error):
                print("Scanning failed with \(error)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
//            var dataComponents = DateComponents()
//            dataComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dataComponents, repeats: false)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("Ooosh")
                    }
                }
            }
            
        }
    }
    // MARK: - BODY
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    HStack{
                        Image(systemName: prospect.isContacted ? "checkmark.circle" : "questionmark.diamond")
                        VStack(alignment: .leading, content: {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                            foregroundColor(.secondary)
                        })
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted"  : "Mark Contacted") {
                            self.prospects.toggle(prospect)
                        }
                        
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button(action: {
                self.isShowingScanner = true
            }, label: {
                Image(systemName: "qrcode.viewfinder")
                Text("Scan")
            }))
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Emile Wong\nme@emilewong.com", completion: self.handleScan)
            }
        }
    }
}
// MARK: - PREVIEW
struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
    }
}
