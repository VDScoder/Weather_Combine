//
//  MainView.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import SwiftUI

struct MainView: View {
    @StateObject var vm = MainViewModel()
    @State private var showAddCity = false
    @ScaledMetric(wrappedValue: 80, relativeTo: .callout) private var temperatureSize: CGFloat
    @State private var citySelection: Int = 0
    @State private var goToSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink (
                    destination: SettingsView(mainVm: vm),
                    isActive: $goToSettings,
                    label: {})
                GeometryReader { gp in
                    Image("atmosphere")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.75)
                        .scaleEffect(1.1)
                        .ignoresSafeArea()
                        .blur(radius: 4)
                }
                
                VStack(spacing: 20) {
                    if vm.weatherForCities.count < 1 {
                        VStack {
                            HStack {
                                Text("Нажмите")
                                Image(systemName: "plus.circle.fill")
                                Text("добавить город")
                            }
                            .font(.title.weight(.thin))
                            .padding()
                            
                            Spacer()
                        }
                    } else {
                        WeatherView(citySelection: $citySelection, vm: vm)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            goToSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.2.fill")
                                .foregroundColor(.black)
                                
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showAddCity.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.black)
                        }
                    }
                }
                
                if vm.fetchingWeather {
                    ProcessingView(message: "Загружаю данные...")
                }
            }
            .navigationTitle(Text("Погода"))
            .sheet(isPresented: $showAddCity, onDismiss: {
                citySelection = vm.cities.count-1
                vm.dismissView = false
            }, content: {
                SearchView(mainVm: vm)
            })
            .onAppear {
                vm.updateAllCityWeather()
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView(vm: MockMainViewModel())
            MainView(vm: MockMainViewModel())
                .preferredColorScheme(.dark)
        }
    }
}

