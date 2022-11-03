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
    
    @StateObject var inputButtonModel         = CustomButtonStateModel(model: .init(title: "Select input images directroy"))
    @StateObject var outputButtonModel        = CustomButtonStateModel(model: .init(title: "Select output directory"))
    @StateObject var processImagesButtonModel = CustomButtonStateModel(model: .init(title: "Process Images"))
    @StateObject var previewItemButtonModel   = CustomButtonStateModel(model: .init(title: "Preview Item"))
    
    @State var selectedDirectroy:       URL?
    @State var selectedOutputDirectroy: URL?
    @State var modelItemUrl:            URL?
    @State var presentsARQuickLook:     Bool   = false
    @State var isLoading:               Bool   = false
    @State var alertPresented:          Bool   = false
    @State var progressValue:           Double = 0.0
    @State var processingLogs:          String = "No logs yet..."
    
    let pickerValues                   = ["Preview", "Reduced", "Medium", "Full", "Raw"]
    @State var pickerSelection: String = "Preview"
    
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
                    
                    
                    //MARK: Input directory button
                    CustomButton(stateModel: inputButtonModel) {
                        selectFolder { url in
                            guard let url else { return }
                            selectedDirectroy = url
                        }
                    }
                    
                    
                    
                    //MARK: Selected Directroy Label
                    Text("Loading images from: \(selectedDirectroy?.absoluteString ?? "Not yet selected")")
                        .padding(.bottom)
                    
                    
                    
                    //MARK: Model Output Selection
                    CustomButton(stateModel: outputButtonModel) {
                        selectFolder { url in
                            guard let url else { return }
                            selectedOutputDirectroy = url
                        }
                    }
                
                    //MARK: Selected output Directroy Label
                    Text("Output: \(selectedOutputDirectroy?.absoluteString ?? "Not yet selected")")
                        .padding(.bottom)
                    
                    HStack {
                        //MARK: Start Object Process Button
                        CustomButton(stateModel: processImagesButtonModel, isDisabled: (selectedDirectroy == nil || selectedOutputDirectroy == nil || isLoading)) {
                            let converter = RealityKitConverter()
                            processingLogs = ""
                            withAnimation(.easeInOut(duration: 0.4)) {
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
                                    
                                } logsHandler: { logs in
                                    processingLogs += logs
                                }

                            converter.startModellingProcess(
                                outputUrl: selectedOutputDirectroy,
                                detail:    renderDetail())
                        }
                        .padding(.bottom)
                        
                        
                        Spacer()
                        
                        
                        //MARK: Preview item button
                        CustomButton(stateModel: previewItemButtonModel) {
                            selectFolder(previewSelection: true) { url in
                                guard let url else { return }
                                self.modelItemUrl = url
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    //MARK: Render Detail Picker
                    Picker("Render Detail", selection: $pickerSelection) {
                        ForEach(pickerValues, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(isLoading)
                    
                    Text("• Modelling complete! Press on 'Preview item\" and select the .obj file to preview it!")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .opacity(modelItemUrl != nil && (progressValue >= 100) ? 1 : 0)
                    
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
            
            HStack {
                Spacer()
                VStack {
                    
                    Text("Processing Logs")
                        .font(.headline)
                    ScrollableTextView(stateModel: .init(model: .init(text: processingLogs)))
                        .frame(width: 350, height: 150)

                    
//                    Text(processingLogs)
//                        .lineLimit(nil)
//                        .font(.caption2)
//                        .frame(width: 350, height: 150)
//                        .padding(4)
//                        .background(RoundedRectangle(cornerRadius: 0).foregroundColor(.gray.opacity(0.3)))
                    
                    Spacer()
                }
                .padding([.trailing, .top], 24)
            }
                    
        }
        .frame(minWidth: 900, minHeight: 800)
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
    
    private func renderDetail() -> PhotogrammetrySession.Request.Detail {
        switch self.pickerSelection {
        case "Preview": return .preview
        case "Reduced": return .reduced
        case "Medium":  return .medium
        case "Full":    return .full
        case "Raw":     return .raw
        default:        break
        }
        
        return .preview
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
