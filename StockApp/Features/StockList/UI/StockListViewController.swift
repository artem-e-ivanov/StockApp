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

    private var sortControl: UISegmentedControl!
    private var tableView: UITableView!
    private var dataSource: DataSource!
    private var displayLink: CADisplayLink?
    private var stockProvider: StockProvider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDataSource()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopUpdates()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "Stock"
        
        let startButton = UIButton()
        startButton.tag = 0
        startButton.setImage(UIImage(systemName: "power.circle.fill"), for: .normal)
        startButton.addTarget(self, action: #selector(startStopAction), for: .primaryActionTriggered)
        let leftButtonItem = UIBarButtonItem(customView: startButton)
        navigationItem.leftBarButtonItem = leftButtonItem

        let sortControl = UISegmentedControl()
        sortControl.addTarget(self, action: #selector(sortControlAction), for: .valueChanged)
        let rightButtonItem = UIBarButtonItem(customView: sortControl)
        navigationItem.rightBarButtonItem = rightButtonItem
        sortControl.insertSegment(withTitle: "Title", at: 0, animated: false)
        sortControl.insertSegment(withTitle: "Price", at: 1, animated: false)
        sortControl.insertSegment(withTitle: "Change", at: 2, animated: false)
        self.sortControl = sortControl

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
            // TODO: Move to model
            let stock = await self?.stockProvider?.get()
            self?.applyUpdates(stock)
        }
    }
    
    @objc private func startStopAction(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.setImage(UIImage(systemName: "power.circle"), for: .normal)
            sender.tag = 1
            startUpdates()
        } else {
            sender.setImage(UIImage(systemName: "power.circle.fill"), for: .normal)
            sender.tag = 0
            stopUpdates()
        }
    }
    
    @objc private func sortControlAction(_ sender: UISegmentedControl) {
        displayLink?.isPaused = true
        
        applyUpdatesAndSort(dataSource.snapshot().itemIdentifiers)

        displayLink?.isPaused = false
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

        var snapshot = dataSource.snapshot()
        if snapshot.numberOfSections == 0 {
            snapshot = Snapshot()
            snapshot.appendSections([0])
            snapshot.appendItems(stock)
        } else {
            var toAdd = [Stock]()
            var toChange = [Stock]()
            stock.forEach { newStock in
                if let oldStock = snapshot.itemIdentifiers.first(where: { $0.symbol == newStock.symbol }) {
                    snapshot.insertItems([newStock], afterItem: oldStock)
                    snapshot.deleteItems([oldStock])
                    toChange.append(newStock)
                } else {
                    toAdd.append(newStock)
                }
            }
            snapshot.reconfigureItems(toChange)
            snapshot.appendItems(toAdd)
        }
        
        applyUpdatesAndSort(snapshot.itemIdentifiers)
    }
    
    private func applyUpdatesAndSort(_ stock: [Stock]) {
        let sorter: (Stock, Stock) -> Bool
        if sortControl.selectedSegmentIndex == 1 {
            sorter = { $0.price > $1.price }
        } else if sortControl.selectedSegmentIndex == 2 {
            sorter = { $0.change > $1.change }
        } else {
            sorter = { $0.symbol < $1.symbol }
        }
        var stock = stock
        stock.sort(by: sorter)
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(stock)

        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
