///
//  TagsView.swift
//  Prueba de concepto
//
//  Created by Juan Sebastian Sanchez on 25/09/23.
//

import SwiftUI

// Vista para "Tags"
    struct TagsView: View {
        @StateObject private var viewModel = TagsViewModel()
        @StateObject private var functions = GlobalFunctions()
        @StateObject private var loginViewModel = LoginViewModel()
        
        
        
        var body: some View {
            
            ZStack() {
                Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Tags")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: 400, maxHeight: 60)

            VStack() {
                Spacer(minLength: 40)
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 50)
                {
                    
                    
                    
                    ForEach(viewModel.categoriesWithId.indices, id: \.self) { index in
                        ZStack {
                            Rectangle()
                                .fill(Color(red: 242/255, green: 242/255, blue: 242/255))
                                .frame(width: 90, height: 90)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 0.5)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)

                            VStack {
                                Spacer(minLength: 8)
                                if viewModel.categoriesWithId[index].name == "Add"{
                                    Image(viewModel.categoriesWithId[index].name)
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                }
                                else{
                                        Image("DefaultImage")
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                    }

                                Text(viewModel.categoriesWithId[index].name)
                                    .foregroundColor(.gray)
                                    .padding(10)
                                    .font(.custom("San Francisco", size: 12))
                            }
                            
                            if viewModel.categoriesWithId[index].name != "Add" {
                                if viewModel.isEditMode {
                                    Button(action: {
                                      viewModel.deleteCategory(categoryId: viewModel.categoriesWithId[index].id)
                                       viewModel.listCategories()
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .padding(5)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .offset(x: 20, y: -20)
                                    }
                                }
                            } else {
                                Button(action: {
                                    viewModel.isAddTagDialogPresented.toggle()
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                        .padding(5)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .offset(x: 20, y: -20)
                                }
                            }
                        }
                    }
                }
                .onAppear {

                    
                    viewModel.listCategories()
                            }
                
                Spacer(minLength: 30)
                .padding()
            }
            .background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isEditMode.toggle()
                    }) {
                        Text(viewModel.isEditMode ? "Done" : "Edit")
                    }
                }
            }.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .sheet(isPresented: $viewModel.isAddTagDialogPresented) {
                AddTagDialog(isPresented: $viewModel.isAddTagDialogPresented, tagName: $viewModel.newTagName, addTagAction: viewModel.addNewTag)
            }
        }
    }

struct AddTagDialog: View {
    @Binding var isPresented: Bool
    @Binding var tagName: String
    @StateObject private var viewModel = TagsViewModel()
    @StateObject private var functions = GlobalFunctions()
    @StateObject private var loginViewModel = LoginViewModel()
    
    var addTagAction: (String) -> Void // Cierre para agregar una nueva etiqueta
    
    var body: some View {
        VStack{
        ZStack() {
            Color(red: 21/255, green: 191/255, blue: 129/255).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Add new tag")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }.frame(maxWidth: 400, maxHeight: 60)
        VStack {
            
            TextField("Tag name", text: $tagName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex:"EE446D"))
                        .cornerRadius(10)
                }
                .padding()
                Spacer()
                Button(action: {
                    // Llama a la función para agregar la nueva etiqueta
                    viewModel.createCategory(name: tagName)
                    viewModel.listCategories()
                    // Cierra el diálogo
                    isPresented = false
                }) {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex:"12CD8A"))
                        .cornerRadius(10)
                }
                .padding()
                
            }
            .padding()
        }
        .padding()
        Spacer()
        }.background(functions.isDaytime ? Color.white : Color(red: 23/255, green: 24/255, blue: 25/255))
    }
}
