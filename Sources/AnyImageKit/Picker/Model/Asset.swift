//
//  Asset.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/16.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import Photos

public class Asset<Resource: ResourceIdentifiable> {
    
    public let resource: Resource
    public let mediaType: MediaType
    
    var _images: [ImageKey: UIImage] = [:]
    var videoDidDownload: Bool = false
    
    var idx: Int = 0
    var state: State = .unchecked
    var selectedNum: Int = 1
    
    init(resource: Resource, mediaType: MediaType) {
        self.resource = resource
        self.mediaType = mediaType
    }
}

extension Asset where Resource == PHAsset {
    
    convenience init(idx: Int, asset: PHAsset, selectOptions: PickerSelectOption) {
        let mediaType = MediaType(asset: asset, selectOptions: selectOptions)
        self.init(resource: asset, mediaType: mediaType)
        self.idx = idx
    }
    
    var duration: TimeInterval {
        return resource.duration
    }
    
    var durationDescription: String {
        let time = Int(duration)
        let min = time / 60
        let sec = time % 60
        return String(format: "%02ld:%02ld", min, sec)
    }
}

extension Asset: ResourceIdentifiable {
    
    public var identifier: String {
        return resource.identifier
    }
}

extension Asset where Resource == PHAsset {
    
    /// 输出图像
    public var image: UIImage {
        return _image ?? .init()
    }
    
    var _image: UIImage? {
        return (_images[.output] ?? _images[.edited]) ?? _images[.initial]
    }
    
    var isReady: Bool {
        switch mediaType {
        case .photo, .photoGIF, .photoLive:
            return _image != nil
        case .video:
            return videoDidDownload
        }
    }
    
    var isCamera: Bool {
        return idx == Asset.cameraItemIdx
    }
    
    static let cameraItemIdx: Int = -1
}

extension Asset: Equatable {
    
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension Asset: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension Asset: CustomStringConvertible where Resource == PHAsset {
    
    public var description: String {
        return "<Asset> \(identifier) mediaType=\(mediaType) image=\(image)"
    }
}

// MARK: - State
extension Asset {
    
    enum State: Equatable {
        
        case unchecked
        case normal
        case selected
        case disable(AssetDisableCheckRule)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.unchecked, unchecked):
                return true
            case (.normal, normal):
                return true
            case (.selected, selected):
                return true
            case (.disable, disable):
                return true
            default:
                return false
            }
        }
    }
    
    var isUnchecked: Bool {
        return state == .unchecked
    }
    
    var isSelected: Bool {
        get {
            return state == .selected
        }
        set {
            state = newValue ? .selected : .normal
        }
    }
    
    var isDisable: Bool {
        switch state {
        case .disable(_):
            return true
        default:
            return false
        }
    }
}

// MARK: - Disable Check
extension Asset where Resource == PHAsset {

    func check(disable rules: [AssetDisableCheckRule]) {
        guard isUnchecked else { return }
        for rule in rules {
            if rule.isDisable(for: self) {
                state = .disable(rule)
                return
            }
        }
        state = .normal
    }
}

// MARK: - Original Photo
extension Asset where Resource == PHAsset {
    
    /// Fetch Photo Data 获取原图数据
    /// - Note: Only for `MediaType` Photo, GIF, LivePhoto 仅用于媒体类型为照片、GIF、实况
    /// - Parameter options: Photo Data Fetch Options 原图获取选项
    /// - Parameter completion: Photo Data Fetch Completion 原图获取结果回调
    @discardableResult
    public func fetchPhotoData(options: PhotoDataFetchOptions = .init(), completion: @escaping PhotoDataFetchCompletion) -> PHImageRequestID {
        guard resource.mediaType == .image else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestPhotoData(for: resource, options: options, completion: completion)
    }
    
    /// Fetch Photo URL 获取原图路径
    /// - Note: Only for `MediaType` Photo, PhotoGIF 仅用于媒体类型为照片、GIF
    /// - Parameter options: Photo URL Fetch Options 原图路径获取选项
    /// - Parameter completion: Photo URL Fetch Completion 原图路径获取结果回调
    @discardableResult
    public func fetchPhotoURL(options: PhotoURLFetchOptions = .init(), completion: @escaping PhotoURLFetchCompletion) -> PHImageRequestID {
        guard resource.mediaType == .image else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestPhotoURL(for: resource, options: options, completion: completion)
    }
}

// MARK: - Video
extension Asset where Resource == PHAsset {
    
    /// Fetch Video 获取视频，用于播放
    /// - Note: Only for `MediaType` Video 仅用于媒体类型为视频
    /// - Parameter options: Video Fetch Options 视频获取选项
    /// - Parameter completion: Video Fetch Completion 视频获取结果回调
    @discardableResult
    public func fetchVideo(options: VideoFetchOptions = .init(), completion: @escaping VideoFetchCompletion) -> PHImageRequestID {
        guard resource.mediaType == .video else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestVideo(for: resource, options: options, completion: completion)
    }
    
    /// Fetch Video URL 获取视频路径，用于传输
    /// - Note: Only for `MediaType` Video 仅用于媒体类型为视频
    /// - Parameter options: Video URL Fetch Options 视频路径获取选项
    /// - Parameter completion: Video URL Fetch Completion 视频路径获取结果回调
    @discardableResult
    public func fetchVideoURL(options: VideoURLFetchOptions = .init(), completion: @escaping VideoURLFetchCompletion) -> PHImageRequestID {
        guard resource.mediaType == .video else {
            completion(.failure(.invalidMediaType), 0)
            return 0
        }
        return ExportTool.requestVideoURL(for: resource, options: options, completion: completion)
    }
}

extension Asset {
    
    enum ImageKey: String, Hashable {
        
        case initial
        case edited
        case output
    }
}
