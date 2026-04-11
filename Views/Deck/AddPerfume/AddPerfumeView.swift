import SwiftUI
import SwiftData

struct AddPerfumeView: View {

    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddPerfumeViewModel

    init(mode: FormMode = .create) {
        _viewModel = State(initialValue: AddPerfumeViewModel(mode: mode))
    }

    // MARK: - Body
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section("Required") {
                    TextField("Perfume name", text: $viewModel.name)

                    if viewModel.showSuggestions {
                        suggestionsView
                    }

                    if viewModel.isSearching {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    TextField("Brand", text: $viewModel.brand)

                    Picker("Family", selection: $viewModel.family) {
                        ForEach(FragranceFamily.allCases, id: \.self) { family in
                            Text(family.rawValue).tag(family)
                        }
                    }

                    Picker("Gender", selection: $viewModel.gender) {
                        ForEach(PerfumeGender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                }

                Section("Notes (optional, comma separated)") {
                    TextField("Top notes", text: $viewModel.topNotes)
                    TextField("Middle notes", text: $viewModel.middleNotes)
                    TextField("Base notes", text: $viewModel.baseNotes)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.save(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }

    // MARK: - Subviews
    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.searchResults) { result in
                Button {
                    viewModel.selectResult(result)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text(result.brand)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(result.family.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                if result.id != viewModel.searchResults.last?.id {
                    Divider()
                }
            }
        }
    }
}

#Preview {
    AddPerfumeView()
        .modelContainer(for: Perfume.self, inMemory: true)
}
