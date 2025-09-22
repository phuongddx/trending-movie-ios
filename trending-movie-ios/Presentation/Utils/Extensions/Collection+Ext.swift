//
//  Collection+Ext.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 8/6/24.
//

import Foundation

public extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Self.Index) -> Self.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
