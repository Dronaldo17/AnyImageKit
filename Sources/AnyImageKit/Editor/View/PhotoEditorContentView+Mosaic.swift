//
//  PhotoEditorContentView+Mosaic.swift
//  AnyImageKit
//
//  Created by 蒋惠 on 2019/10/29.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit

// MARK: - Public function
extension PhotoEditorContentView {
    
    func setMosaicImage(_ idx: Int) {
        mosaic?.setMosaicCoverImage(idx)
        imageView.image = mosaicCache.read(deleteMemoryStorage: false) ?? image
    }
    
    func mosaicUndo() {
        imageView.image = mosaicCache.read(deleteMemoryStorage: true) ?? image
        mosaic?.reset()
    }
    
    func mosaicCanUndo() -> Bool {
        return mosaicCache.hasDiskCache()
    }
}

// MARK: - Internal function
extension PhotoEditorContentView {
    
    /// 在子线程创建马赛克图片
    internal func setupMosaicView() {
        let idx = mosaic?.currentIdx ?? options.defaultMosaicIndex
        mosaic = nil
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard let mosaicImage = self.image.mosaicImage(level: self.options.mosaicLevel) else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                _print("Mosaic created")
                self.mosaic = Mosaic(frame: CGRect(origin: .zero, size: self.imageView.bounds.size),
                                     originalMosaicImage: mosaicImage,
                                     mosaicOptions: self.options.mosaicOptions,
                                     lineWidth: self.options.mosaicWidth)
                self.mosaic?.setMosaicCoverImage(idx)
                self.mosaic?.delegate = self
                self.mosaic?.dataSource = self
                self.mosaic?.isUserInteractionEnabled = false
                self.imageView.insertSubview(self.mosaic!, belowSubview: self.canvas)
                self.delegate?.mosaicDidCreated()
            }
        }
    }
}

// MARK: - MosaicDelegate
extension PhotoEditorContentView: MosaicDelegate {
    
    func mosaicDidBeginPen() {
        delegate?.photoDidBeginPen()
    }
    
    func mosaicDidEndPen() {
        delegate?.photoDidEndPen()
        canvas.isHidden = true // 不能把画笔部分截进去
        hiddenAllTextView() // 不能把文本截进去
        let screenshot = imageView.screenshot(image.size)
        canvas.isHidden = false
        restoreHiddenTextView()
        imageView.image = screenshot
        mosaic?.reset()
        mosaicCache.write(screenshot)
    }
}

// MARK: - MosaicDataSource
extension PhotoEditorContentView: MosaicDataSource {
    
    func mosaicGetScale(_ mosaic: Mosaic) -> CGFloat {
        return scrollView.zoomScale
    }
}
