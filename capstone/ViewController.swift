//
//  ViewController.swift
//  capstone
//
//  Created by Ciaran Paik on 10/22/26.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var demoData: [String] = ["One", "Two", "Three"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView?.dataSource = self
    }

    @IBAction func actionButtonTapped(_ sender: UIButton) {
        // Example: present an alert to confirm wiring works
        let alert = UIAlertController(title: "Button Tapped", message: "Your IBAction is connected!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demoData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = demoData[indexPath.row]
        return cell
    }
}
