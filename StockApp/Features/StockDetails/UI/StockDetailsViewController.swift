//
//  StockDetailsViewController.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit
import Combine

@MainActor
final class StockDetailsViewController: UIViewController {
    private let viewModel: StockDetailsViewModel
    
    private var priceLabel: UILabel!
    private var changeLabel: UILabel!
    private var displayLink: CADisplayLink!
    
    init(viewModel: StockDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        displayLink.isPaused = true
        displayLink.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        displayLink.isPaused = false
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = viewModel.symbol
        
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        view.addConstraints([
            descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .darkGray
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textAlignment = .justified
        descriptionLabel.text = StockSymbolListProvider.descriptions[viewModel.symbol]
        
        priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(priceLabel)
        view.addConstraints([
            priceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            priceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        priceLabel.textAlignment = .center
        priceLabel.textColor = .darkGray
        priceLabel.font = UIFont.monospacedSystemFont(ofSize: 40, weight: .regular)

        changeLabel = UILabel()
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(changeLabel)
        view.addConstraints([
            changeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 20)
        ])
        changeLabel.textAlignment = .center
        changeLabel.textColor = .systemGray
        changeLabel.font = UIFont.monospacedSystemFont(ofSize: 30, weight: .regular)
        
        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc private func tick(_ link: CADisplayLink) {
        Task { [weak self] in
            let stock = await self?.viewModel.viewNeedsData()
            self?.updateStock(stock)
        }
    }
    
    private func updateStock(_ stock: Stock?) {
        priceLabel.text = stock?.price.formatted(.number.precision(.fractionLength(2)))
        changeLabel.text = stock?.change.formatted(.number.precision(.fractionLength(2)))
        if stock?.change == 0 {
            changeLabel.textColor = .systemGray
        } else {
            changeLabel.textColor = (stock?.change ?? 0) > 0 ? .systemGreen : .systemRed
        }
    }
}
