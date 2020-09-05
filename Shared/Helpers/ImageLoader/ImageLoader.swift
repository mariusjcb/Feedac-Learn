//
//  ImageLoader.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import UIKit
import Combine

public class ImageLoaderCache {
    public static let shared = ImageLoaderCache()
    
    private var loaders: NSCache<NSString, ImageLoader> = NSCache()
    
    public func loaderFor(path: String?) -> ImageLoader {
        let key = NSString(string: "\(path ?? "missing")")
        if let loader = loaders.object(forKey: key) {
            return loader
        } else {
            let loader = ImageLoader(path: path)
            loaders.setObject(loader, forKey: key)
            return loader
        }
    }
    
    public func loaderFor(url: URL?) -> ImageLoader {
        return loaderFor(path: url?.absoluteString)
    }
}

public final class ImageLoader: ObservableObject {
    public let path: String?
    
    public var objectWillChange = Publishers.Sequence<[UIImage?], Never>(sequence: []).eraseToAnyPublisher()
    
    @Published public var image: UIImage? = nil
    
    public var cancellable: AnyCancellable?
    
    public init(path: String?) {
        self.path = path
        
        self.objectWillChange = $image.handleEvents(receiveSubscription: { [weak self] sub in
            self?.loadImage()
        }, receiveCancel: { [weak self] in
            self?.cancellable?.cancel()
        }).eraseToAnyPublisher()
    }
    
    private func loadImage() {
        guard let poster = path, image == nil else {
            return
        }
        cancellable = ImageService.shared.fetchImage(url: poster)
            .receive(on: DispatchQueue.main)
            .assign(to: \ImageLoader.image, on: self)
    }
    
    deinit {
        cancellable?.cancel()
    }
}
