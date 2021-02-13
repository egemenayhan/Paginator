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
    private lazy var paginationView = {
        return PaginationView(frame: CGRect(
            x: 0,
            y: 0,
            width: tableView.bounds.width,
            height: 80
        ))
    }()
    private lazy var emptyView: UIView = {
        let emptyLabel = UILabel()
        emptyLabel.textAlignment = .center
        emptyLabel.text = "Nothing to see here..."
        return emptyLabel
    }()

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
                self.refreshControl.programaticallyBeginRefreshing(in: self.tableView)
            case .refreshLoaded:
                self.refreshControl.endRefreshing()
            case .paginationLoading:
                self.paginationView.updateUI(state: .paginating)
            case .paginationLoaded:
                let paginationState: PaginationState = self.viewModel.state.nextPage == nil ? .done : .idle
                self.paginationView.updateUI(state: paginationState)
            case .paginationError:
                self.paginationView.updateUI(state: .fail)
            case .reloaded:
                self.presentation.refresh(state: self.viewModel.state)
                self.tableView.contentOffset = .zero
                self.tableView.reloadData()
                self.showEmptyViewIfNecessary()
            case .paginated(let people, let diffCount):
                self.handlePagination(newPeople: people, diffCount: diffCount)
            case .errorOcurred(let error):
                self.showEmptyViewIfNecessary()
                self.showError(message: error)
            }
        }
    }

    private func setupUI() {
        title = "People"

        paginationView.actionTapHandler = { [weak self] (state) in
            guard let self = self else { return }
            switch state {
            case .idle:
                self.viewModel.nextPage()
            case .fail:
                self.viewModel.retry()
            default:
                break
            }
        }

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = paginationView
        tableView.allowsSelection = false
        tableView.delegate = self
    }

    @objc private func refresh(_ sender: AnyObject) {
        viewModel.reloadData()
    }

    private func showError(message: String?) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        let retryAction = UIAlertAction(title: "Retry", style: .default) { [weak self] (_) in
            self?.viewModel.retry()
        }
        alertController.addAction(retryAction)
        let dismissAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }

    private func showEmptyViewIfNecessary() {
        guard presentation.people.isEmpty else {
            tableView.backgroundView = nil
            return
        }
        tableView.backgroundView = emptyView
    }

    private func handlePagination(newPeople: [Person], diffCount: Int) {
        self.presentation.update(newPeople: newPeople)
        var newIndexes: [IndexPath] = []
        let lowerBound = presentation.people.count - diffCount
        for index in lowerBound..<presentation.people.count {
            newIndexes.append(IndexPath(row: index, section: 0))
        }
        tableView.performBatchUpdates { [weak self] in
            self?.tableView.insertRows(at: newIndexes, with: .automatic)
        }
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

        let person = presentation.people[indexPath.row]
        cell.textLabel?.text = "\(person.id) - \(person.fullName)"
        cell.textLabel?.textColor = .white

        return cell
    }

}

extension PeopleController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presentation.people.count - 1 {
            viewModel.nextPage()
        }
    }
}

extension UIRefreshControl {
    func programaticallyBeginRefreshing(in tableView: UITableView) {
        beginRefreshing()
        let offsetPoint = CGPoint.init(x: 0, y: -frame.size.height)
        tableView.setContentOffset(offsetPoint, animated: true)
    }
}
