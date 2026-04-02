//
//  StockListViewController.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

final class StockListViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let test = UILabel()
        test.translatesAutoresizingMaskIntoConstraints = false
        test.textColor = .darkText
        test.text = "Test"
        test.font = .systemFont(ofSize: 32, weight: .bold)
        view.addSubview(test)
        view.addConstraints([
            test.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            test.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
