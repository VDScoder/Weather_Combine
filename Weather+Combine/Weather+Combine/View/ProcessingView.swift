//
//  ProcessingView.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import SwiftUI

struct ProcessingView: View {
    var message: String
    
    var body: some View {
        VStack {
            ProgressView()
                .scaleEffect(2)
                .padding()
            Text(message)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color.secondary.opacity(0.3)))
    }
}

struct ProcessingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProcessingView(message: "Processing...")
                .previewLayout(.sizeThatFits)
            ProcessingView(message: "Processing...")
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
