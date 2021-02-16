//
//  PeoplePresentation.swift
//  Paginator
//
//  Created by Egemen Ayhan on 13.02.2021.
//

import Foundation

struct PeoplePresentation {

    private(set) var people: [Person] = []

    mutating func refresh(state: PeopleState) {
        people = state.people.array as? [Person] ?? []
    }

    mutating func update(newPeople: [Person]) {
        people.append(contentsOf: Array(newPeople))
    }

}
