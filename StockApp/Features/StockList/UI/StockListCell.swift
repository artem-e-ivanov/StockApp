//
//  StockListCell.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

final class StockListCell: UITableViewCell {
    static let reuseId = "StockListCell"
    
    private var symbolLabel: UILabel!
    private var priceLabel: UILabel!
    private var changeLabel: UILabel!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        symbolLabel = UILabel()
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(symbolLabel)
        addConstraints([
            symbolLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            symbolLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            symbolLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            symbolLabel.widthAnchor.constraint(equalToConstant: 150)
        ])
        symbolLabel.textColor = .systemGray
        symbolLabel.font = .systemFont(ofSize: 25, weight: .bold)
        
        priceLabel = UILabel()
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(priceLabel)
        addConstraints([
            priceLabel.leadingAnchor.constraint(equalTo: symbolLabel.trailingAnchor, constant: 10),
            priceLabel.topAnchor.constraint(equalTo: topAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        priceLabel.textAlignment = .right
        priceLabel.textColor = .darkGray
        priceLabel.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
        
        changeLabel = UILabel()
        changeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(changeLabel)
        addConstraints([
            changeLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 10),
            changeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            changeLabel.topAnchor.constraint(equalTo: topAnchor),
            changeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            changeLabel.widthAnchor.constraint(equalToConstant: 100)
        ])
        changeLabel.textAlignment = .right
        changeLabel.textColor = .systemGray
        changeLabel.font = UIFont.monospacedSystemFont(ofSize: 20, weight: .regular)
    }
    
    func configure(stock: Stock) {
        symbolLabel.text = stock.symbol
        priceLabel.text = stock.price.formatted(.number.precision(.fractionLength(2)))
        changeLabel.text = stock.change.formatted(.number.precision(.fractionLength(2)))
        if stock.change == 0 {
            changeLabel.textColor = .systemGray
        } else {
            changeLabel.textColor = stock.change > 0 ? .systemGreen : .systemRed
        }
    }
}
