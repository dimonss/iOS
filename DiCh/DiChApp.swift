//
//  DiChApp.swift
//  DiCh
//
//  Точка входа приложения - аналог main.js/index.js в веб-приложениях
//

import SwiftUI
import SwiftData

// @main - указывает точку входа (как export default в Next.js)
@main
struct DiChApp: App {
    // ModelContainer - контейнер базы данных SwiftData
    // Аналог: подключение к MongoDB/PostgreSQL в backend
    var sharedModelContainer: ModelContainer = {
        // Schema - схема данных (как Mongoose Schema или Prisma Schema)
        let schema = Schema([
            TodoItem.self,  // Регистрируем нашу модель TodoItem
        ])
        
        // Конфигурация хранилища
        // isStoredInMemoryOnly: false = данные сохраняются на диск (как SQLite)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // fatalError - критическая ошибка, приложение падает
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // body - главный UI приложения
    // Аналог: return в функциональном компоненте React
    var body: some Scene {
        // WindowGroup - окно приложения
        WindowGroup {
            // Здесь указываем главный View
            TodoListView()
        }
        // Подключаем базу данных ко всему приложению
        // Аналог: Provider в React (Context API, Redux, etc.)
        .modelContainer(sharedModelContainer)
    }
}
