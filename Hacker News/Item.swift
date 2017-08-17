//
//  Item.swift
//  Hacker News
//
//  Created by Kanstantsin Linou on 8/17/17.
//  Copyright © 2017 self.edu. All rights reserved.
//

import Foundation
import Firebase

class Item: NSObject {
    let url: String?
    let title: String
    let author: String
    let score: Int
    init?(data: FDataSnapshot?) {
        guard
            let data = data?.value as? [String: Any],
            let url = data[Constants.Key.Url] as? String?,
            let title = data[Constants.Key.Title] as? String,
            let author = data[Constants.Key.Author] as? String,
            let score = data[Constants.Key.Score] as? Int
        else { return nil }
        self.url = url
        self.title = title
        self.author = author
        self.score = score
    }
}
