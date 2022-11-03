//
//  QuickView.swift
//  RealityKitConverter
//
//  Created by Jonas Gamburg on 02.11.22.
//

import SwiftUI
import QuickLook
import QuickLookUI

struct QuickView: NSViewRepresentable {
    
    var item: URL?
    
    func makeNSView(context: Context) -> some NSView {
        guard let item else { return QLPreviewView() }
        let preview          = QLPreviewView(frame: .zero, style: .normal)
        preview?.autostarts  = true
        preview?.previewItem = item as QLPreviewItem
        
        return preview ?? QLPreviewView()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        guard let item else { return }
        (nsView as! QLPreviewView).previewItem = item as QLPreviewItem
    }
}

