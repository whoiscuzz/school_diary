import SwiftUI
import ActivityKit
import UserNotifications
import Charts

// --- 1. ЛОГИКА ШКОЛЫ ---
struct Vacation {
    let name: String
    let startDate: Date
}

class SchoolLogic {
    static let shared = SchoolLogic()
    
    // Каникулы
    let vacations: [Vacation] = [
        Vacation(name: "Зимних каникул ❄️", startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 25))!),
        Vacation(name: "Весенних каникул 🌱", startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 22))!),
        Vacation(name: "Летних каникул ☀️", startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 1))!)
    ]
    
    // Цитаты
    let quotes = [
        "Знание — сила. 🧠",
        "Не откладывай на завтра. 🔥",
        "Трудности закаляют. 💪",
        "Учись, пока другие спят. 📚",
        "Ты способен на большее! 🚀"
    ]
    
    func getNextVacation() -> (String, Int) {
        let now = Date()
        if let nextVacation = vacations.first(where: { $0.startDate >= now }) {
            let diff = Calendar.current.dateComponents([.day], from: now, to: nextVacation.startDate).day ?? 0
            return (nextVacation.name, diff)
        }
        return ("Каникулы! 🎉", 0)
    }
    
    // Получить уроки ТОЛЬКО на сегодня
    func getTodayLessons(schedule: [SchoolDay]) -> [Lesson] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let weekMap: [Int: String] = [2: "Понедельник", 3: "Вторник", 4: "Среда", 5: "Четверг", 6: "Пятница"]
        
        guard let todayName = weekMap[weekday],
              let todaySchedule = schedule.first(where: { $0.name == todayName }) else {
            return []
        }
        return todaySchedule.lessons
    }
    
    func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Доброе утро ☀️"
        case 12..<17: return "Добрый день 👋"
        case 17..<22: return "Добрый вечер 🌙"
        default: return "Доброй ночи 💤"
    }
    }
}

// --- 2. МЕНЕДЖЕРЫ ---
class LiveActivityManager {
    static let shared = LiveActivityManager()
    func startLesson(name: String, room: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let now = Date()
        let end = Calendar.current.date(byAdding: .minute, value: 45, to: now)!
        let attributes = LessonAttributes(lessonName: name, room: room)
        let state = LessonAttributes.ContentState(endTime: end, startTime: now)
        let content = ActivityContent(state: state, staleDate: nil)
        do { let _ = try Activity<LessonAttributes>.request(attributes: attributes, content: content, pushType: nil) } catch {}
    }
    func stopActivity() {
        Task { for activity in Activity<LessonAttributes>.activities { await activity.end(nil, dismissalPolicy: .immediate) } }
    }
}

class NotificationManager {
    static let shared = NotificationManager()
    func requestPermission() { UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in } }
    func scheduleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "📝 Дневник"; content.body = "Не забудь обновить оценки!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let req = UNNotificationRequest(identifier: "diaryReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}

// --- 3. РАСПИСАНИЕ ---
let fullSchedule: [SchoolDay] = [
    SchoolDay(name: "Понедельник", lessons: [
        Lesson(time: "08:30", name: "Матем. (физмат)", room: "320"),
        Lesson(time: "09:30", name: "Матем. (физмат)", room: "320"),
        Lesson(time: "10:30", name: "Физика (физмат)", room: "321"),
        Lesson(time: "11:30", name: "Физика (физмат)", room: "321")
    ]),
    SchoolDay(name: "Вторник", lessons: [
        Lesson(time: "08:30", name: "Биология", room: "322"),
        Lesson(time: "09:30", name: "Физика / Матем.", room: "321/328"),
        Lesson(time: "10:30", name: "Физкультура", room: "Зал"),
        Lesson(time: "11:30", name: "Матем. / Физика", room: "320/321"),
        Lesson(time: "12:30", name: "Англ. яз", room: "116/114"),
        Lesson(time: "13:25", name: "Химия", room: "321"),
        Lesson(time: "14:20", name: "Кл. час", room: "116")
    ]),
    SchoolDay(name: "Среда", lessons: [
        Lesson(time: "08:30", name: "Бел. лит", room: "316"),
        Lesson(time: "09:30", name: "Бел. яз", room: "316"),
        Lesson(time: "10:30", name: "Обществов.", room: "318"),
        Lesson(time: "11:30", name: "Матем.", room: "320"),
        Lesson(time: "12:30", name: "Ист. Беларуси", room: "322"),
        Lesson(time: "13:25", name: "Рус. яз", room: "411"),
        Lesson(time: "14:20", name: "Физкультура", room: "Зал")
    ]),
    SchoolDay(name: "Четверг", lessons: [
        Lesson(time: "08:30", name: "Англ. яз", room: "116"),
        Lesson(time: "09:30", name: "Матем", room: "321"),
        Lesson(time: "10:55", name: "Рус. лит", room: "411"),
        Lesson(time: "11:55", name: "Рус. яз", room: "411"),
        Lesson(time: "12:55", name: "География", room: "318"),
        Lesson(time: "13:50", name: "Физика.", room: "320"),
        Lesson(time: "14:45", name: "Черчение", room: "315")
    ]),
    SchoolDay(name: "Пятница", lessons: [
        Lesson(time: "08:30", name: "Бел. лит", room: "316"),
        Lesson(time: "09:30", name: "Матем.", room: "320"),
        Lesson(time: "10:30", name: "Химия", room: "323"),
        Lesson(time: "11:30", name: "Информ.", room: "326"),
        Lesson(time: "12:30", name: "Ист. Беларуси", room: "322"),
        Lesson(time: "13:25", name: "Биология", room: "322"),
        Lesson(time: "14:20", name: "Физкультура", room: "Зал"),
    ])
]

