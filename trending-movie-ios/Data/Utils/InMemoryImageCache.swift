//
//  InMemoryImageCache.swift
//  trending-movie-ios
//
//  Created by PhuongDoan on 8/6/24.
//

import Foundation

class InMemoryImageCache {
    private var cache = NSCache<NSString, NSData>()

    func store(_ imageData: NSData, forKey key: String) {
        cache.setObject(imageData, forKey: key as NSString)
    }

    func retrieve(forKey key: String) -> NSData? {
        return cache.object(forKey: key as NSString)
    }

    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
