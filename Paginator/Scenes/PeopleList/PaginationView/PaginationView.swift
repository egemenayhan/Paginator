//
//  PaginationView.swift
//  Paginator
//
//  Created by Egemen Ayhan on 13.02.2021.
//

import UIKit

struct PaginationStateConfig {
    var showLoading: Bool
    var title: String
    var actionTitle: String?

    static var paginating = PaginationStateConfig(showLoading: true, title: "Incoming...", actionTitle: nil)
    static var idle = PaginationStateConfig(showLoading: false, title: "Do you want more?", actionTitle: "Load More")
    static var done = PaginationStateConfig(showLoading: false, title: "Thats all mate.", actionTitle: nil)
    static var fail = PaginationStateConfig(showLoading: false, title: "Error ocurred :(", actionTitle: "Retry")
}

enum PaginationState {
    case paginating
    case idle
    case done
    case fail

    var configuration: PaginationStateConfig {
        switch self {
        case .paginating:
            return PaginationStateConfig.paginating
        case .idle:
            return PaginationStateConfig.idle
        case .done:
            return PaginationStateConfig.done
        case .fail:
            return PaginationStateConfig.fail
        }
    }
}

class PaginationView: UIView {

    private var contentStackView = UIStackView()
    private var titleLabel = UILabel()
    private var actionButton = UIButton()
    private var activityIndicator = UIActivityIndicatorView(style: .large)

    var actionTapHandler: ((PaginationState)->())?
    private var currentState: PaginationState = .idle

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStackView)
        contentStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentStackView.axis = .vertical
        contentStackView.distribution = .fill

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(activityIndicator)
        contentStackView.addArrangedSubview(actionButton)

        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 20, weight: .medium)

        activityIndicator.hidesWhenStopped = true

        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        actionButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        actionButton.setTitleColor(.systemBlue, for: .normal)

        updateUI(state: currentState)
    }

    func updateUI(state: PaginationState) {
        currentState = state
        titleLabel.text = state.configuration.title
        state.configuration.showLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        activityIndicator.isHidden = !state.configuration.showLoading
        actionButton.isHidden = state.configuration.actionTitle == nil
        actionButton.setTitle(state.configuration.actionTitle, for: .normal)
    }

    @objc private func actionButtonTapped() {
        actionTapHandler?(currentState)
    }

}
