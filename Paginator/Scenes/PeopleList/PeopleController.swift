//
//  PeopleController.swift
//  Paginator
//
//  Created by Egemen Ayhan on 13.02.2021.
//

import UIKit

class PeopleController: UIViewController {

    private enum Constants {
        enum Cell {
            static let reuseIdentifier = "personCell"
        }
    }

    @IBOutlet private weak var tableView: UITableView!

    private var presentation = PeoplePresentation()
    private var viewModel = PeopleViewModel(state: PeopleState())
    private var refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewModel()
        setupUI()

        viewModel.reloadData()
    }

    func configureViewModel() {
        viewModel.stateChangeHandler = { [weak self] (change) in
            guard let self = self else { return }
            switch change {
            case .refreshLoading:
                self.refreshControl.beginRefreshing()
            case .refreshLoaded:
                self.refreshControl.endRefreshing()
            case .reloaded:
                self.presentation.refresh(state: self.viewModel.state)
                self.tableView.contentOffset = .zero
                self.tableView.reloadData()
            case .errorOcurred(let error):
                self.showError(message: error)
            }
        }
    }

    private func setupUI() {
        title = "People"

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView(frame: .zero)
    }

    @objc private func refresh(_ sender: AnyObject) {
        viewModel.reloadData()
    }

    private func showError(message: String?) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }

}

extension PeopleController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presentation.people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.Cell.reuseIdentifier,
            for: indexPath
        )
        cell.textLabel?.text = presentation.people[indexPath.row].fullName
        cell.textLabel?.textColor = .white

        return cell
    }

}

