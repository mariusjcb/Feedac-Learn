//
//  ContentView.swift
//  Shared
//
//  Created by Marius Ilie on 04/09/2020.
//

import SwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let sutStore = Store<SutState>(SutState(), using: SutReducer)
        return ReduxStoreUIContainer(sutStore) { SutView() }
    }
}

fileprivate struct SutIncrementAction: Action { }

fileprivate struct SutState: Feedac_CoreRedux.State {
    var count = 0
}

fileprivate let SutReducer: Reducer<SutState> = { state, action in
    var state = state
    switch action {
    case _ as SutIncrementAction:
        state.count += 1
    default:
        break
    }
    return state
}

fileprivate struct SutView: ReduxView {
    struct DataModel {
        let count: Int
        let onIncrementCount: () -> Void
    }
    
    func text(for dataModel: DataModel) -> String {
        return "\(dataModel.count)"
    }
    
    func map(_ state: SutState, dispatch: @escaping Dispatcher) -> DataModel {
        DataModel(count: state.count) {
            dispatch(SutIncrementAction())
        }
    }
    
    func body(_ dataModel: DataModel) -> some View {
        VStack {
            Text(text(for: dataModel))
            Button(action: dataModel.onIncrementCount) {
                Text("Increment")
            }
        }
    }
}
