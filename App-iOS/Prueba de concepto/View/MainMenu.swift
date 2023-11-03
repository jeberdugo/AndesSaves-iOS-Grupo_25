//
//  MainMenu.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI
import UserNotifications

// MENU PRINCIPAL
struct MainMenu: View {
    @StateObject private var viewModel = MainMenuViewModel()
    @StateObject private var functions = GlobalFunctions()
    
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .mask(TopRoundedRectangle(radius: 30))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
                            .shadow(radius: 3, x: 0, y: -3))
                            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                VStack {
                Spacer(minLength: 50)
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
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
        }.onAppear(perform: scheduleNotification)
    }
}

func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Alerta de gastos"
        content.body = "Estás por encima de tus gastos estimados. ¡Cuida tus finanzas!"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request)
    }

struct TopRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY)) // start from bottom left
        path.addLine(to: CGPoint(x: 0, y: radius)) // line to top left
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: false) // top left corner
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0)) // line to top right
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: radius), radius: radius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: false) // top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // line to bottom right
        path.closeSubpath()
        return path
    }
}
