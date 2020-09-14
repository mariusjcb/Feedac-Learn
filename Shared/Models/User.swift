//
//  User.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 13.09.2020.
//

import Foundation

public struct User: Codable, Identifiable {
    public var id: String
    public var name: String
    public var isTeacher: Bool
    public var totalSalesCount: Int
    public var totalSalesAmount: Double
    public var imageUrl: URL?
    public var totalRating: Int
}

extension User {
    static func mock() -> User {
        return User(id: UUID().uuidString,
                    name: "Demo User",
                    isTeacher: [true, false].randomElement()!,
                    totalSalesCount: Int.random(in: 1...1000),
                    totalSalesAmount: Double.random(in: 100...1000),
                    imageUrl: URL(string: "https://feedac.com/img.png"),
                    totalRating: Int.random(in: 1...5))
    }
}
