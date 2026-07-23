//
//  FeedArticleCard.swift
//  Scentdex
//
//  Created by macbook on 18/05/2026.
//

import SwiftUI

struct FeedArticleCard: View {
    
    
    let article: FeedArticle
    @State private var showSafari = false

    var body: some View {
        Button {
                    if article.url != nil {
                        showSafari = true
                    }
                } label: {
                    
        HStack( spacing:16 ) {
            Text(article.emoji)
                .font(.system(size: 32))
                .frame(width: 60, height: 60)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(categoryColor.opacity(0.3), lineWidth: 0.5)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(article.category.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(categoryColor)
                    
                    Text(".")
                        .foregroundStyle(.secondary)
                    
                    Text(article.readTime)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    }
                    
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                    
                    Text(article.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.15), lineWidth: 0.5)
            )
        }
            .buttonStyle(.plain)
                .sheet(isPresented: $showSafari) {
                    if let url = article.url {
                        SafariView(url: url)
                            .ignoresSafeArea()
                            }
                        }
                    }
    
        private var categoryColor: Color {
            switch article.category {
            case .tip:        return .mint
            case .guide:      return Color(hex: "#C9A84C") ?? .yellow
            case .ingredient: return Color(hex: "#5D8A5E") ?? .green
            case .news:       return Color(hex: "#0EA5E9") ?? .blue
            }
        }
    }
