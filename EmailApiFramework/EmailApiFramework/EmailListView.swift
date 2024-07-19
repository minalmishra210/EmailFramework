//
//  EmailListView.swift
//  EmailApiFramework
//
//  Created by Meenal Mishra on 02/07/24.
//

import Foundation
import UIKit

public class EmailListView: UIViewController {
    
    private var tableView: UITableView!
    private var emails: [String] = []
    private var fetchedEmails : [String] = []
    public var dataHandler: ((String) -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        apiCall()
    }
    
    func apiCall() {
        if !emails.isEmpty {
            setupView()
            return
        }
        
        APIManager.shared.getEmailAddresses { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let jsonDict):
                var fetchedEmails: [String] = []
                for i in 0..<jsonDict.count {
                    fetchedEmails.append(jsonDict[i]["employee_name"] as? String ?? "")
                }
                self.emails = fetchedEmails
                DispatchQueue.main.async {
                    self.setupView()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }

    
    func setupView() {
        let viewWidth: CGFloat = UIScreen.main.bounds.width - 40.0
        let viewHeight: CGFloat = UIScreen.main.bounds.height - 150.0
        
        let screenWidth = UIScreen.main.bounds.width
        
        let centerX = screenWidth / 2
        
        let viewFrame = CGRect(x: centerX - (viewWidth / 2),
                               y: 20,width: viewWidth,height: viewHeight)
        
        tableView = UITableView(frame: viewFrame, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EmailCell")
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        let button = UIButton(type: .system)
        button.setTitle("Send back data!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.frame = CGRect(x: (UIScreen.main.bounds.width / 2) - 100, y: tableView.frame.size.height + 40, width: 200, height: 50)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        view.addSubview(button)
        tableView.reloadData()
    }
    
    @objc func buttonTapped() {
        sendDataBack()
        self.dismiss(animated: true)
    }
    
    func sendDataBack() {
        dataHandler?(emails[0])
    }
}

extension EmailListView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmailCell", for: indexPath)
        cell.textLabel?.text = emails[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
