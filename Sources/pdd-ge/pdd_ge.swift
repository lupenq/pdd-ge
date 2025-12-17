import Foundation

#if os(iOS)
import SwiftUI

@main
struct PddGeApp: App {
    private let repository = QuestionRepository(provider: MockQuestionProvider())

    var body: some Scene {
        WindowGroup {
            TrainingView(repository: repository)
        }
    }
}
#else
@main
struct PddGeCLI {
    static func main() async {
        let repository = QuestionRepository(provider: MockQuestionProvider())
        let state = await repository.loadTickets()

        guard case .loaded(let tickets) = state else {
            print("Не удалось загрузить билеты")
            return
        }

        let questions = tickets.flatMap { $0.questions }
        let session = TrainingSession(questions: questions)

        print("Запуск демо-режима обучения: \(questions.count) вопросов, удаляются после 4 правильных ответов")
        var question = session.nextQuestion()
        var counter = 0

        while let current = question, counter < 4 {
            guard let option = current.options.randomElement() else { break }
            let isCorrect = session.answer(question: current, option: option)
            let status = isCorrect ? "✅" : "❌"
            print("\(status) Ответ на вопрос: \(current.prompt)")
            question = session.nextQuestion()
            counter += 1
        }

        let stateSnapshot = session.currentState().progress
        print("\nИтог: \(stateSnapshot.retiredQuestions) вопросов снято после 4 верных ответов")
        print("Правильных ответов: \(stateSnapshot.correctAnswers). Ошибок: \(stateSnapshot.incorrectAnswers)")
    }
}
#endif
