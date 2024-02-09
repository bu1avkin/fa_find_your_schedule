//
//  ContentView.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var scheduleService = ScheduleService()
    
    private let userDisciplines = ["Программирование в среде R", "Основы технологий интернета вещей", "Иностранный язык в профессиональной сфере", "Информационное право", "Машинное обучение в семантическом и сетевом анализе"]

    var body: some View {
        NavigationView {
            List(scheduleService.scheduleData.filter { classInfo in
                userDisciplines.contains(classInfo.discipline)
            }) { classInfo in
                VStack(alignment: .leading, spacing: 5) {
                    Text(classInfo.discipline).fontWeight(.bold)
                    Text("Дата: \(classInfo.date)")
                    Text("Время: \(classInfo.beginLesson) - \(classInfo.endLesson)")
                    Text("Аудитория: \(classInfo.auditorium)")
                }
            }
            .navigationTitle("Расписание")
            .onAppear {
                scheduleService.fetchSchedule()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
