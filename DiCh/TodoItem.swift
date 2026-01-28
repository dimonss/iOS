//
//  TodoItem.swift
//  DiCh
//
//  TODO Item model - это наша модель данных
//

import Foundation
import SwiftData

// @Model - это макрос SwiftData, который делает класс персистентным (сохраняемым)
// Аналог в веб-разработке: модель Mongoose/Sequelize или TypeORM entity
@Model
final class TodoItem {
    // Уникальный идентификатор (как id в базе данных)
    var id: UUID
    
    // Название задачи
    var title: String
    
    // Выполнена ли задача (как checkbox)
    var isCompleted: Bool
    
    // Дата создания задачи
    var createdAt: Date
    
    // Приоритет задачи (0 = низкий, 1 = средний, 2 = высокий)
    var priority: Int
    
    // Инициализатор - аналог конструктора класса в JS
    init(title: String, isCompleted: Bool = false, priority: Int = 1) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.priority = priority
    }
}
