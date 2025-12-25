import Foundation
import ActivityKit

// --- 1. АТРИБУТЫ ДЛЯ ВИДЖЕТА ---
public struct LessonAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endTime: Date
        var startTime: Date
    }
    var lessonName: String
    var room: String
}

// --- 2. УРОК И РАСПИСАНИЕ ---
struct Lesson: Identifiable, Hashable, Codable {
    let id = UUID()
    let time: String
    let name: String
    let room: String
}

struct SchoolDay: Identifiable, Codable {
    let id = UUID()
    let name: String
    let lessons: [Lesson]
}

// --- 3. ДОМАШНЕЕ ЗАДАНИЕ ---
// Добавили Equatable, чтобы работало сохранение
struct HomeworkItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var subject: String
    var dueDate: Date
    var isCompleted: Bool
}

// --- 4. ОЦЕНКИ ---
struct GradeEntry: Identifiable, Codable, Hashable, Equatable {
    var id = UUID()
    var value: Int
}

// Добавили Equatable, чтобы работало сохранение
struct SubjectGrade: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var grades: [GradeEntry]
    
    var average: Double {
        guard !grades.isEmpty else { return 0.0 }
        let sum = grades.reduce(0) { $0 + $1.value }
        return Double(sum) / Double(grades.count)
    }
}
