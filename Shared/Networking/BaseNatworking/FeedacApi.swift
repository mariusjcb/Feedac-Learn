//
//  FeedacApi.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 14.09.2020.
//

import Combine
import Foundation

protocol Api {
    static var worker: ApiWorker { get }
    static var path: FeedacApi.Path { get }
}

extension Api {
    static var worker: ApiWorker { FeedacApi.worker }
    
    static func run<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        return worker.run(request)
            .map(\.value)
            .eraseToAnyPublisher()
    }
    
    static func run<E: Encodable, T: Decodable>(
        _ method: FeedacApi.HTTPMethod = .get,
        on: FeedacApi.Path,
        path: String,
        headers: [String: String] = [:],
        params: E? = nil)
    -> AnyPublisher<T, Error> {
        var req = URLRequest(url: URL(string: "")!)
        req.httpMethod = method.rawValue
        if method != .get {
            req.httpBody = try! JSONEncoder().encode(params)
        } else {
            
        }
        return worker.run(req)
            .map(\.value)
            .eraseToAnyPublisher()
    }
}

struct FeedacApi: Api {
    static var path: Path { .root }
    
    static let worker = ApiWorker()
    static let baseUrl = URL(string: "http://feedac-api.azurewebsites.net/api/")!
    
    enum HTTPMethod: String { case get, post }
    enum Path: String {
        case root = ""
        case home
        case user
        case review
        case lesson
    }
    
    enum Home: Api {
        static var path: Path { .home }
    }
    enum User: Api {
        static var path: Path { .user }
    }
    enum Review: Api {
        static var path: Path { .review }
    }
    enum Lessons: Api {
        static var path: Path { .lesson }
    }
}
