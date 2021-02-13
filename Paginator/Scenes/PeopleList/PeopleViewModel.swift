//
//  PeopleViewModel.swift
//  Paginator
//
//  Created by Egemen Ayhan on 13.02.2021.
//

import Foundation
typealias PeopleChangeHandler = (PeopleState.Change)->()

struct PeopleState {

    var people: [Person] = []
    var nextPage: String?

    enum Change {
        case refreshLoading
        case refreshLoaded
        case reloaded
        case errorOcurred(String?)
    }
}

class PeopleViewModel {

    var stateChangeHandler: PeopleChangeHandler?
    private(set) var state: PeopleState

    init(state: PeopleState) {
        self.state = state
    }

    private func emit(_ state: PeopleState.Change) {
        stateChangeHandler?(state)
    }

    // TODO: implementation
    func reloadData() {
        loadData(next: nil)
    }

    func loadData(next: String?) {
        emit(.refreshLoading)
        DataSource.fetch(next: next) { [weak self] (response, error) in
            self?.emit(.refreshLoaded)
            guard let strongSelf = self,
                  let response = response,
                  error == nil else {
                self?.emit(.errorOcurred(error?.errorDescription ?? "Couldn`t fetch data."))
                return
            }
            print("count: \(response.people.count)")
            if next == nil {
                strongSelf.state.people = response.people
                strongSelf.emit(.reloaded)
            } else {
                strongSelf.state.people.append(contentsOf: response.people)
                strongSelf.emit(.reloaded)
            }
        }
    }

}
