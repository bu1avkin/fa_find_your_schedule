//
//  ScheduleService.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import Foundation

class ScheduleService: ObservableObject {
    @Published var scheduleData = [ClassInfo]()
    @Published var groupedScheduleData = [String: [ClassInfo]]()
    
    func fetchSchedule() {
        guard let url = URL(string: "https://ruz.fa.ru/api/schedule/group/110815?start=2024.02.12&finish=2024.02.18&lng=1") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Ошибка запроса: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([ClassInfo].self, from: data)
                DispatchQueue.main.async {
                    self?.scheduleData = decodedData
                }
            } catch {
                print("Ошибка декодирования: \(error)")
            }
        }.resume()
    }
}
