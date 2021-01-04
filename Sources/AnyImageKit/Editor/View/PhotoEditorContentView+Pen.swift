//
//  PhotoEditorContentView+Pen.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Public function
extension PhotoEditorContentView {
    
    func canvasUndo() {
        canvas.lastPenImageView.image = penCache.read(deleteMemoryStorage: true)
        canvas.reset()
    }
    
    func canvasCanUndo() -> Bool {
        return penCache.hasDiskCache()
    }
}

// MARK: - Internal function
extension PhotoEditorContentView {
    
    func updateCanvasFrame() {
        canvas.frame = CGRect(origin: .zero, size: imageView.bounds.size)
    }
}

// MARK: - CanvasDelegate
extension PhotoEditorContentView: CanvasDelegate {
    
    func canvasDidBeginPen() {
        delegate?.photoDidBeginPen()
    }
    
    func canvasDidEndPen() {
        let screenshot = canvas.screenshot()
        canvas.lastPenImageView.image = screenshot
        canvas.reset()
        penCache.write(screenshot)
        
        delegate?.photoDidEndPen()
    }
}

// MARK: - CanvasDataSource
extension PhotoEditorContentView: CanvasDataSource {
    
    func canvasGetScale(_ canvas: Canvas) -> CGFloat {
        return scrollView.zoomScale
    }
}
