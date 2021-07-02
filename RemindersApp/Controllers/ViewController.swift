//
//  ViewController.swift
//  RemindersApp
//
//  Created by Arman Abkar on 7/1/21.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    
    @IBOutlet weak var table: UITableView!
    
    var models = [Reminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        guard let viewController = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        
        viewController.title = "New Reminder"
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.completion = { title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                
                let new = Reminder(title: title, date: date, identifier: "id_\(title)")
                self.models.append(new)
                self.table.reloadData()
                
                self.createNotification(title: title, body: body, date: date)
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func didTapTest(_ sender: Any) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.createNotification(title: "Test Notification", body: "Hi! This is a test notification from Reminders app!", date: Date().addingTimeInterval(10))
            } else if error != nil {
                print("Error occurred...")
            }
        }
    }
    
    func createNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        content.body = body
        
        let targetDate = date
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error != nil {
                print("Something went wrong...")
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DispatchQueue.main.async {
                self.models.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .none {
            return
        }
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        let date = models[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY HH:mm:ss"
        cell.detailTextLabel?.text = formatter.string(from: date)
        return cell
    }
    
}

