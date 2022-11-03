//
//  RealityKitConverter.swift
//  RealityKitConverter
//
//  Created by Jonas Gamburg on 02.11.22.
//

import Foundation
import RealityKit

final class RealityKitConverter {
    typealias RealityKitConverterCompletion   = (URL?)   -> Void
    typealias RealityConverterProgressHandler = (Double) -> Void
    typealias RealityConverterLogsHandler     = (String) -> Void
    
    private var inputFolderUrl: URL?            = nil
    private var outputItemUrl:  URL?            = nil
    private var session: PhotogrammetrySession? = nil
    
    @discardableResult
    func configureSession(inputUrl: URL?,
                          completion: @escaping RealityKitConverterCompletion,
                          progressHadler: RealityConverterProgressHandler? = nil,
                          logsHandler:    RealityConverterLogsHandler?     = nil) -> Bool {
        
        guard let inputUrl else {
            print("\n~~> Failed to configure Session | Invalid directory Url provided.")
            return false
        }
        
        self.inputFolderUrl = inputUrl
        
        do {
            self.session = try .init(input: inputUrl, configuration: .init())
            handleSessionOutputs { url in
                completion(url)
            } progressHandler: { progress in
                progressHadler?(progress)
            } logsHanlder: { logs in
                logsHandler?(logs)
            }
            
            
        } catch {
            print("\n~~> Provided directory path does not exist or cannot be read.")
            return false
        }
        
        return true
    }
    
    func startModellingProcess(outputUrl: URL?, detail: PhotogrammetrySession.Request.Detail) {
        guard let outputUrl else { return }
        do {
            try self.session?.process(requests: [
                .modelFile(url: outputUrl, detail: detail)
            ])
        } catch {
            print("\n~~> Could not finish modeling process: \(error)")
        }
    }
    
    
    
    private func handleSessionOutputs(_ completion: @escaping (URL?) -> Void,
                                      progressHandler: RealityConverterProgressHandler? = nil,
                                      logsHanlder:     RealityConverterLogsHandler?     = nil) -> Void {
        guard let session else { return }
        
        Task {
            for try await output in session.outputs {
                switch output {
                case .requestProgress(let request, let fraction):
                    progressHandler?(fraction)
                    logsHanlder?("\n~~> Process fraction [\(fraction)] | For request: [\(request)]")
                    
                case .requestComplete(_, let result):
                    if case .modelFile(let url) = result {
                        self.outputItemUrl = url
                        completion(url)
                        print("\n~~> Session output: Request result output at: \(url)")
                    }
                    
                case .requestError(let request, let error):
                    logsHanlder?("\n~~> Error for request [ \(request) ]\nerror = \(error)")
                    completion(nil)
                    
                case .processingComplete:
                    print("\n~~> Session output: Processing completed!")
                    logsHanlder?("\n\n~~> Session output: Processing completed!")
                    // Can exit the program here...
                    self.session = nil
                    
                default: break
                }
            }
        }
    }
}
