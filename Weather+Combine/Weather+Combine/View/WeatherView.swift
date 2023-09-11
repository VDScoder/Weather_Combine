//
//  WeatherView.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import SwiftUI

struct WeatherView: View {
    @Binding var citySelection: Int
    @State private var cityToDelete: City?
    
    @ObservedObject var vm: MainViewModel
    
    @ScaledMetric(wrappedValue: 68, relativeTo: .callout) private var temperatureSize: CGFloat
    @ScaledMetric(wrappedValue: 90, relativeTo: .callout) private var imageHeight: CGFloat
    @ScaledMetric(wrappedValue: 26, relativeTo: .body) private var hourlyImageHeight: CGFloat
    
    var body: some View {
        GeometryReader { gp in
            TabView(selection: $citySelection) {
                ForEach(vm.weatherForCities) { weather in
                    VStack(spacing: 20) {
                        ZStack(alignment: .top) {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("\(weather.currentWeather.temp)°")
                                    Text("\(vm.isFahrenheit ? "F" : "C")")
                                }
                                .font(.system(size: temperatureSize, weight: .thin, design: .default))
                                .padding(.top, 8)
                                
                                weather.currentWeather.image
                                    .font(.system(size: temperatureSize, weight: .thin, design: .default))
                                    .shadow(radius: 3, x: 5, y: 5)
                                    .padding(.bottom)
                                    .frame(height: imageHeight)
                                
                                Text(weather.currentWeather.description)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(RoundedRectangle(cornerRadius: 25, style: .continuous)
                                            .fill(.thinMaterial)
                                            .opacity(0.9))
                            .padding(.top, 30)
                            
                            locationView(weather: weather)
                        }
                        
                        HStack {
                            VStack {
                                Image(systemName: "thermometer")
                                    .frame(height: hourlyImageHeight, alignment: .center)
                                HStack(spacing: 2) {
                                    Text("\(weather.currentWeather.feelsLike)°")
                                    Text("\(vm.isFahrenheit ? "F" : "C")")
                                }
                                Text("Ощущается")
                                    .font(Font.footnote.weight(.thin))
                            }
                            .frame(maxWidth: .infinity)
                            VStack {
                                Image(systemName: "wind")
                                    .frame(height: hourlyImageHeight, alignment: .center)
                                
                                HStack(spacing: 2) {
                                    Text(weather.currentWeather.windSpeed)
                                }
                                Text("Скорость ветра")
                                    .font(Font.footnote.weight(.thin))
                            }
                            .frame(maxWidth: .infinity)
                            VStack {
                                Image(systemName: "cloud.sun")
                                    .frame(height: hourlyImageHeight, alignment: .center)
                                
                                HStack(spacing: 2) {
                                    Text(weather.currentWeather.clouds)
                                }
                                Text("Облачность")
                                    .font(Font.footnote.weight(.thin))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(.thinMaterial)
                                        .opacity(0.9))
                        
                        HourlyTemperatureView(weather: weather, isFahrenheit: vm.isFahrenheit)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal)
                    .tag(weather.id)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .id(vm.id)
        }
        .alert(item: $cityToDelete) { cityToDelete in
            Alert(title: Text("Удалить"),
                  message: Text("Вы действительно хотите удалить  \(cityToDelete.name)?"),
                  primaryButton: Alert.Button.cancel(Text("Отмена")),
                  secondaryButton: Alert.Button.destructive(Text("Удалить"), action: {
                    
                    if citySelection > 0 {
                        citySelection -= 1
                    }
                    vm.deleteCity(cityToDelete: cityToDelete)
                  }))
        }
    }
    
    fileprivate func locationView(weather: WeatherToView) -> some View {
        ZStack(alignment: .trailing) {
            VStack {
                HStack(spacing: 0) {
                    Text(weather.city.name)
                    if (weather.city.state.isEmpty == false) {
                        Text(", \(weather.city.state)")
                    }
                    Text(" - \(weather.city.country)")
                }
                .font(Font.body.weight(.medium))
                
                Text(weather.currentWeather.date)
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Capsule()
                            .fill(Color(UIColor.systemBackground))
                            .shadow(radius: 6))
            
            Button(action: { cityToDelete = weather.city }, label: {
                Image(systemName: "xmark.circle")
                    .font(.title.weight(.light))
                    .foregroundColor(Color(.black))
                    .padding(12)
            })
        }
        .padding(.horizontal, 30)
    }
}

struct WeatherView_Previews: PreviewProvider {
    @StateObject static var vm = MockMainViewModel()
    
    static var previews: some View {
        Group {
            ZStack {
                Image("atmosphere")
                    .resizable()
                    .opacity(0.6)
                    .ignoresSafeArea()
                WeatherView(citySelection: .constant(0), vm: vm)
            }
            ZStack {
                Image("atmosphere")
                    .resizable()
                    .ignoresSafeArea()
                WeatherView(citySelection: .constant(0), vm: vm)
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct HourlyTemperatureView: View {
    var weather: WeatherToView
    var isFahrenheit: Bool
    
    @ScaledMetric(wrappedValue: 26, relativeTo: .body) private var hourlyImageHeight: CGFloat
    
    var body: some View {
        VStack {
            Text("Температура в течении дня")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(weather.hourly) { hour in
                        VStack {
                            Text(hour.date)
                                .font(Font.body.weight(.thin))
                            HStack(spacing: 4) {
                                Text("\(hour.temp)°")
                                Text("\(isFahrenheit ? "F" : "C")")
                            }
                            .font(.title2)
                            .fixedSize()
                            
                            hour.image
                                .font(Font.body.weight(.thin))
                                .frame(height: hourlyImageHeight)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(.thinMaterial)
                                        .opacity(0.9))
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.top)
        .padding(.bottom, 8)
        .background(RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(.thinMaterial)
                        .opacity(0.9))
    }
}
