//
//  RemoteImageLoader.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 07.09.2020.
//

import SwiftUI
import Combine
import Feedac_CoreRedux
import Feedac_UIRedux

class RemoteImageModel: ObservableObject {
    @Published var image: UIImage?
    var imageUrl: String?
    var cachedImage = CachedImage.getCachedImage()
    
    init(imageUrl: String?) {
        self.imageUrl = imageUrl
        if imageFromCache() {
            return
        }
        imageFromRemoteUrl()
    }
    
    
    func imageFromCache() -> Bool {
        guard let url = imageUrl, let cacheImage = cachedImage.get(key: url) else {
            return false
        }
        image = cacheImage
        return true
    }
    
    func imageFromRemoteUrl() {
        guard let url = imageUrl else {
            return
        }
        
        let imageURL = URL(string: url)!
        
        URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    guard let remoteImage = UIImage(data: data)?
                            .withTintColor(.clear, renderingMode: .alwaysOriginal) else {
                        return
                    }
                    
                    self.cachedImage.set(key: self.imageUrl!, image: remoteImage)
                    self.image = remoteImage
                }
            }
        }).resume()
    }
}

class CachedImage {
    var cache = NSCache<NSString, UIImage>()
    
    func get(key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    func set(key: String, image: UIImage) {
        cache.setObject(image, forKey: NSString(string: key))
    }
}

extension CachedImage {
    private static var cachedImage = CachedImage()
    static func getCachedImage() -> CachedImage {
        return cachedImage
    }
}

public struct ImageView: View {
    @ObservedObject var remoteImageModel: RemoteImageModel
    
    init(url: String?) {
        remoteImageModel = RemoteImageModel(imageUrl: url)
    }
    
    public var body: some View {
        Group {
            if let image = remoteImageModel.image {
                Image(uiImage: image).resizable()
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Activitylndicator().frame(width: 20, height: 20)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

public struct WebImageView : View {
    @SwiftUI.State var url = "https://link-to-image"
    
    public var body: some View {
        VStack {
            ImageView(url: url)
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var downloadedImage: UIImage?
    
    func load(url: String) {
        guard let imageURL = URL(string: url) else {
            fatalError("ImageURL is not correct!")
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    self.downloadedImage = nil
                    return
                }
                self.downloadedImage = UIImage(data: data)?.withTintColor(.clear, renderingMode: .alwaysOriginal)
            }
        }.resume()
    }
}
