//
//  AddPerfumeView.swift
//  Scentdex
//
//  Created by macbook on 25/03/2026.
//


import SwiftUI
import SwiftData

struct AddPerfumeView: View {
    
    
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddPerfumeViewModel()
    
    // MARK: -  Body
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section("Required") {
                    TextField("Perfume name", text: $viewModel.name)
                    TextField("Brand", text: $viewModel.brand)
                    Picker("Family", selection: $viewModel.family) {
                        ForEach(FragranceFamily.allCases, id: \.self) {family in
                            Text(family.rawValue).tag(family)
                            Picker("Gender", selection: $viewModel.gender) {
                                ForEach(PerfumeGender.allCases, id: \.self) { gender in
                                    Text(gender.rawValue).tag(gender)
                                }
                            }
                        }
                    }
                }
                //maybe delete
                Section("Notes (Optional, Comma separated)") {
                    TextField("Top notes", text: $viewModel.topNotes)
                    TextField("Middle notes", text: $viewModel.middleNotes)
                    TextField("Base notes", text: $viewModel.baseNotes)
                }
            }
            
            .navigationTitle("Add Perfume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.savePerfume(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

#Preview {
    AddPerfumeView()
        .modelContainer(for: Perfume.self, inMemory: true)
}
