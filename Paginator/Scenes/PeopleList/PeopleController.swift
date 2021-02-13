//
//  PeopleController.swift
//  Paginator
//
//  Created by Egemen Ayhan on 13.02.2021.
//

import UIKit

class PeopleController: UIViewController {

    private var presentation = PeoplePresentation()
    private var viewModel = PeopleViewModel(state: PeopleState())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

