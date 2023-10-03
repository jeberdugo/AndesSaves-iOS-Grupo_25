//
//  SummaryView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI

// Vista para "Summary"
    struct SummaryView: View {
        @StateObject private var functions = GlobalFunctions()
        
        var body: some View {
            VStack(){
                ZStack() {
                    Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Summary")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }.frame(maxWidth: 400, maxHeight: 60)
                Spacer()
                VStack() {
                    
                }
            }
            .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
        }
    }
    
