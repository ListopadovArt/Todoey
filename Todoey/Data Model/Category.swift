//
//  Category.swift
//  Todoey
//
//  Created by Artem Listopadov on 24.05.22.


import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
