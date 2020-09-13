//
//  TextFieldObservable.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 06.09.2020.
//

import SwiftUI
import Combine

open class TextFieldObservable: ObservableObject {
    var onUpdateText: ((String) -> ())?
    var onUpdateTextDebounced: ((String) -> ())?
    
    @Published public var text = "" {
        willSet {
            DispatchQueue.main.async {
                self.textSubject.send(newValue)
            }
        }
        didSet {
            DispatchQueue.main.async {
                self.onUpdateText?(self.text)
            }
        }
    }
        
    public let textSubject = PassthroughSubject<String, Never>()
    
    private var textCancellable: Cancellable? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    deinit {
        textCancellable?.cancel()
    }
    
    public init() {
        textCancellable = textSubject.eraseToAnyPublisher()
            .map {
                $0
        }
        .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
        .removeDuplicates()
        .filter { !$0.isEmpty }
        .sink(receiveValue: { (text) in
            self.onUpdateTextDebounced?(text)
        })
    }
}
