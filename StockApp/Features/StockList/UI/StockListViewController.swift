//
//  StockListViewController.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

@MainActor
final class StockListViewController: UIViewController {
    private typealias DataSource = UITableViewDiffableDataSource<Int, Stock>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Stock>

    private var tableView: UITableView!
    private var dataSource: DataSource!
    private var displayLink: CADisplayLink?
    private var stockProvider: StockProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopUpdates()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground

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
    }
    
    private func startUpdates() {
        guard displayLink == nil else { return }
        
        Task { [weak self] in
            await self?.stockProvider?.start()
        }
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopUpdates() {
        Task { [weak self] in
            await self?.stockProvider?.stop()
        }
        
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func tick(_ link: CADisplayLink) {
        Task { @MainActor [weak self] in
            let stock = await self?.stockProvider?.get()
            self?.applyUpdates(stock)
        }
    }
}

// Data related code
private extension StockListViewController {
    private func setupDataSource() {
        stockProvider = AppDIContainer.shared.resolve(StockProvider.self)
        
        dataSource = DataSource(tableView: tableView,
                                cellProvider: { tableView, indexPath, stock in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StockListCell.reuseId,
                                                           for: indexPath) as? StockListCell else {
                // Handle error
                return UITableViewCell()
            }

            cell.configure(stock: stock)
            return cell
        })
    }
    
    private func applyUpdates(_ stock: [Stock]?) {
        guard let stock = stock, !stock.isEmpty else { return }

        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(stock)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
