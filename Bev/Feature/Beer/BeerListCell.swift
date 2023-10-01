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
    
    @Environment(\.colorScheme) var colorScheme
    
    let beer: Beer
    
    var body: some View {
        beerContainer
            .frame(height: 144)
            .background(Color(colorScheme == .dark ? UIColor.darkGray : UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: colorScheme == .dark ? .clear
                                                : .primary.opacity(0.16),
                    radius: 22 / UIScreen.main.scale,
                    x: 0, y: 2)
            .padding(.bottom, 16)
    }
    
    private var beerContainer: some View {
        HStack(spacing: 16) {
            beerImage
            beerDetails
        }
    }
    
    @ViewBuilder
    private var beerImage: some View {
        if let urlString = beer.imageURL,
           let url = URL(string: urlString) {
            AsyncImage(
                url: url,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                },
                placeholder: {
                    ProgressView()
                }
            )
            .frame(width: 120, alignment: .center)
        }
    }
    
    private var beerDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(beer.name)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primary.opacity(0.98))
                .multilineTextAlignment(.leading)
            
            Text(beer.tagline)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 4)
            
            Text(beer.details)
                .font(.footnote)
                .foregroundColor(.primary.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .truncationMode(.tail)
        }
        .padding(.vertical, 8)
        .padding(.trailing, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
