//
//  ScheduleService.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import Foundation

class ScheduleService: ObservableObject {
    @Published var groupedScheduleData = [String: [ClassInfo]]()
    @Published var days = [String]()

    func fetchSchedule() {
        let calendar = Calendar.current
        let today = Date()
        let twoWeeksBefore = calendar.date(byAdding: .weekOfYear, value: -2, to: today)!
        let threeWeeksAfter = calendar.date(byAdding: .weekOfYear, value: 3, to: today)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        let startDate = dateFormatter.string(from: twoWeeksBefore)
        let finishDate = dateFormatter.string(from: threeWeeksAfter)

        let urlString = "https://ruz.fa.ru/api/schedule/group/110815?start=\(startDate)&finish=\(finishDate)&lng=1"
        guard let url = URL(string: urlString) else { return }

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
                    self?.groupScheduleByDate(decodedData)
                }
            } catch {
                print("Ошибка декодирования: \(error)")
            }
        }.resume()
    }

    private func groupScheduleByDate(_ scheduleData: [ClassInfo]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd" // Формат, соответствующий вашим данным
        dateFormatter.locale = Locale(identifier: "ru_RU") // Локаль для интерпретации дней недели
        
        var newGroupedScheduleData = [String: [ClassInfo]]()
        var newDays = Set<String>()

        for classInfo in scheduleData {
            let day = classInfo.date // Используем date напрямую, если она в формате 'yyyy.MM.dd'
            newGroupedScheduleData[day, default: []].append(classInfo)
            newDays.insert(day)
        }

        self.groupedScheduleData = newGroupedScheduleData
        self.days = Array(newDays).sorted(by: { $0 < $1 })
    }
}
