import Foundation

public final class TrainingSession {
    public struct State {
        public let currentQuestion: Question?
        public let progress: TrainingProgress
    }

    private var pool: [Question]
    private var retiredQuestions: Set<UUID> = []
    private var correctCounters: [UUID: Int] = [:]
    private var answeredCorrectly: Int = 0
    private var answeredIncorrectly: Int = 0
    private let requiredCorrectAnswers: Int

    public init(questions: [Question], requiredCorrectAnswers: Int = 4) {
        self.pool = questions.shuffled()
        self.requiredCorrectAnswers = requiredCorrectAnswers
    }

    public func nextQuestion() -> Question? {
        pool = pool.shuffled()
        return pool.randomElement()
    }

    @discardableResult
    public func answer(question: Question, option: AnswerOption) -> Bool {
        guard pool.contains(where: { $0.id == question.id }) else { return false }

        if option.isCorrect {
            answeredCorrectly += 1
            incrementCounter(for: question.id)
        } else {
            answeredIncorrectly += 1
        }

        return option.isCorrect
    }

    public func currentState() -> State {
        let progress = TrainingProgress(
            totalQuestions: pool.count + retiredQuestions.count,
            retiredQuestions: retiredQuestions.count,
            questionsRemaining: pool.count,
            correctAnswers: answeredCorrectly,
            incorrectAnswers: answeredIncorrectly
        )

        return State(currentQuestion: pool.randomElement(), progress: progress)
    }

    private func incrementCounter(for questionID: UUID) {
        let newValue = (correctCounters[questionID] ?? 0) + 1
        correctCounters[questionID] = newValue

        if newValue >= requiredCorrectAnswers {
            retireQuestion(id: questionID)
        }
    }

    private func retireQuestion(id: UUID) {
        retiredQuestions.insert(id)
        pool.removeAll { $0.id == id }
        correctCounters[id] = nil
    }
}
