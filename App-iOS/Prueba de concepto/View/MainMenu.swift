//
//  MainMenu.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI

// MENU PRINCIPAL
struct MainMenu: View {
    @StateObject private var viewModel = MainMenuViewModel()
    @StateObject private var functions = GlobalFunctions()
    
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            VStack {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 50) {
                    ForEach(viewModel.menuItems, id: \.title) { menuItem in
                        NavigationLink(destination: destinationView(for: menuItem)) {
                            ZStack {
                                Rectangle()
                                    .fill(functions.isDaytime ? Color(red: 242/255, green: 242/255, blue: 242/255): Color.white)
                                    .frame(width: 120, height: 120)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 0.5)
                                    )
                                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                                
                                VStack {
                                    Image(menuItem.imageName)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                    Text(menuItem.title)
                                        .foregroundColor(.gray)
                                        .padding(10)
                                }
                            }
                        }
                    }
                    Spacer(minLength: 30)
                        .padding()
                }
            }
        } .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
    }
}
