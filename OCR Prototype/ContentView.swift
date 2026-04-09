//
//  ContentView.swift
//  OCR Prototype
//
//  Created by Mathieu Dubart on 26/03/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var isShowingCamera = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(lineWidth: 2)
                        .foregroundColor(.gray.opacity(0.3))
                        .background(Color.gray.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                    
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 40))
                            Text("Prendre une photo")
                                .font(.subheadline)
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .onTapGesture {
                    sourceType = .camera
                    isShowingCamera = true
                }
                
                Form {
                    Section(header: Text("Informations extraites")) {
                        HStack {
                            Text(viewModel.field1Title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            TextField("Ex: 12/05/2024", text: $viewModel.field1Value)
                                .font(.body)
                        }
                        
                        HStack {
                            Text(viewModel.field2Title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            TextField("Ex: 45,99 €", text: $viewModel.field2Value)
                                .font(.body)
                        }
                    }
                }
                .frame(maxHeight: 200)
                
                // Option : Afficher tout le texte brut reconnu (pour débugger)
                // Section "Texte Brut"
                /*
                 if !viewModel.recognizedTextBlocks.isEmpty {
                 VStack(alignment: .leading) {
                 Text("Texte Brut Reconnu :")
                 .font(.headline)
                 .padding(.horizontal)
                 ScrollView {
                 VStack(alignment: .leading) {
                 ForEach(viewModel.recognizedTextBlocks) { block in
                 Text(block.text)
                 .font(.caption)
                 .padding(.bottom, 2)
                 }
                 }
                 .padding(.horizontal)
                 }
                 }
                 .frame(maxHeight: .infinity)
                 }
                 */
            }
            .navigationTitle("OCR Proto")
            .sheet(isPresented: $isShowingCamera) {
                // Utilise le wrapper pour UIImagePickerController
                ImagePickerView(selectedImage: $viewModel.selectedImage, sourceType: sourceType, onImagePicked: { image in
                    // Quand l'image est choisie, on lance le traitement OCR
                    viewModel.processImage(image: image)
                })
            }
        }
    }
}
