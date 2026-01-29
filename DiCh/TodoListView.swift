//
//  TodoListView.swift
//  DiCh
//
//  Главный экран со списком задач
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    // @Environment - аналог Context API в React или provide/inject во Vue
    // modelContext - это контекст базы данных SwiftData
    @Environment(\.modelContext) private var modelContext
    
    // @Query - автоматически подтягивает данные из SwiftData
    // Аналог useQuery в React Query или Apollo GraphQL
    // sort: сортируем по дате создания (новые сверху)
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var todos: [TodoItem]
    
    // @State - локальное состояние компонента
    // Аналог useState в React или ref во Vue 3
    @State private var newTodoTitle = ""
    @State private var showingAddSheet = false
    @State private var selectedPriority = 1
    
    var body: some View {
        // NavigationStack - контейнер навигации (как React Router)
        NavigationStack {
            VStack(spacing: 0) {
                // Список задач
                if todos.isEmpty {
                    // Пустое состояние
                    ContentUnavailableView(
                        "Нет задач",
                        systemImage: "checklist",
                        description: Text("Нажми + чтобы добавить первую задачу")
                    )
                } else {
                    List {
                        // ForEach - как .map() в JSX
                        ForEach(todos) { todo in
                            NavigationLink(destination: TodoDetailView(todo: todo)) {
                                TodoRowView(todo: todo)
                            }
                        }
                        // onDelete - swipe-to-delete жест
                        .onDelete(perform: deleteTodos)
                    }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
                }
            }
            // Заголовок навигации
            .navigationTitle("📝 Мои задачи")
            // Toolbar - панель с кнопками
            .toolbar {
                // Кнопка редактирования (для удаления)
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    if !todos.isEmpty {
                        EditButton()
                    }
                }
                #endif
                // Кнопка добавления
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #else
                ToolbarItem {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                #endif
            }
            // Sheet - модальное окно (как Modal в Bootstrap/MUI)
            .sheet(isPresented: $showingAddSheet) {
                AddTodoSheet(
                    title: $newTodoTitle,
                    priority: $selectedPriority,
                    onSave: addTodo,
                    onCancel: { showingAddSheet = false }
                )
            }
        }
    }
    
    // Функция добавления задачи
    private func addTodo() {
        // Проверяем что title не пустой
        guard !newTodoTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // withAnimation - добавляет анимацию (как CSS transition)
        withAnimation {
            let newTodo = TodoItem(title: newTodoTitle, priority: selectedPriority)
            // Вставляем в базу данных
            modelContext.insert(newTodo)
        }
        
        // Сбрасываем форму
        newTodoTitle = ""
        selectedPriority = 1
        showingAddSheet = false
    }
    
    // Функция удаления задач
    private func deleteTodos(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(todos[index])
            }
        }
    }
}

// MARK: - Компонент строки задачи

struct TodoRowView: View {
    // @Bindable - позволяет редактировать свойства модели
    // Аналог two-way binding (v-model во Vue)
    @Bindable var todo: TodoItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Кнопка-чекбокс
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(todo.isCompleted ? .green : .gray)
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        todo.isCompleted.toggle()
                    }
                }
            
            // Текст задачи
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .strikethrough(todo.isCompleted)
                    .foregroundStyle(todo.isCompleted ? .secondary : .primary)
                
                // Дата создания
                Text(todo.createdAt, format: .dateTime.day().month().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Индикатор приоритета
            priorityIndicator
        }
        .padding(.vertical, 4)
    }
    
    // Computed property - как computed во Vue или useMemo в React
    @ViewBuilder
    private var priorityIndicator: some View {
        switch todo.priority {
        case 2:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
        case 0:
            Image(systemName: "arrow.down.circle")
                .foregroundStyle(.blue)
        default:
            EmptyView()
        }
    }
}

// MARK: - Модальное окно добавления

struct AddTodoSheet: View {
    @Binding var title: String
    @Binding var priority: Int
    let onSave: () -> Void
    let onCancel: () -> Void
    
    // FocusState - управление фокусом (как document.getElementById().focus())
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                // Секция ввода названия
                Section("Название задачи") {
                    TextField("Что нужно сделать?", text: $title)
                        .focused($isTitleFocused)
                }
                
                // Секция выбора приоритета
                Section("Приоритет") {
                    Picker("Приоритет", selection: $priority) {
                        Label("Низкий", systemImage: "arrow.down.circle")
                            .tag(0)
                        Label("Средний", systemImage: "minus.circle")
                            .tag(1)
                        Label("Высокий", systemImage: "exclamationmark.circle.fill")
                            .tag(2)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Новая задача")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Добавить", action: onSave)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                isTitleFocused = true
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Preview (предпросмотр в Xcode)

#Preview {
    TodoListView()
        .modelContainer(for: TodoItem.self, inMemory: true)
}
