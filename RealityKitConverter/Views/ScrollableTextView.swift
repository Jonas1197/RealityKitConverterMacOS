//
//  ScrollableTextView.swift
//  RealityKitConverter
//
//  Created by Jonas Gamburg on 03.11.22.
//

import SwiftUI

struct ScrollableTextViewModel {
    var text: String
}

final class ScrollableTextViewStateModel: ObservableObject {
    @Published var model: ScrollableTextViewModel = .init(text: "")
    
    init(model: ScrollableTextViewModel) {
        self.model = model
    }
}

struct ScrollableTextView: NSViewRepresentable {
    typealias NSViewType = NSScrollView
    
    @ObservedObject var stateModel: ScrollableTextViewStateModel
    
    func makeNSView(context: Context) -> NSScrollView {
        let textView              = NSTextView()
        textView.autoresizingMask = [.width, .height]
        textView.isEditable       = false
        textView.delegate         = context.coordinator
        textView.backgroundColor  = .black
        textView.textColor        = .green
        
        let scrollView                 = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView        = textView
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else {
            assertionFailure("Unexpected text view")
            return
        }
        
        if textView.delegate !== context.coordinator {
            textView.delegate = context.coordinator
        }
        
        textView.string = stateModel.model.text
        scrollView.documentView?.scroll(.init(x: 0, y: (scrollView.documentView?.bounds.size.height ?? 0) + 20))
    }
    
   
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    final class Coordinator: NSObject, NSTextViewDelegate {
        
    }
}
