//
//  SearchHeader.swift
//  YourDestination
//
//  Created by Abdalazem Saleh on 2023-02-19.
//

import UIKit

protocol SearchPlace: AnyObject {
    func getDestnation(_ destnation: String)
}

class SearchHeader: UITableViewHeaderFooterView {
    // MARK: - Variables
    static let reusableIdentfire = "SearchHeader"
    
    let searchTextField = UITextField()
    var constraint: [NSLayoutConstraint] = []
    
    weak var delegate: SearchPlace?
    
    // MARK: - initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        searchTextField.delegate = self
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - Configure function
    func configure() {
        addSubview(searchTextField)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.backgroundColor = .systemGray6
        searchTextField.layer.cornerRadius = 16
        
        constraint.append(searchTextField.topAnchor.constraint(equalTo: topAnchor, constant: 8))
        constraint.append(searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20))
        constraint.append(searchTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20))
        constraint.append(searchTextField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8))
        
        NSLayoutConstraint.activate(constraint)
    }
}

extension SearchHeader: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let place = textField.text else { return false }
        delegate?.getDestnation(place)
        textField.text = ""
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let place = textField.text else { return }
        delegate?.getDestnation(place)
    }
}
