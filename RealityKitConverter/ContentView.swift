//
//  ContentView.swift
//  RealityKitConverter
//
//  Created by Jonas Gamburg on 02.11.22.
//

import SwiftUI
import RealityKit
import QuickLook
import QuickLookUI

struct ContentView: View {
    
    @State var selectedDirectroy:       URL?
    @State var selectedOutputDirectroy: URL?
    @State var modelItemUrl:            URL?
    @State var presentsARQuickLook:     Bool   = false
    @State var isLoading:               Bool   = false
    @State var alertPresented:          Bool   = false
    @State var progressValue:           Double = 0.0
    
    var body: some View {
        ZStack {
            HStack {
                
                VStack(alignment: .leading) {
                    Text("Images to RealityKit Object Converter")
                        .font(.title)
                        .padding(.bottom, 8)
                    
                    Text("Use this tool to create 3D models to use with RealityKit.")
                        .font(.callout)
                        .padding(.bottom)
                    
                    
                    
                    //MARK: Image Url Selection
                    Button {
                        //TODO: User selects directroy with images
                        selectFolder { url in
                            guard let url else { return }
                            
                            print("\n~~> Selected URL: \(url)")
                            selectedDirectroy = url
                        }
                        
                    } label: {
                        Text("Load images from directory")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular))
                    }
                    .padding(.bottom)
                    
                    
                    
                    //MARK: Selected Directroy Label
                    Text("Loading images from: \(selectedDirectroy?.absoluteString ?? "Not yet selected")")
                        .padding(.bottom)
                    
                    
                    
                    //MARK: Model Output Selection
                    Button {
                        //TODO: User selects directroy with images
                        selectFolder { url in
                            guard let url else { return }
                            
                            print("\n~~> Output URL selected: \(url)")
                            selectedOutputDirectroy = url
                        }
                        
                    } label: {
                        Text("Select output directory")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .regular))
                    }
                    .padding(.bottom)
                
                    
                    
                    //MARK: Selected output Directroy Label
                    Text("Output: \(selectedOutputDirectroy?.absoluteString ?? "Not yet selected")")
                        .padding(.bottom)
                    
                    
                    HStack {
                        //MARK: Start Object Process Button
                        Button {
                            let converter = RealityKitConverter()
                            withAnimation(.easeInOut(duration: 1)) {
                                isLoading = true
                            }
                            
                            converter.configureSession(
                                inputUrl: selectedDirectroy) { modelUrl in
                                    guard let modelUrl else {
                                        self.isLoading      = false
                                        self.alertPresented = true
                                        return
                                    }
                                    
                                    self.modelItemUrl = modelUrl
                                    isLoading = false
                                    
                                } progressHadler: { progressValue in
                                    self.progressValue = progressValue
                                }

                            
                            converter.startModellingProcess(
                                outputUrl: selectedOutputDirectroy,
                                detail: .preview
                            )
                            
                            
                            
                        } label: {
                            Text("Process images")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .regular))
                            
                            
                        }.disabled((selectedDirectroy == nil || selectedOutputDirectroy == nil || isLoading))
                            .padding(.bottom)
                        
                        Spacer()
                        
                        //MARK: Preview item button
                        
                        Button {
                            selectFolder(previewSelection: true) { url in
                                guard let url else { return }
                                self.modelItemUrl = url
                                
                            }
                        } label: {
                            Text("Preview item")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .regular))
                        }
                        .padding(.bottom)
                    }
                    
                    Text("• Modelling complete! Press on 'Preview item\" and select the .obj file to preview it!")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .opacity(modelItemUrl != nil ? 1 : 0)
                    
                    //MARK: Model Preview Canvas
                    ZStack {
                        QuickView(item: modelItemUrl)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .foregroundColor(.gray.opacity(0.2))
                            )
                        
                        ProgressView("Processing 3D Model...")
                            .progressViewStyle(.circular)
                            .foregroundColor(.white)
                            .opacity(isLoading ? 1 : 0)
                        
                        VStack {
                            Spacer()
                                Text("Progress: \(progressValue * 100)%")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.callout)
                                    .opacity(isLoading ? 1 : 0)
                            .padding([.leading, .bottom], 10)
                        }
                    }
                    
                }
                .padding(24)
                Spacer()
            }
                    
        }
        .frame(width: 800, height: 600)
        .alert("Error occured while processing images!", isPresented: $alertPresented) {
            Button("Close", role: .cancel) {}
        }
    }
    
    /// Prompts the user a directory selector.
    func selectFolder(previewSelection: Bool = false, _ completion: @escaping (URL?) -> Void) {

        let openPanel                     = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories    = true
        openPanel.canCreateDirectories    = true
        openPanel.canChooseFiles          = previewSelection
        
        openPanel.begin { response in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                completion(openPanel.url)
            } else {
                completion(nil)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
