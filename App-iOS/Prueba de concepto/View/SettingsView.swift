//
//  SettingsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI

// Vista para "Settings"
    struct SettingsView: View {
        @StateObject private var functions = GlobalFunctions()
        
        var body: some View {
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }.frame(maxWidth: 400, maxHeight: 60)
            Spacer()
            VStack(){
            VStack() {
                HStack() {
                    Image(systemName: "dollarsign.circle")
                        .foregroundColor(.blue)
                        .padding(.leading, 16)
                        .frame(width: 30, height: 30)
                    
                    SectionView(title: "Currency")
                        .font(.headline)
                        .padding(.leading, 16)
                        .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                    
                    Spacer()}
                
                Divider()
                
                HStack(){
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .padding(.leading, 16)
                        .frame(width: 30, height: 30)
                    
                    SectionView(title: "Language")
                        .font(.headline)
                        .padding(.leading, 16)
                        .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                    
                    Spacer()}
                
                Divider()
                
                HStack() {
                    Image(systemName: "bell")
                        .foregroundColor(.blue)
                        .padding(.leading, 16)
                        .frame(width: 30, height: 30)
                    
                    SectionView(title: "Notifications")
                        .font(.headline)
                        .padding(.leading, 16)
                        .foregroundColor(functions.isDaytime ? Color.black : Color.white)
                    
                    Spacer()}
                
            }
            Spacer()
                }.background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                }
            }

                struct SectionView: View {
                    var title: String

                    var body: some View {
                        HStack {
                            Text(title)
                                .font(.headline)
                                .padding(.leading, 16)

                            Spacer()
                        }
                        .frame(height: 40)
                    }
                }
