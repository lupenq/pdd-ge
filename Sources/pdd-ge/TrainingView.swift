#if canImport(SwiftUI)
import SwiftUI

@MainActor
final class TrainingViewModel: ObservableObject {
    @Published var question: Question?
    @Published var progress = TrainingProgress(totalQuestions: 0, retiredQuestions: 0, questionsRemaining: 0, correctAnswers: 0, incorrectAnswers: 0)
    @Published var errorMessage: String?

    private let repository: QuestionRepository
    private var session: TrainingSession?

    init(repository: QuestionRepository) {
        self.repository = repository
        Task { await loadQuestions() }
    }

    func loadQuestions() async {
        let state = await repository.loadTickets()
        switch state {
        case .loaded(let tickets):
            let allQuestions = tickets.flatMap { $0.questions }
            let session = TrainingSession(questions: allQuestions)
            self.session = session
            question = session.nextQuestion()
            progress = session.currentState().progress
        case .failed(let error):
            errorMessage = error.localizedDescription
        case .loading, .idle:
            break
        }
    }

    func select(option: AnswerOption) {
        guard let question, let session else { return }
        let wasCorrect = session.answer(question: question, option: option)
        let state = session.currentState()
        withAnimation {
            progress = state.progress
        }

        if wasCorrect {
            self.question = session.nextQuestion()
        }
    }
}

struct TrainingView: View {
    @StateObject private var viewModel: TrainingViewModel

    init(repository: QuestionRepository) {
        _viewModel = StateObject(wrappedValue: TrainingViewModel(repository: repository))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            progressView
            questionContent
            Spacer()
        }
        .padding()
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("Закрыть") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Режим обучения")
                .font(.largeTitle).bold()
            Text("Отвечайте правильно на вопросы 4 раза, и они исчезнут из выборки")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var progressView: some View {
        HStack(spacing: 12) {
            Label("Всего: \(viewModel.progress.totalQuestions)", systemImage: "list.bullet")
            Label("Пройдено: \(viewModel.progress.retiredQuestions)", systemImage: "checkmark.seal")
            Label("Осталось: \(viewModel.progress.questionsRemaining)", systemImage: "hourglass")
        }
        .font(.callout)
        .padding(.vertical, 4)
    }

    private var questionContent: some View {
        Group {
            if let question = viewModel.question {
                VStack(alignment: .leading, spacing: 12) {
                    Text(question.prompt)
                        .font(.title3)
                        .fontWeight(.semibold)
                    ForEach(question.options) { option in
                        Button {
                            viewModel.select(option: option)
                        } label: {
                            HStack {
                                Text(option.text)
                                Spacer()
                                if option.isCorrect {
                                    Image(systemName: "checkmark.circle")
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue.opacity(0.8))
                    }
                }
            } else {
                ContentUnavailableView("Загрузка вопросов", systemImage: "hourglass", description: Text("Получаем билеты ПДД"))
            }
        }
    }
}
#endif
