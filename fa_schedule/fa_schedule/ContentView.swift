//
//  ContentView.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var scheduleService = ScheduleService()
    
    private let targetForeignLecturer = "Романова"
    private let foreignLanguageDiscipline = "Иностранный язык в профессиональной сфере"
    
    // Определяем базовые и пользовательские дисциплины
    private let basic_disciplines = [
        "Иностранный язык в профессиональной сфере",
        "Информационное право",
        "Программная инженерия",
        "Бухгалтерские информационные системы",
        "Машинное обучение в семантическом и сетевом анализе"]
    private var user_disciplines: [String] { [
        "Управление качеством программных систем",
        "Проектирование информационных систем",
        "Основы технологий интернета вещей"
    ] + basic_disciplines
    }
    
    // DateFormatter для форматирования дат
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd" // Формат только с месяцем и днем
        return formatter
    }()
    
    // В ContentView
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(scheduleService.days, id: \.self) { day in
                            if let classesForDay = scheduleService.groupedScheduleData[day] {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(day)
                                        .font(.headline)
                                        .padding(.leading)
                                    
                                    ForEach(classesForDay) { classInfo in
                                        if classInfo.discipline == foreignLanguageDiscipline && classInfo.lecturer.contains(targetForeignLecturer) {
                                            ClassRowView(classInfo: classInfo)
                                        } else if user_disciplines.contains(classInfo.discipline) && classInfo.discipline != foreignLanguageDiscipline {
                                            ClassRowView(classInfo: classInfo)
                                        }
                                    }
                                    .frame(width: UIScreen.main.bounds.width - 30, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: UIScreen.main.bounds.height / 2)
                }
                .navigationTitle("Расписание")
                .onAppear {
                    scheduleService.fetchSchedule()
                }
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
            .cornerRadius(50)
        }
        
        private func backgroundColor(forKindOfWork kindOfWork: String) -> Color {
            if kindOfWork.contains("Лекция") {
                return Color.blue.opacity(0.2)
            } else if kindOfWork.contains("Практические") {
                return Color.green.opacity(0.2)
            } else {
                return Color.gray.opacity(0.1) // Легкий фон для других типов работ
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
}
