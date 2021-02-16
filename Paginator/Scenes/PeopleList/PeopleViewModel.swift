//
//  PeopleViewModel.swift
//  Paginator
//
//  Created by Egemen Ayhan on 13.02.2021.
//

import Foundation
typealias PeopleChangeHandler = (PeopleState.Change)->()

struct PeopleState {

    var people: NSMutableOrderedSet = []
    var nextPage: String?
    var lastFetchAttempt: String?
    var isFetchInProgress = false

    enum Change {
        case refreshLoading
        case refreshLoaded
        case paginationLoading
        case paginationLoaded
        case paginationError
        case reloaded
        case paginated(newPeople: [Person], diffCount: Int)
        case errorOcurred(String?)
    }
}

class PeopleViewModel {

    enum Constants {
        static let fetchRetryThreshold = 3
    }

    var stateChangeHandler: PeopleChangeHandler?
    private(set) var state: PeopleState
    private var fetchRetryCount = 0

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

    func nextPage() {
        guard let next = state.nextPage else { return }
        loadData(next: next)
    }

    func retry() {
        loadData(next: state.lastFetchAttempt)
    }

    private func loadData(next: String?) {
        guard !state.isFetchInProgress else {
            emit(.refreshLoaded)
            return
        }
        let isInitialFetch = next == nil
        isInitialFetch ? emit(.refreshLoading) : emit(.paginationLoading)
        state.isFetchInProgress = true
        state.lastFetchAttempt = next
        DataSource.fetch(next: next) { [weak self] (response, error) in
            self?.state.isFetchInProgress = false
            guard let strongSelf = self,
                  let response = response,
                  error == nil else {
                if next == nil {
                    self?.emit(.refreshLoaded)
                    self?.emit(.errorOcurred(error?.errorDescription ?? "Couldn`t fetch data."))
                } else {
                    self?.emit(.paginationError)
                }
                return
            }

            guard response.people.count > 0 else { // automatically fetches next page if people count is 0
                let initialPageHasNextPage = ((response.next != nil) && isInitialFetch)
                let isNextPageDifferent = ((strongSelf.state.nextPage != nil) && !isInitialFetch && (strongSelf.state.nextPage != next))
                if (initialPageHasNextPage || isNextPageDifferent)
                    && strongSelf.fetchRetryCount < Constants.fetchRetryThreshold { // fetch if there is next page
                    strongSelf.emit(.refreshLoaded)
                    strongSelf.fetchRetryCount += 1
                    strongSelf.loadData(next: response.next)
                } else if isInitialFetch,
                          strongSelf.state.people.count == 0,
                          strongSelf.fetchRetryCount < Constants.fetchRetryThreshold { // retry initial fetch if there is no next page and people

                    strongSelf.emit(.refreshLoaded)
                    strongSelf.fetchRetryCount += 1
                    strongSelf.loadData(next: nil)
                } else if isInitialFetch { // can not retry again for initial fetch
                    strongSelf.emit(.refreshLoaded)
                    strongSelf.emit(.errorOcurred("Failed to reload page."))
                } else { // can not retry again for pagination
                    strongSelf.emit(.paginationError)
                }
                return
            }
            strongSelf.state.nextPage = response.next
            isInitialFetch ? strongSelf.emit(.refreshLoaded) : strongSelf.emit(.paginationLoaded)
            strongSelf.fetchRetryCount = 0 // reset retry count on successfull operation
            if next == nil {
                strongSelf.state.people = NSMutableOrderedSet(array: response.people)
                strongSelf.emit(.reloaded)
            } else {
                let newPeople = NSMutableOrderedSet(array: response.people) // remove duplicate values from itself
                newPeople.minus(strongSelf.state.people) // unique new people to add
                strongSelf.state.people.addObjects(from: newPeople.array) // append new people to our data source
                let diffCount = newPeople.count
                guard diffCount > 0 else { // automatically fetches next page if there is no new unique people
                    if let nextPage = strongSelf.state.nextPage {
                        strongSelf.loadData(next: nextPage)
                    }
                    return
                }
                strongSelf.emit(.paginated(newPeople: newPeople.array as? [Person] ?? [], diffCount: diffCount))
            }
        }
    }

}

extension Person: Hashable, Equatable {

    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
