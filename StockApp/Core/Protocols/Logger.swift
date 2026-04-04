//
//  Logger.swift
//  StockApp
//
//  Created by developer on 1/4/26.
//

import UIKit

nonisolated protocol Logger: AnyObject {
    func log(_ message: String)
}
