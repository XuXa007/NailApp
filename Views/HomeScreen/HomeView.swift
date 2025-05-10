import SwiftUI


struct HomeView: View {
    @State private var isLoggedIn = false
    @State private var showLogin = false
    @State private var popularDesigns: [NailDesign] = []
    @State private var isLoading = true

    // !!! ИСПРАВЛЕНИЕ: Добавлено состояние для фильтров
    @State private var currentFilters = DesignFilters()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок
                Text("Дизайн маникюра")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                // Кнопки выбора дизайна
                HStack(spacing: 15) {
                    // Исправление в NavigationLink
                    NavigationLink(destination: FilterView(filters: $currentFilters, onApply: {
                        // !!! ИСПРАВЛЕНИЕ: Замыкание onApply теперь без аргументов
                        // Здесь вызови метод, который загружает дизайны с учетом currentFilters
                        print("Применены фильтры: \(currentFilters)") // Пример
                        // loadDesigns(with: currentFilters) // Раскомментируй и реализуй этот метод
                    })) {
                        FeatureCard(
                            title: "Выбрать дизайн",
                            description: "Подберите идеальный дизайн для вас",
                            iconName: "wand.and.stars"
                        )
                    }

                    NavigationLink(destination: ARTryOnView()) {
                        FeatureCard(
                            title: "Примерить",
                            description: "Попробуйте дизайн в AR или на фото",
                            iconName: "camera.viewfinder"
                        )
                    }
                }
                .padding(.horizontal)

                // Популярные дизайны
                VStack(alignment: .leading) {
                    Text("Популярные дизайны")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(popularDesigns) { design in
                                    NavigationLink(destination: DesignDetailView(design: design)) {
                                        DesignCard(design: design)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Дополнительные опции
                if !isLoggedIn {
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Войти или зарегистрироваться")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else {
                    NavigationLink(destination: FavoritesView()) {
                        Text("Мои избранные дизайны")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            // Проверяем статус авторизации
            // Убедись, что UserProfile.isLoggedIn корректно определен
            // isLoggedIn = UserProfile.isLoggedIn // Раскомментируй, если UserProfile существует
            
            // Загружаем популярные дизайны (или дизайны по умолчанию)
            loadPopularDesigns() // Или loadDesigns(with: currentFilters) если нужно при загрузке применять дефолтные фильтры
        }
        .sheet(isPresented: $showLogin) {
            LoginView(isPresented: $showLogin, onLogin: {
                isLoggedIn = true
            })
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    // Загрузка популярных дизайнов (или дизайнов по умолчанию)
    private func loadPopularDesigns() {
        isLoading = true

        // !!! В идеале, здесь или в отдельной функции loadDesigns(with filters: DesignFilters)
        // должна происходить загрузка дизайнов с учетом currentFilters.
        // Этот метод пока загружает "популярные", как было в оригинале.
        ApiService.shared.getPopularDesigns { designs, error in
            DispatchQueue.main.async {
                isLoading = false

                if let designs = designs {
                    popularDesigns = designs
                } else {
                    // Можно добавить обработку ошибки
                    print("Ошибка загрузки дизайнов: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }

    // Пример функции для загрузки с фильтрами (ее нужно дописать)
    // private func loadDesigns(with filters: DesignFilters) {
    //     isLoading = true
    //     // Здесь вызови API с параметрами из filters
    //     // ApiService.shared.getDesigns(filters: filters) { designs, error in
    //     //     DispatchQueue.main.async {
    //     //         isLoading = false
    //     //         if let designs = designs {
    //     //             popularDesigns = designs // Обнови список дизайнов
    //     //         } else {
    //     //             print("Ошибка загрузки дизайнов с фильтрами: \(error?.localizedDescription ?? "Unknown error")")
    //     //         }
    //     //     }
    //     // }
    // }
}

// Код FilterView и вспомогательных структур (OptionGrid, OptionButton, ColorGrid, ColorButton)
// выглядит корректным для работы с @Binding и closure без аргументов.
// Оставь его как есть:

/*
import SwiftUI

struct FilterView: View {
    @Binding var filters: DesignFilters
    var onApply: () -> Void // Ожидает замыкание без аргументов

    @Environment(\.presentationMode) var presentationMode

    // Локальные копии для редактирования
    @State private var shape: String?
    @State private var length: String?
    @State private var occasion: String?
    @State private var season: String?
    @State private var color: String?
    @State private var decoration: String?
    @State private var material: String?

    // Выбранная категория фильтра
    @State private var selectedCategory: FilterCategory = .shape

    // Категории фильтров
    enum FilterCategory: String, CaseIterable {
        case shape = "Форма"
        case length = "Длина"
        case occasion = "Мероприятие"
        case season = "Сезон"
        case color = "Цвет"
        case decoration = "Декор"
        case material = "Материал"
    }

    var body: some View {
        NavigationView {
            VStack {
                // Меню выбора категории
                Picker("Категория", selection: $selectedCategory) {
                    ForEach(FilterCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Контент в зависимости от выбранной категории
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        switch selectedCategory {
                        case .shape:
                            OptionGrid(
                                title: "Выберите форму",
                                options: DesignFilters.shapeOptions,
                                selectedOption: $shape
                            )
                        case .length:
                            OptionGrid(
                                title: "Выберите длину",
                                options: DesignFilters.lengthOptions,
                                selectedOption: $length
                            )
                        case .occasion:
                            OptionGrid(
                                title: "Выберите мероприятие",
                                options: DesignFilters.occasionOptions,
                                selectedOption: $occasion
                            )
                        case .season:
                            OptionGrid(
                                title: "Выберите сезон",
                                options: DesignFilters.seasonOptions,
                                selectedOption: $season
                            )
                        case .color:
                            ColorGrid(selectedColor: $color)
                        case .decoration:
                            OptionGrid(
                                title: "Выберите декор",
                                options: DesignFilters.decorationOptions,
                                selectedOption: $decoration
                            )
                        case .material:
                            OptionGrid(
                                title: "Выберите материал",
                                options: DesignFilters.materialOptions,
                                selectedOption: $material
                            )
                        }
                    }
                    .padding()
                }

                // Кнопки действий
                HStack {
                    // Кнопка сброса
                    Button(action: resetFilters) {
                        Text("Сбросить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }

                    // Кнопка применения
                    Button(action: applyFilters) {
                        Text("Применить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Фильтры", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            })
            .onAppear {
                // Инициализация локальных копий при открытии
                shape = filters.shape
                length = filters.length
                occasion = filters.occasion
                season = filters.season
                color = filters.color
                decoration = filters.decoration
                material = filters.material
            }
        }
    }

    // Сброс всех фильтров
    private func resetFilters() {
        shape = nil
        length = nil
        occasion = nil
        season = nil
        color = nil
        decoration = nil
        material = nil
    }

    // Применение фильтров
    private func applyFilters() {
        // Обновляем значения фильтров ЧЕРЕЗ @Binding filters
        filters.shape = shape
        filters.length = length
        filters.occasion = occasion
        filters.season = season
        filters.color = color
        filters.decoration = decoration
        filters.material = material

        // Вызываем обработчик в HomeView (он теперь без аргументов)
        onApply()

        // Закрываем лист
        presentationMode.wrappedValue.dismiss()
    }
}

// ... (OptionGrid, OptionButton, ColorGrid, ColorButton остаются без изменений) ...
*/

