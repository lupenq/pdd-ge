import Foundation

public struct AnswerOption: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let text: String
    public let isCorrect: Bool

    public init(id: UUID = UUID(), text: String, isCorrect: Bool) {
        self.id = id
        self.text = text
        self.isCorrect = isCorrect
    }
}

public struct Question: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let prompt: String
    public let options: [AnswerOption]
    public let explanation: String?
    public let category: String

    public init(
        id: UUID = UUID(),
        prompt: String,
        options: [AnswerOption],
        explanation: String? = nil,
        category: String
    ) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.explanation = explanation
        self.category = category
    }
}

public struct Ticket: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let title: String
    public let description: String
    public let questions: [Question]

    public init(id: UUID = UUID(), title: String, description: String, questions: [Question]) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
    }
}

public struct TrainingProgress: Hashable, Sendable {
    public let totalQuestions: Int
    public let retiredQuestions: Int
    public let questionsRemaining: Int
    public let correctAnswers: Int
    public let incorrectAnswers: Int

    public init(totalQuestions: Int, retiredQuestions: Int, questionsRemaining: Int, correctAnswers: Int, incorrectAnswers: Int) {
        self.totalQuestions = totalQuestions
        self.retiredQuestions = retiredQuestions
        self.questionsRemaining = questionsRemaining
        self.correctAnswers = correctAnswers
        self.incorrectAnswers = incorrectAnswers
    }
}
