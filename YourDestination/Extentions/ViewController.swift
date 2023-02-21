//
//  ViewController.swift
//  YourDestination
//
//  Created by Abdalazem Saleh on 2023-02-19.
//

import UIKit

extension UIViewController {
    func showAlertMessage(_ message: String) {
        let alert = UIAlertController(title: "Woops.", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
