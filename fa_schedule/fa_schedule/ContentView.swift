//
//  ContentView.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import SwiftUI
import UIKit

struct AnimatedImage: UIViewRepresentable {
    var name: String
    
    func makeUIView(context: Self.Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        let gif = UIImage.gif(name: name)
        imageView.image = gif
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: UIViewRepresentableContext<AnimatedImage>) {
        // Обновление не требуется, так как GIF анимация воспроизводится автоматически
    }
}

struct ContentView: View {
    @StateObject private var scheduleService = ScheduleService()
    @State private var selectedDay: String?
    @State private var isLoading = true
    @State private var contentOpacity = 0.0

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
    
    private let targetForeignLecturer = "Виноградова"
    private let foreignLanguageDiscipline = "Иностранный язык в профессиональной сфере"
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    Spacer()
                    //ProgressView()
                       //.progressViewStyle(CircularProgressViewStyle())
                        //.scaleEffect(1.5)
                    GifImage("loadingCat1")
                                            .frame(width: 150, height: 150)
                    Spacer()
                } else {
                    // Контент будет появляться с анимацией изменения прозрачности
                    VStack {
                        headerView
                            .opacity(contentOpacity) // Применяем анимацию к headerView
                        if let day = selectedDay, let classesForDay = scheduleService.groupedScheduleData[day], !classesForDay.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading) {
                                    ForEach(classesForDay) { classInfo in
                                        if classInfo.discipline == foreignLanguageDiscipline && classInfo.lecturer.contains(targetForeignLecturer) {
                                            ClassRowView(classInfo: classInfo)
                                        } else if userDisciplines.contains(classInfo.discipline) && classInfo.discipline != foreignLanguageDiscipline {
                                            ClassRowView(classInfo: classInfo)
                                        }
                                    }
                                }
                            }
                            .padding(14)
                        } else {
                            Text("Выберите день для отображения расписания.")
                                .padding()
                        }
                    }
                    .opacity(contentOpacity) // Применяем анимацию ко всему VStack
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let selectedDay = selectedDay {
                        Text(monthName(from: selectedDay))
                            .font(.headline)
                    } else {
                        Text("Расписание")
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                // Задержка перед снятием состояния загрузки
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        isLoading = false
                        contentOpacity = 1.0 // Контент становится полностью непрозрачным
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

extension UIImage {
    // Эта функция возвращает UIImage, который содержит GIF анимацию
    static func gif(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL) else {
            return nil
        }
        
        return UIImage(data: imageData)
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
                .font(.system(size: 17, weight: .medium)) // Увеличенный размер шрифта
                .padding(.vertical, 10) // Увеличенные вертикальные отступы
                .padding(.horizontal, 20) // Увеличенные горизонтальные отступы
                .frame(height: 44) // Установленная фиксированная высота кнопки
                .background(
                    isSelected ? AnyView(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom)) : AnyView(Color.gray.opacity(0.3))
                )
                .foregroundColor(isSelected ? .white : .primary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25) // Увеличенный радиус скругления
                                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .clipShape(Capsule())
                                .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 3, x: 0, y: 3)
                                .padding(7.5)
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
