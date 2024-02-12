//
//  ContentView.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import SwiftUI
import UIKit

import SwiftUI

struct ContentView: View {
    @StateObject private var scheduleService = ScheduleService()
    @State private var selectedDay: String?
    
    var body: some View {
        NavigationView {
            VStack {
                // Заголовок и кнопки для переключения дней
                headerView
                
                // Список пар для выбранного дня
                if let day = selectedDay, let classesForDay = scheduleService.groupedScheduleData[day] {
                    ScrollView {
                        ForEach(classesForDay) { classInfo in
                            ClassRowView(classInfo: classInfo)
                        }
                    }
                } else {
                    Text("Выберите день для отображения расписания.")
                        .padding()
                }
            }
            .navigationTitle("Расписание")
            .onAppear {
                scheduleService.fetchSchedule()
            }
        }
    }
    
    var headerView: some View {
        VStack {
            if !scheduleService.days.isEmpty {
                // Если дни еще не загружены, selectedDay будет nil, поэтому установим его в первый день
                let initialDay = selectedDay ?? scheduleService.days.first!
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(scheduleService.days, id: \.self) { day in
                            DayButton(day: day, isSelected: day == initialDay) {
                                selectedDay = day
                            }
                        }
                    }
                }
                .onAppear {
                    // Установим выбранный день после загрузки данных
                    if selectedDay == nil {
                        selectedDay = scheduleService.days.first
                    }
                }
            }
        }
    }
}

struct DayButton: View {
    var day: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

struct ClassRowView: View {
    let classInfo: ClassInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(classInfo.discipline).fontWeight(.bold)
            Text("Тип: \(classInfo.kindOfWork)")
            Text("Время: \(classInfo.beginLesson) - \(classInfo.endLesson)")
            Text("Аудитория: \(classInfo.auditorium)")
            Text("Преподаватель: \(classInfo.lecturer)")
        }
        .padding()
        .background(self.backgroundColor(forKindOfWork: classInfo.kindOfWork))
        .cornerRadius(8)
    }
    
    private func backgroundColor(forKindOfWork kindOfWork: String) -> Color {
        switch kindOfWork {
        case "Лекция":
            return Color.blue.opacity(0.2)
        case "Практические":
            return Color.green.opacity(0.2)
        default:
            return Color.gray.opacity(0.1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