// --- 4. НОВАЯ КРАСИВАЯ ГЛАВНАЯ СТРАНИЦА ---
struct HomeView: View {
    @Binding var grades: [SubjectGrade]
    @Binding var homeworkTasks: [HomeworkItem]
    @Binding var selectedTab: Int // Чтобы переключать вкладки кнопками
    @Binding var showAddTask: Bool
    
    // Данные
    var vacationInfo: (String, Int) { SchoolLogic.shared.getNextVacation() }
    var todayLessons: [Lesson] { SchoolLogic.shared.getTodayLessons(schedule: fullSchedule) }
    var averageScore: Double {
        let allGrades = grades.flatMap { $0.grades.map { $0.value } }
        return allGrades.isEmpty ? 0.0 : Double(allGrades.reduce(0, +)) / Double(allGrades.count)
    }
    var overdueCount: Int { homeworkTasks.filter { !$0.isCompleted && $0.dueDate < Date() }.count }
    var doneCount: Int { homeworkTasks.filter { $0.isCompleted }.count }
    var randomQuote: String { SchoolLogic.shared.quotes.randomElement()! }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    // 1. HEADER
                    HStack {
                        VStack(alignment: .leading) {
                            Text(SchoolLogic.shared.getGreeting())
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Твой Дашборд 🚀")
                                .font(.largeTitle)
                                .fontWeight(.black)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // 2. ЦИТАТА ДНЯ
                    Text(randomQuote)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    // 3. БЫСТРЫЕ ДЕЙСТВИЯ (Кнопки)
                    HStack(spacing: 15) {
                        Button(action: { showAddTask = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Домашка")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { selectedTab = 1 }) { // Переход к расписанию
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Таймер")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 4. СЕТКА СТАТИСТИКИ (4 квадрата)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        // Каникулы
                        StatsBox(title: "До каникул", value: "\(vacationInfo.1) дн", icon: "beach.umbrella.fill", color: .purple)
                        // Средний балл
                        StatsBox(title: "Ср. балл", value: String(format: "%.2f", averageScore), icon: "graduationcap.fill", color: averageScore >= 8 ? .green : .orange)
                        // Долги
                        StatsBox(title: "Долги", value: "\(overdueCount)", icon: "exclamationmark.triangle.fill", color: overdueCount > 0 ? .red : .gray)
                        // Сделано
                        StatsBox(title: "Сделано", value: "\(doneCount)", icon: "checkmark.circle.fill", color: .blue)
                    }
                    .padding(.horizontal)
                    
                    // 5. ЛЕНТА УРОКОВ НА СЕГОДНЯ
                    VStack(alignment: .leading) {
                        Text("Уроки сегодня")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if todayLessons.isEmpty {
                            Text("Сегодня выходной! 🥳")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(todayLessons) { lesson in
                                        VStack(alignment: .leading) {
                                            Text(lesson.time)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                            Text(lesson.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            Text(lesson.room)
                                                .font(.caption)
                                                .bold()
                                                .foregroundColor(.white)
                                                .padding(4)
                                                .background(Color.white.opacity(0.2))
                                                .cornerRadius(4)
                                        }
                                        .padding()
                                        .frame(width: 140, height: 100)
                                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .cornerRadius(16)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Красивая карточка для статистики
struct StatsBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

// --- 5. ОСТАЛЬНЫЕ ВЬЮ ---
struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var tasks: [HomeworkItem]
    @State private var title = ""
    @State private var subject = ""
    @State private var dueDate = Date()
    var body: some View {
        NavigationView {
            Form {
                TextField("Что задали?", text: $title)
                TextField("Предмет", text: $subject)
                DatePicker("Дедлайн", selection: $dueDate, displayedComponents: .date)
            }
            .navigationTitle("Новая задача")
            .toolbar {
                Button("Сохранить") {
                    tasks.append(HomeworkItem(title: title, subject: subject, dueDate: dueDate, isCompleted: false))
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ScheduleView: View {
    let skyBlue = Color(red: 0.4, green: 0.7, blue: 1.0)
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: { LiveActivityManager.shared.startLesson(name: "Физика", room: "321") }) {
                        HStack { Image(systemName: "play.fill"); Text("Начать урок (45 мин)") }
                    }.foregroundColor(.blue)
                    Button(action: { LiveActivityManager.shared.stopActivity() }) {
                        Text("Закончить урок")
                    }.foregroundColor(.red)
                } header: { Text("Freedom Bar") }
                ForEach(fullSchedule) { day in
                    Section(header: Text(day.name).foregroundColor(skyBlue)) {
                        ForEach(day.lessons) { lesson in
                            HStack {
                                Text(lesson.time).font(.caption).foregroundColor(.gray)
                                Text(lesson.name)
                                Spacer()
                                if !lesson.room.isEmpty { Text(lesson.room).font(.caption).bold().foregroundColor(skyBlue).padding(6).background(skyBlue.opacity(0.15)).cornerRadius(6) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Расписание")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct DeadlinesView: View {
    @Binding var homeworkTasks: [HomeworkItem]
    @Binding var showingAddTask: Bool
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($homeworkTasks) { $task in
                        HStack {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                                .onTapGesture { withAnimation { task.isCompleted.toggle() } }
                            VStack(alignment: .leading) {
                                Text(task.subject).font(.caption).bold().foregroundColor(.gray)
                                Text(task.title).strikethrough(task.isCompleted)
                            }
                            Spacer()
                            if !task.isCompleted && task.dueDate < Date() { Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red) }
                        }
                    }
                    .onDelete { homeworkTasks.remove(atOffsets: $0) }
                }
            }
            .navigationTitle("Дедлайны")
            .toolbar { Button(action: { showingAddTask = true }) { Image(systemName: "plus") } }
            .sheet(isPresented: $showingAddTask) { AddTaskView(tasks: $homeworkTasks) }
        }
    }
}

struct DiaryView: View {
    @Binding var grades: [SubjectGrade]
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Аналитика")) {
                    Chart(grades) { subject in
                        BarMark(x: .value("Предмет", subject.name), y: .value("Балл", subject.average))
                            .foregroundStyle(subject.average >= 8 ? Color.green : (subject.average >= 6 ? Color.orange : Color.red))
                    }
                    .frame(height: 180)
                }
                ForEach($grades) { $subject in
                    Section(header: Text(subject.name)) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(subject.grades) { gradeEntry in
                                    Text("\(gradeEntry.value)")
                                        .font(.headline).frame(width: 35, height: 35)
                                        .background(gradeEntry.value >= 8 ? Color.green.opacity(0.2) : (gradeEntry.value >= 5 ? Color.orange.opacity(0.2) : Color.red.opacity(0.2)))
                                        .cornerRadius(8)
                                        .contextMenu { Button(role: .destructive) { if let index = subject.grades.firstIndex(where: { $0.id == gradeEntry.id }) { withAnimation { subject.grades.remove(at: index) } } } label: { Label("Удалить", systemImage: "trash") } }
                                }
                                Menu { ForEach(1...10, id: \.self) { num in Button("\(num)") { withAnimation { subject.grades.append(GradeEntry(value: num)) } } } } label: { Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.blue) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Мой Дневник")
        }
    }
}

// --- 6. СБОРКА APP ---
struct ContentView: View {
    @State private var homeworkTasks: [HomeworkItem] = []
    @State private var grades: [SubjectGrade] = []
    @State private var showingAddTask = false
    @State private var selectedTab = 0 // Контроль вкладок

    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
        NotificationManager.shared.requestPermission()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView(grades: $grades, homeworkTasks: $homeworkTasks, selectedTab: $selectedTab, showAddTask: $showingAddTask)
                .tabItem { Image(systemName: "house.fill"); Text("Главная") }
                .tag(0)
            
            ScheduleView()
                .tabItem { Image(systemName: "calendar"); Text("Уроки") }
                .tag(1)
            
            DeadlinesView(homeworkTasks: $homeworkTasks, showingAddTask: $showingAddTask)
                .tabItem { Image(systemName: "checklist"); Text("Задачи") }
                .tag(2)
            
            DiaryView(grades: $grades)
                .tabItem { Image(systemName: "graduationcap.fill"); Text("Дневник") }
                .tag(3)
        }
        .accentColor(Color(red: 0.4, green: 0.7, blue: 1.0))
        .onAppear { loadData() }
        .onChange(of: grades) { _ in saveData() }
        .onChange(of: homeworkTasks) { _ in saveData() }
    }
    
    func saveData() {
        if let encodedGrades = try? JSONEncoder().encode(grades) { UserDefaults.standard.set(encodedGrades, forKey: "saved_grades") }
        if let encodedTasks = try? JSONEncoder().encode(homeworkTasks) { UserDefaults.standard.set(encodedTasks, forKey: "saved_tasks") }
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "saved_grades"), let decoded = try? JSONDecoder().decode([SubjectGrade].self, from: data) { grades = decoded }
        else { grades = [SubjectGrade(name: "Математика", grades: []), SubjectGrade(name: "Физика", grades: []), SubjectGrade(name: "Русский яз", grades: []), SubjectGrade(name: "Английский", grades: []), SubjectGrade(name: "Химия", grades: []), SubjectGrade(name: "Бел. лит", grades: []), SubjectGrade(name: "История", grades: [])] }
        if let data = UserDefaults.standard.data(forKey: "saved_tasks"), let decoded = try? JSONDecoder().decode([HomeworkItem].self, from: data) { homeworkTasks = decoded }
    }
}

#Preview { ContentView() }
