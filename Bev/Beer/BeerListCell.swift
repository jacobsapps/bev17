//
//  BeerView.swift
//  Bev
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Domain
import Repository
import SwiftUI

struct BeerListCell: View {
    
    let beer: Beer
    
    var body: some View {
        beerContainer
            .frame(height: 144)
            .cornerRadius(12)
            .shadow(color: .primary.opacity(0.16),
                    radius: 22 / UIScreen.main.scale,
                    x: 0,
                    y: 2)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
    
    private var beerContainer: some View {
        beerDetails
            .padding(.vertical, 8)
            .padding(.leading, 136)
            .padding(.trailing, 8)
            .background(
                ZStack {
                    Color(UIColor.systemBackground)
                    HStack {
                        beerImage
                        Spacer()
                    }
                }
            )
    }
    
    private var beerImage: some View {
        AsyncImage(
            url: URL(string: beer.imageURL ?? ""),
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120)
                    .clipped()
            },
            placeholder: {
                ProgressView()
                    .frame(width: 120, alignment: .center)
            }
        )
    }
    
    private var beerDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(beer.name)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.98))
            
            Text(beer.tagline)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            Text(beer.description)
                .font(.footnote)
                .foregroundColor(.primary.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
