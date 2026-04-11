//
//  PerfumeDetailView.swift
//  Scentdex
//
//  Created by macbook on 27/03/2026.
//

import SwiftUI
import SwiftData


struct PerfumeDetailView: View {
    
    // MARK: - Properties
    let perfume: Perfume
    @State private var showingEdit = false
    
    
    // MARK: - BODY
    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Brand", value: perfume.brand)
                LabeledContent("Family", value: perfume.family.rawValue)
                LabeledContent("Added", value: perfume.dateAdded.formatted(date: .abbreviated, time: .omitted))
            }
            
            if !perfume.topNotes.isEmpty {
                Section("Top Notes") {
                    ForEach(perfume.topNotes, id: \.self) { note in
                        Text(note)
                    }
                }
            }
            
            if !perfume.middleNotes.isEmpty {
                Section("Middle Notes") {
                    ForEach(perfume.middleNotes, id: \.self) { note in
                        Text(note)
                    }
                }
            }
            
            if !perfume.baseNotes.isEmpty {
                Section("Base Notes") {
                    ForEach(perfume.baseNotes, id: \.self) { note in
                        Text(note)
                    }
                }
            }
        }
        .navigationTitle(perfume.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddPerfumeView(mode: .edit(perfume))
        }
    }
}

#Preview {
    NavigationStack {
        PerfumeDetailView(perfume: Perfume(
            name: "Bleu de Chanel",
            brand: "Chanel",
            family: .woody,
            topNotes: ["Bergamot", "Lemon"],
            middleNotes: ["Ginger", "Nutmeg"],
            baseNotes: ["Sandalwood", "Cedar"]
        ))
    }
    .modelContainer(for: Perfume.self, inMemory: true)
}
