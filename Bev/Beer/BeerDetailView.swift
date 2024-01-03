//
//  BeerDetailView.swift
//  Bev
//
//  Created by Jacob Bartlett on 06/07/2023.
//

import Domain
import SwiftUI

struct BeerDetailView: View {
    
    let beer: Beer
    
    var body: some View {
        List {
            image
            tagline
            description
            brewInformation
            foodPairings
            yeast
            malt
            hops
        }
        .navigationTitle(beer.name)
    }
    
    private var image: some View {
        AsyncImage(
            url: URL(string: beer.imageURL ?? ""),
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 400, alignment: .center)
            },
            placeholder: { ProgressView() }
        )
    }
    
    private var tagline: some View {
        Text(beer.tagline)
            .font(.title3)
            .fontWeight(.light)
            .foregroundColor(.secondary)
    }
    
    private var description: some View {
        Text(beer.description)
            .font(.body)
            .foregroundColor(.primary.opacity(0.98))
    }
    
    private var brewInformation: some View {
        HStack {
            Text("First brewed \(beer.firstBrewed)")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(.primary.opacity(0.98))
            
            Spacer()
            
            Text(String(format: "%.2f", beer.abv) + "% abv")
                .font(.title3)
                .fontWeight(.light)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private var foodPairings: some View {
        if !beer.foodPairing.isEmpty {
            Section("Drink this with") {
                ForEach(beer.foodPairing, id: \.self) {
                    Text($0)
                        .font(.body)
                        .foregroundColor(.primary.opacity(0.98))
                }
            }
        }
    }
    
    @ViewBuilder
    private var yeast: some View {
        if let yeast = beer.ingredients.yeast {
            Section("Yeast") {
                Text(yeast)
                    .font(.body)
                    .foregroundColor(.primary.opacity(0.98))
            }
        }
    }
    
    @ViewBuilder
    private var malt: some View {
        if !beer.ingredients.malt.isEmpty {
            Section("Malt") {
                ForEach(beer.ingredients.malt.map { $0.name }, id: \.self) {
                    Text($0)
                        .font(.body)
                        .foregroundColor(.primary.opacity(0.98))
                }
            }
        }
    }
    
    @ViewBuilder
    private var hops: some View {
        if !beer.ingredients.hops.isEmpty {
            Section("Hops") {
                ForEach(beer.ingredients.hops.map { $0.name }, id: \.self) {
                    Text($0)
                        .font(.body)
                        .foregroundColor(.primary.opacity(0.98))
                }
            }
        }
    }
}
