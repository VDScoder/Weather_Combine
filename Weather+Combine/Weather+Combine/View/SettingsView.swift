//
//  SettingsView.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var mainVm: MainViewModel
    
    var body: some View {
        Form {
            Section(header: Label("Настройки", systemImage: "gearshape.2.fill")) {
                Toggle("Фаренгейт", isOn: $mainVm.isFahrenheit)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(mainVm: MockMainViewModel())
    }
}
