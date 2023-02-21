//
//  SearchVC.swift
//  YourDestination
//
//  Created by Abdalazem Saleh on 2023-02-19.
//

import UIKit
import MapKit

class SearchVC: UIViewController {
    // MARK: - Variables
    var placeMarks: [CLPlacemark] = []

    weak var delegate: getPlaceMark?
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
        
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    // MARK: - IBActions
    
    // MARK: - Functions
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    private func configureTableView() {
        tableView.delegate      = self
        tableView.dataSource    = self
        tableView.register(UINib(nibName: SearchCell.reusbleIdentfire, bundle: .main), forCellReuseIdentifier: SearchCell.reusbleIdentfire)
        tableView.register(SearchHeader.self, forHeaderFooterViewReuseIdentifier: SearchHeader.reusableIdentfire)

    }
    
    // MARK: - Table view header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchHeader.reusableIdentfire) as! SearchHeader
        header.delegate = self
        return header
    }

    
    // MARK: - Tbale view body
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeMarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.reusbleIdentfire, for: indexPath) as! SearchCell
        let placeMark = placeMarks[indexPath.row]
        cell.name.text = placeMark.name ?? "Not data"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destnation = placeMarks[indexPath.row]
        delegate?.getCoordinate(destnation)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

// MARK: - Get place from header
extension SearchVC: SearchPlace {
    func getDestnation(_ destnation: String) {
        searchForDestnation(destnation)
    }
}

extension SearchVC: MKMapViewDelegate {
    func searchForDestnation(_ destnation: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(destnation) { places, error in
            guard let places = places, error == nil else {
                self.showAlertMessage("No data to display")
                return
            }
            self.placeMarks.removeAll()
            self.placeMarks.append(contentsOf: places)
            self.tableView.reloadData()
        }
    }
}

protocol getPlaceMark: AnyObject {
    func getCoordinate(_ placeMark: CLPlacemark)
}

