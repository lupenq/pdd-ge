import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol QuestionProvider: Sendable {
    func fetchTickets() async throws -> [Ticket]
}

public struct APIClient: @unchecked Sendable {
    public let baseURL: URL
    public let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func get(_ path: String) async throws -> Data {
        let requestURL = baseURL.appendingPathComponent(path)
        let (data, response) = try await session.data(from: requestURL)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

public struct RemoteQuestionProvider: QuestionProvider {
    private let client: APIClient
    private let decoder: JSONDecoder

    public init(client: APIClient, decoder: JSONDecoder = JSONDecoder()) {
        self.client = client
        self.decoder = decoder
    }

    public func fetchTickets() async throws -> [Ticket] {
        // Replace "mock/tickets" with a real endpoint once backend is ready.
        let data = try await client.get("mock/tickets")
        return try decoder.decode([Ticket].self, from: data)
    }
}

public struct MockQuestionProvider: QuestionProvider {
    public init() {}

    public func fetchTickets() async throws -> [Ticket] {
        return Self.mockTickets
    }

    static let mockTickets: [Ticket] = {
        let basicRules = Ticket(
            title: "Базовые правила",
            description: "Раздел с вопросами о базовых правилах дорожного движения Грузии",
            questions: [
                Question(
                    prompt: "Какой максимальный предел превышения скорости допустим в населённом пункте?",
                    options: [
                        AnswerOption(text: "5 км/ч", isCorrect: true),
                        AnswerOption(text: "10 км/ч", isCorrect: false),
                        AnswerOption(text: "Разрешено любое", isCorrect: false),
                        AnswerOption(text: "Нужно снизить скорость до 30 км/ч", isCorrect: false)
                    ],
                    explanation: "Правила допускают небольшое превышение в пределах 5 км/ч из-за погрешности спидометра.",
                    category: "Скорость"
                ),
                Question(
                    prompt: "Кто имеет преимущество на нерегулируемом перекрёстке равнозначных дорог?",
                    options: [
                        AnswerOption(text: "Транспорт справа", isCorrect: true),
                        AnswerOption(text: "Транспорт слева", isCorrect: false),
                        AnswerOption(text: "Автобусы", isCorrect: false),
                        AnswerOption(text: "Пешеходы", isCorrect: false)
                    ],
                    explanation: "На перекрёстке равнозначных дорог действует правило правой руки.",
                    category: "Перекрёстки"
                )
            ]
        )

        let signage = Ticket(
            title: "Дорожные знаки",
            description: "Распознавание предупреждающих и предписывающих знаков",
            questions: [
                Question(
                    prompt: "Что означает знак 'Уступи дорогу'?",
                    options: [
                        AnswerOption(text: "Обязан уступить транспортным средствам на главной", isCorrect: true),
                        AnswerOption(text: "Главная дорога", isCorrect: false),
                        AnswerOption(text: "Движение без остановки", isCorrect: false),
                        AnswerOption(text: "Конец главной дороги", isCorrect: false)
                    ],
                    explanation: "Знак сообщает о необходимости уступить транспортным средствам на пересекаемой дороге.",
                    category: "Знаки"
                ),
                Question(
                    prompt: "Когда нужно включать аварийную сигнализацию?",
                    options: [
                        AnswerOption(text: "При вынужденной остановке в месте с плохой видимостью", isCorrect: true),
                        AnswerOption(text: "При обгоне", isCorrect: false),
                        AnswerOption(text: "При движении по автомагистрали", isCorrect: false),
                        AnswerOption(text: "При повороте", isCorrect: false)
                    ],
                    explanation: "Аварийная сигнализация помогает предупредить других участников о вынужденной остановке.",
                    category: "Сигналы"
                )
            ]
        )

        return [basicRules, signage]
    }()
}

public actor QuestionRepository {
    public enum LoadingState: Sendable {
        case idle
        case loading
        case loaded([Ticket])
        case failed(Error)
    }

    private let provider: QuestionProvider
    private(set) var state: LoadingState = .idle

    public init(provider: QuestionProvider) {
        self.provider = provider
    }

    @discardableResult
    public func loadTickets() async -> LoadingState {
        state = .loading
        do {
            let tickets = try await provider.fetchTickets()
            state = .loaded(tickets)
        } catch {
            state = .failed(error)
        }
        return state
    }
}
