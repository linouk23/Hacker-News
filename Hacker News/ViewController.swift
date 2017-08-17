//
//  ViewController.swift
//  Hacker News
//
//  Created by Kanstantsin Linou on 8/17/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import UIKit
import SafariServices
import Firebase

class HomeController: UITableViewController, SFSafariViewControllerDelegate {
    // MARK: Model
    private var items = [Item]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var firebase = Firebase(url: Constants.FirebaseRef)
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.title = Constants.HomeTitle
        searchForItems()
    }
    private func searchForItems() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var itemsMap = [Int: Item]()
        let query = firebase?.child(byAppendingPath: Constants.TypeChildRef).queryLimited(toFirst: Constants.ItemLimit)
        // https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty
        query?.observeSingleEvent(of: .value, with: { snap in
            guard let ids = snap?.value as? [Int]
            else { return }
            // ids = [ 9129911, 9129199, 9127761, 9128141, ..., 9038733 ]
            for id in ids {
                //  https://hacker-news.firebaseio.com/v0/item/8863.json?print=pretty
                let query = self.firebase?.child(byAppendingPath: Constants.ItemChildRef)
                                          .child(byAppendingPath: String(id))
                query?.observeSingleEvent(of: .value, with: { snap in
                    itemsMap[id] = Item(data: snap!)
                    // Firebase observer is asynchronous!
                    if itemsMap.count == Int(Constants.ItemLimit) {
                        var sortedStories = [Item]()
                        for id in ids {
                            sortedStories.append(itemsMap[id]!)
                        }
                        self.items = sortedStories
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }
                })
            }
        })
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellId)
            ?? UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Constants.CellId)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(item.score) points by \(item.author)"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        if let url = item.url {
            let webViewController = SFSafariViewController(url: URL(string: url)!)
            webViewController.delegate = self
            present(webViewController, animated: true, completion: nil)
        }
    }
    // MARK: SFSafariViewControllerDelegate
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
