//
//  StockListViewController.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit
import Combine

@MainActor
final class StockListViewController: UIViewController {
    private let viewModel: StockListViewModel

    private var startButton: UIButton!
    private var sortControl: UISegmentedControl!
    private var tableView: UITableView!

    private var displayLink: CADisplayLink!
    private var bag = Set<AnyCancellable>()
    
    init(viewModel: StockListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDataSource()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        displayLink.isPaused = true
        displayLink.invalidate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = String(localized: "Stock")
        
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .common)

        startButton = UIButton()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: startButton)
        startButton.setImage(UIImage(systemName: "power.circle.fill"), for: .normal)
        startButton.addTarget(self, action: #selector(startStopAction), for: .primaryActionTriggered)

        sortControl = UISegmentedControl(items: StockListSortOrder.allCases.map { $0.localized })
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortControl)
        sortControl.addTarget(self, action: #selector(sortControlAction), for: .valueChanged)
        sortControl.selectedSegmentIndex = 0

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addConstraints([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        tableView.register(StockListCell.self, forCellReuseIdentifier: StockListCell.reuseId)
        tableView.delegate = self
    }
    
    private func setupDataSource() {
        viewModel.$stockProviderStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateStockProviderStatus(status)
            }
            .store(in: &self.bag)
        
        viewModel.configure(tableView: tableView) { tableView, indexPath, stock in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StockListCell.reuseId,
                                                           for: indexPath) as? StockListCell else {
                // Handle error
                return UITableViewCell()
            }

            cell.configure(stock: stock)
            return cell
        }
    }
    
    @objc private func tick(_ link: CADisplayLink) {
        Task {
            await viewModel.viewNeedsData()
        }
    }
    
    @objc private func startStopAction(_ sender: UIButton) {
        Task {
            await viewModel.startStopUpdates()
        }
    }
    
    @objc private func sortControlAction(_ sender: UISegmentedControl) {
        displayLink.isPaused = true
        
        viewModel.sortOrder = StockListSortOrder.allCases[sender.selectedSegmentIndex]

        displayLink.isPaused = false
    }
    
    private func updateStockProviderStatus(_ status: StockProviderStatus) {
        displayLink.isPaused = true
        switch status {
            case .offline:
                startButton.tintColor = .systemGray
            case .connecting:
                startButton.tintColor = .systemYellow
            case .online:
                startButton.tintColor = .systemGreen
                displayLink.isPaused = false
        }
    }
}

extension StockListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        viewModel.viewTapsOnStock(indexPath)
    }
}
