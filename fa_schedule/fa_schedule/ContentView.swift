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

    // Создаем DateFormatter для получения названия месяца
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL" // Формат для получения полного названия месяца
        formatter.locale = Locale(identifier: "ru_RU") // Установка локали, если нужно
        return formatter
    }()
    
    // Функция для получения названия месяца из строки даты
    private func monthName(from date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd" // Формат даты, соответствующий вашему API
        if let date = dateFormatter.date(from: date) {
            return monthFormatter.string(from: date).capitalized
        }
        return "Расписание" // В случае ошибки вернуть заглушку
    }
    
    private var todayString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: Date())
    }
    
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Анимированное отображение названия месяца или "Расписание"
                    if let selectedDay = selectedDay {
                        Text(monthName(from: selectedDay))
                            .font(.headline)
                            .transition(.opacity)
                            .animation(.default, value: selectedDay)
                    } else {
                        Text("Расписание")
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                scheduleService.fetchSchedule()
            }
        }
    }
    
    var headerView: some View {
        VStack {
            if !scheduleService.days.isEmpty {
                // Установка сегодняшней даты
                let todayString = DateFormatter.yyyyMMdd.string(from: Date())
                ScrollView(.horizontal, showsIndicators: false) {
                    ScrollViewReader { scrollViewProxy in
                        HStack(spacing: 8) {
                            ForEach(scheduleService.days, id: \.self) { day in
                                DayButton(day: day, isSelected: day == selectedDay) {
                                    selectedDay = day
                                }
                                .id(day)
                            }
                        }
                        .padding(.horizontal)
                        .onAppear {
                            // Установка selectedDay в сегодняшний день
                            selectedDay = todayString
                            // Прокрутка к сегодняшнему дню с анимацией
                            DispatchQueue.main.async {
                                withAnimation {
                                    scrollViewProxy.scrollTo(todayString, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
}
    

struct DayButton: View {
    var day: String
    var isSelected: Bool
    var action: () -> Void
    
    private static var dayNumberFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
    
    private func dayNumber(from day: String) -> String {
        if let date = DayButton.dayNumberFormatter.date(from: day) {
            DayButton.dayNumberFormatter.dateFormat = "d"
            defer { DayButton.dayNumberFormatter.dateFormat = "yyyy.MM.dd" }
            return DayButton.dayNumberFormatter.string(from: date)
        }
        return day
    }
    
    var body: some View {
        Button(action: action) {
            Text(dayNumber(from: day))
                .font(.system(size: 16, weight: .medium))
                .frame(minWidth: 36)
                .padding(.vertical, 8)
                .background(
                    isSelected ? AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom)) : AnyView(Color.gray.opacity(0.3))
                )
                .foregroundColor(isSelected ? .white : .black)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                .clipShape(Capsule())
                .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 5, x: 0, y: 0)
                .animation(.easeInOut, value: isSelected)
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
