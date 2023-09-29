//
//  BeerListView.swift
//  Bev
//
//  Created by Jacob Bartlett on 01/04/2023.
//

import Domain
import SwiftUI

struct BeerListView: View {

    @State private var viewModel = BeerViewModel()
    @State private var beer: Beer?
    
    var body: some View {
        NavigationStack {
            beerListView
                .overlay(loadingIndicator)
                .navigationTitle("Feature.Beer.ListView.Title")
                .toolbar(.automatic, for: .navigationBar)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { refreshButton } }
        }
        .alert(isPresented: $viewModel.showAlert) { errorAlert }
        .refreshable { viewModel.refreshBeers() }
        .task { await viewModel.loadBeers() }
    }
    
    @ViewBuilder
    private var beerListView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                if viewModel.beers.isEmpty {
                    beersSkeletonView
                    
                } else {
                    beersScrollView
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var beersSkeletonView: some View {
        ForEach([Beer.sample(id: 1, name: "Sample 1"),
                 Beer.sample(id: 2, name: "Tankard 2"),
                 Beer.sample(id: 3, name: "Bev 3"),
                 Beer.sample(id: 4, name: "Gigantic Beer 4"),
                 Beer.sample(id: 5, name: "Ale 5"),
                 Beer.sample(id: 6, name: "Lager 6")]) { beer in
            BeerListCell(beer: beer)
        }.redacted(reason: .placeholder)
    }
    
    private var beersScrollView: some View {
        ForEach(viewModel.beers) { beer in
            NavigationLink(value: beer, label: {
                BeerListCell(beer: beer)
            })
        }
        .navigationDestination(for: Beer.self, destination: {
            BeerDetailView(beer: $0)
        })
    }
    
    private var refreshButton: some View {
        Button(action: {
            viewModel.refreshBeers()
            
        }, label: {
            Image(systemName: "arrow.clockwise")
        })
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        if viewModel.isLoading {
            ProgressView()
        }
    }
    
    private var errorAlert: Alert {
        Alert(
            title: Text("Feature.Beer.ListView.Error"),
            message: Text(viewModel.errorMessage ?? ""),
            dismissButton: .default(Text("Feature.Beer.ListView.OK")) {
                viewModel.showAlert.toggle()
            }
        )
    }
}

struct BeerGridView_Previews: PreviewProvider {
    static var previews: some View {
        BeerListView()
    }
}
