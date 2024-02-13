//
//  ContentView.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var scheduleService = ScheduleService()
    @State private var selectedDay: String?
    
    // Определяем базовые и пользовательские дисциплины
    private let basicDisciplines = [
        "Иностранный язык в профессиональной сфере",
        "Информационное право",
        "Программная инженерия",
        "Бухгалтерские информационные системы",
        "Машинное обучение в семантическом и сетевом анализе"
    ]
    
    private var userDisciplines: [String] {
        [
            "Управление качеством программных систем",
            "Проектирование информационных систем",
            "Основы технологий интернета вещей"
        ] + basicDisciplines
    }
    
    private let targetForeignLecturer = "Романова"
    private let foreignLanguageDiscipline = "Иностранный язык в профессиональной сфере"

    var body: some View {
        NavigationView {
            VStack {
                // Заголовок и кнопки для переключения дней
                headerView

                // Список пар для выбранного дня
                if let day = selectedDay, let classesForDay = scheduleService.groupedScheduleData[day] {
                    ScrollView {
                        VStack {
                            ForEach(classesForDay) { classInfo in
                                if classInfo.discipline == foreignLanguageDiscipline && classInfo.lecturer.contains(targetForeignLecturer) {
                                    ClassRowView(classInfo: classInfo)
                                } else if userDisciplines.contains(classInfo.discipline) && classInfo.discipline != foreignLanguageDiscipline {
                                    ClassRowView(classInfo: classInfo)
                                }
                            }
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
                    HStack(spacing: 8) {
                        ForEach(scheduleService.days, id: \.self) { day in
                            DayButton(day: day, isSelected: day == initialDay) {
                                selectedDay = day
                            }
                        }
                    }
                    .padding(.horizontal)
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
    
    // Создаем DateFormatter для преобразования строки в дату и обратно
    private static var dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd" // Исходный формат даты
        return formatter
    }()
    
    // Функция для преобразования строки даты в только число дня
    private func dayNumber(from day: String) -> String {
            if let date = DayButton.dayNumberFormatter.date(from: day) {
                DayButton.dayNumberFormatter.dateFormat = "d" // Новый формат даты, показывающий только число
                defer { DayButton.dayNumberFormatter.dateFormat = "yyyy.MM.dd" } // Восстановить исходный формат
                return DayButton.dayNumberFormatter.string(from: date)
            }
            return day // В случае ошибки вернуть исходную строку
        }
    
    var body: some View {
        Button(action: action) {
            Text(dayNumber(from: day))
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}

struct ClassRowView: View {
    let classInfo: ClassInfo

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 2) {
                Image(systemName: "circle.fill")
                    .imageScale(.medium)
                    .font(.footnote)
                    .foregroundColor(self.backgroundColor(forKindOfWork: classInfo.kindOfWork))
                Rectangle()
                    .frame(width: 2)
                    .foregroundColor(self.backgroundColor(forKindOfWork: classInfo.kindOfWork))
            }
            .frame(height: 140)

            VStack(alignment: .leading, spacing: 6) {
                Text(classInfo.beginLesson)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text(classInfo.discipline)
                    .font(.system(.headline, weight: .medium))
                Text(classInfo.kindOfWork)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text("Аудитория: \(classInfo.auditorium)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Text("Преподаватель: \(classInfo.lecturer)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    private func backgroundColor(forKindOfWork kindOfWork: String) -> Color {
        switch kindOfWork {
        case "Лекции":
            return Color.blue
        case "Практические (семинарские) занятия":
            return Color.green
        default:
            return Color.gray
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
