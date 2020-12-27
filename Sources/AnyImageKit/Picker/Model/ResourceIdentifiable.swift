//
//  ResourceIdentifiable.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2020/12/26.
//  Copyright © 2020 AnyImageProject.org. All rights reserved.
//

import Foundation
import Photos

public protocol ResourceIdentifiable {
    
    var identifier: String { get }
}

extension PHAsset: ResourceIdentifiable {
    
    public var identifier: String {
        return localIdentifier
    }
}

extension URL: ResourceIdentifiable {
    
    public var identifier: String {
        return absoluteString
    }
}

