//
//  TodoDetailView.swift
//  DiCh
//
//  Детальная страница задачи
//

import SwiftUI
import SwiftData

struct TodoDetailView: View {
    // @Bindable позволяет редактировать свойства модели
    @Bindable var todo: TodoItem
    
    // Для закрытия экрана
    @Environment(\.dismiss) private var dismiss
    
    // Локальное состояние для текста комментария
    @State private var commentText: String = ""
    
    var body: some View {
        Form {
            // MARK: - Информация о задаче
            Section("Задача") {
                // Название (только для чтения)
                HStack {
                    Text("Название")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(todo.title)
                        .multilineTextAlignment(.trailing)
                }
                
                // Статус выполнения
                Toggle("Выполнено", isOn: $todo.isCompleted)
                
                // Дата создания
                HStack {
                    Text("Создано")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(todo.createdAt, format: .dateTime.day().month().year().hour().minute())
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: - Приоритет
            Section("Приоритет") {
                Picker("Приоритет", selection: $todo.priority) {
                    Label("Низкий", systemImage: "arrow.down.circle")
                        .tag(0)
                    Label("Средний", systemImage: "minus.circle")
                        .tag(1)
                    Label("Высокий", systemImage: "exclamationmark.circle.fill")
                        .tag(2)
                }
                .pickerStyle(.segmented)
                
                // Описание выбранного приоритета
                HStack {
                    priorityIcon
                    Text(priorityDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // MARK: - Комментарий
            Section("Комментарий") {
                TextEditor(text: $commentText)
                    .frame(minHeight: 100)
                    .overlay(
                        Group {
                            if commentText.isEmpty {
                                Text("Добавьте заметку к задаче...")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                        },
                        alignment: .topLeading
                    )
            }
        }
        .navigationTitle("Детали задачи")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            // Загружаем существующий комментарий
            commentText = todo.comment ?? ""
        }
        .onDisappear {
            // Сохраняем комментарий при уходе с экрана
            todo.comment = commentText.isEmpty ? nil : commentText
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Готово") {
                    todo.comment = commentText.isEmpty ? nil : commentText
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Вспомогательные свойства
    
    @ViewBuilder
    private var priorityIcon: some View {
        switch todo.priority {
        case 0:
            Image(systemName: "arrow.down.circle.fill")
                .foregroundStyle(.blue)
        case 2:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
        default:
            Image(systemName: "minus.circle.fill")
                .foregroundStyle(.orange)
        }
    }
    
    private var priorityDescription: String {
        switch todo.priority {
        case 0:
            return "Низкий приоритет — можно отложить"
        case 2:
            return "Высокий приоритет — требует внимания!"
        default:
            return "Средний приоритет — обычная задача"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TodoDetailView(todo: TodoItem(title: "Пример задачи", priority: 1))
    }
    .modelContainer(for: TodoItem.self, inMemory: true)
}
