//
//  ImageService.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation
import SwiftUI
import Combine
import UIKit

public class ImageService {
    public static let shared = ImageService()
    
    public enum ImageError: Error {
        case decodingError
    }
    
    public func fetchImage(url: String) -> AnyPublisher<UIImage?, Never> {
        return URLSession.shared
            .dataTaskPublisher(for: URL(string: url)!)
            .tryMap { (data, response) -> UIImage? in
                return UIImage(data: data)
            }.catch { error in
                return Just(nil)
            }.eraseToAnyPublisher()
    }
}
