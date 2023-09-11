//
//  SearchView.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    var mainVm: MainViewModel
    @StateObject private var vm = SearchViewModel()
    @State private var isAddingCity = false
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { gp in
                Image("Clouds")
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
                    .opacity(0.5)
            }
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("введите город", text: $vm.city)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 14)
                                .fill(Color(UIColor.systemBackground))
                                .overlay(RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.primary, lineWidth: 0.4)))
                .padding()
                
                ScrollView {
                    LazyVStack {
                        ForEach(vm.cities) { city in
                            Button(action: {
                                isAddingCity = true
                                mainVm.addCity(city: city)
                            }) {
                                VStack {
                                    HStack(spacing: 0) {
                                        Text(city.name)
                                        if (city.state.isEmpty == false) {
                                            Text(", \(city.state)")
                                        }
                                        Text(" - \(city.country)")
                                    }
                                    .font(.title3.weight(.thin))
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                }
                            }
                            .transition(.opacity.animation(.easeInOut))
                            .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.top)
            }
            .navigationTitle(Text("Добавить город"))
            .onReceive(mainVm.$dismissView) { dismissView in
                if dismissView {
                    isAddingCity = false
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            if isAddingCity {
                ProcessingView(message: "Добавляю город...")
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

struct LookupCityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SearchView(mainVm: MainViewModel())
            SearchView(mainVm: MainViewModel())
                .preferredColorScheme(.dark)
        }
    }
}
