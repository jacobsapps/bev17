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
    @State private var searchText: String = ""
    
    private var beerSearchResults: [Beer] {
        if searchText.isEmpty {
            return viewModel.beers
        } else {
            return viewModel.beers.filter {
                $0.name.contains(searchText)
                || $0.tagline.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            beerListView
                .overlay(loadingIndicator)
                .navigationTitle("Feature.Beer.ListView.Title")
                .toolbar(.automatic, for: .navigationBar)
                .toolbar { ToolbarItem(placement: .navigationBarTrailing) { refreshButton } }
        }
        .searchable(text: $searchText)
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
        ForEach([Beer.sample(id: 9999991, name: "Sample 1"),
                 Beer.sample(id: 9999992, name: "Tankard 2"),
                 Beer.sample(id: 9999993, name: "Bev 3"),
                 Beer.sample(id: 9999994, name: "Gigantic Beer 4"),
                 Beer.sample(id: 9999995, name: "Ale 5"),
                 Beer.sample(id: 9999996, name: "Lager 6")]) { beer in
            BeerListCell(beer: beer)
        }.redacted(reason: .placeholder)
    }
    
    private var beersScrollView: some View {
        ForEach(beerSearchResults) { beer in
            NavigationLink(value: beer) {
                BeerListCell(beer: beer)
            }
        }
        .animation(.bouncy, value: beerSearchResults)
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
