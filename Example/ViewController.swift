//
//  ViewController.swift
//  Example
//
//  Created by Laurent Grondin on 22 mai 2019.
//  Copyright © 2019 CodableCloudKit. All rights reserved.
//

import UIKit
import CodableCloudKit

// Exemple from Json/Data

/* let json = """
 {
 "username": "Federico Zanetello",
 }
 """.data(using: .utf8)!
 
 class User: Codable & Cloud {
 let username: String
 }
 
 let user = try! JSONDecoder().decode(User.self, from: json)
 */

// MARK: - User

class User: CodableCloud /* OR Codable & Cloud */ {
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case username
    }
    
    required init(username: String) {
        self.username = username
        super.init()
    }
    
    required override init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.username = try container.decode(String.self, forKey: .username)
        try super.init(from: decoder)
    }
}

// MARK: - ViewController

class ViewController: UIViewController {
    
    // MARK: - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var users = [User]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUsersFromCloud()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let user = User(username: "User\(users.count)")
        addUserInCloud(user: user)
    }
    
    // MARK: - Custom Functions
    
    func retrieveUsersFromCloud() {
        User.retrieveFromCloud(completion: { [weak self] (result: Result<[User]>) in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                print("\(data.count) users retrieved from Cloud")
                self.users.removeAll()
                self.users.append(contentsOf: data)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func addUserInCloud(user: User) {
        user.saveInCloud { [weak self] (result: Result<CKRecord>) in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                print("\(user.username) saved in Cloud")
                self.users.insert(user, at: 0)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func removeUserFromCloud(user: User, index: Int) {
        user.removeFromCloud() { [weak self] (result: Result<CKRecord.ID?>) in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                print("\(user.username) removed from Cloud")
                self.users.remove(at: index)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Extensions
// MARK: - UITableView

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        removeUserFromCloud(user: user, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
