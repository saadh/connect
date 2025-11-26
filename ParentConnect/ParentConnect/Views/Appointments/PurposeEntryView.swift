import SwiftUI

struct PurposeEntryView: View {
    @EnvironmentObject var viewModel: AppointmentViewModel
    @FocusState private var isTextFieldFocused: Bool

    private let maxCharacters = 500
    private let minSentences = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Describe the purpose of your meeting")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("Please provide at least 2 sentences explaining why you would like to meet. This helps the representative prepare for your meeting.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            // Text Editor
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if viewModel.purpose.isEmpty {
                        Text("Please describe the purpose of your meeting...")
                            .foregroundColor(.textTertiary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                    }

                    TextEditor(text: $viewModel.purpose)
                        .focused($isTextFieldFocused)
                        .frame(minHeight: 150, maxHeight: 250)
                        .padding(12)
                        .scrollContentBackground(.hidden)
                        .background(Color.backgroundPrimary)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(borderColor, lineWidth: isTextFieldFocused ? 2 : 1)
                        )
                        .onChange(of: viewModel.purpose) { _, newValue in
                            // Limit to max characters
                            if newValue.count > maxCharacters {
                                viewModel.purpose = String(newValue.prefix(maxCharacters))
                            }
                            viewModel.validatePurpose()
                        }
                }

                // Character and Sentence Count
                HStack {
                    // Sentence count indicator
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.sentenceCount >= minSentences ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.sentenceCount >= minSentences ? .green : .textTertiary)
                            .font(.caption)

                        Text("\(viewModel.sentenceCount)/\(minSentences) sentences")
                            .font(.caption)
                            .foregroundColor(viewModel.sentenceCount >= minSentences ? .green : .textSecondary)
                    }

                    Spacer()

                    // Character count
                    Text("\(viewModel.purpose.count)/\(maxCharacters)")
                        .font(.caption)
                        .foregroundColor(characterCountColor)
                }
            }

            // Validation Message
            if !viewModel.purposeValidationMessage.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.canSubmit ? "checkmark.circle.fill" : "info.circle.fill")
                        .foregroundColor(viewModel.canSubmit ? .green : .orange)

                    Text(viewModel.purposeValidationMessage)
                        .font(.caption)
                        .foregroundColor(viewModel.canSubmit ? .green : .orange)
                }
                .padding(12)
                .background((viewModel.canSubmit ? Color.green : Color.orange).opacity(0.1))
                .cornerRadius(8)
            }

            // Tips Section
            tipsSection

            Spacer()
        }
        .onAppear {
            viewModel.validatePurpose()
        }
    }

    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Tips for a good description")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                TipRow(text: "Be specific about the topic you want to discuss")
                TipRow(text: "Include any relevant context or background")
                TipRow(text: "Mention any specific concerns or questions")
                TipRow(text: "End sentences with periods, exclamation marks, or question marks")
            }
        }
        .padding(16)
        .background(Color.yellow.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Computed Properties
    private var borderColor: Color {
        if isTextFieldFocused {
            return viewModel.canSubmit ? Color.green : Color.primaryBlue
        }
        return Color.gray.opacity(0.3)
    }

    private var characterCountColor: Color {
        if viewModel.purpose.count >= maxCharacters {
            return .red
        } else if viewModel.purpose.count >= maxCharacters - 50 {
            return .orange
        }
        return .textTertiary
    }
}

struct TipRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark")
                .font(.caption2)
                .foregroundColor(.green)

            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    PurposeEntryView()
        .environmentObject(AppointmentViewModel())
        .padding()
        .background(Color.backgroundSecondary)
}
