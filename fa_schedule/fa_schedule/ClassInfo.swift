//
//  ClassInfo.swift
//  fa_schedule
//
//  Created by Леша Булатов on 09.02.2024.
//

import Foundation

struct ClassInfo: Codable, Identifiable {
    let id = UUID()
    let createdDate: String
    let date: String
    let dateOfNest: String
    let dayOfWeek: Int
    let dayOfWeekString: String
    let discipline: String
    let beginLesson: String
    let endLesson: String
    let auditorium: String
    let kindOfWork: String
    let lecturer: String
    
    private enum CodingKeys: String, CodingKey {
        case createdDate = "createddate", date, dateOfNest, dayOfWeek, dayOfWeekString, discipline, beginLesson, endLesson, auditorium, kindOfWork, lecturer
    }
}

