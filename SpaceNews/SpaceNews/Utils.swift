//
//  Utils.swift
//  Storyboard Tutorial
//
//  Created by Carlos Moreira on 01/02/2022.
//

import Foundation

import UserNotifications


class UtilsFuncs{
    
    
    // MARK: - Convert date format
    static func convertDateFormater(_ date: String?) -> String {
        var fixDate = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "pt_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let originalDate = date {
            if let newDate = dateFormatter.date(from: originalDate) {
                dateFormatter.dateFormat = "EEEE, MMM d"
                fixDate = dateFormatter.string(from: newDate)
            }
        }
        return fixDate
    }
    
    static func notification(body: String, title:String) {
        
        var center = UNUserNotificationCenter.current()
        
        print("Notificação registada")
        
        // Cria o conteudo da notificação
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        // Cria o trigger da aplicação
        let date = Date().addingTimeInterval(10)
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Cria o pedido da notificação
        
        let uuidString = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Regista a notificação
        center.add(request) { (error) in
            if error != nil {
                print("Erro de notificação", error)
            }
        }
        
    }
    
}
