//
//  CustomButton.swift
//  RealityKitConverter
//
//  Created by Jonas Gamburg on 03.11.22.
//

import SwiftUI

struct CustomButtonModel {
    var title:      String
    
    static let example: CustomButtonModel = .init(title: "Example Button")
}

typealias CustomButtonActionHandler = () -> Void

final class CustomButtonStateModel: ObservableObject {
    @Published var model:  CustomButtonModel
    
    init(model: CustomButtonModel) {
        self.model = model
    }
}

struct CustomButton: View {
    var stateModel: CustomButtonStateModel
    var isDisabled: Bool = false
    var action:     CustomButtonActionHandler
    
    var body: some View {
        Button(stateModel.model.title, action: action)
            .disabled(isDisabled)
    }
    
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(stateModel: .init(model: .example), action: {})
    }
}
