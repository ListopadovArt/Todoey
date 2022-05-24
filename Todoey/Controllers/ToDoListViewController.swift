//
//  ViewController.swift
//  Todoey
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: UITableViewController {
    
    
    // MARK: - Properties
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigtionBarItems()
        title = selectedCategory?.name
    }
    
    
    // MARK: - Realm Methods
    func save(item: Item){
        do {
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving item \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        self.tableView.reloadData()
    }
    
    
    //MARK: - TableView DataSource and Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell else {
            return UITableViewCell()
        }
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let color = UIColor(selectedCategory!.color).darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added Yet!"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = todoItems?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(item)
                    }
                } catch {
                    print("Error delete item, \(error)")
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: - Configure NavigtionBar
    fileprivate func configureNavigtionBarItems() {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation Controller doesn't exist!")
        }
        if let colorHex = selectedCategory?.color {
            searchBar.barTintColor = UIColor(colorHex)
            let navBarColor = ContrastColorOf(UIColor(colorHex), returnFlat: true)
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: navBarColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: navBarColor]
            appearance.backgroundColor = UIColor(colorHex)
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: UIFont.Weight(900)), NSAttributedString.Key.strikethroughColor: navBarColor]
            navBar.tintColor = navBarColor
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
        }
    }
    
    
    //MARK: - Add New Items
    @IBAction func addButtunPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let currentCategory = self.selectedCategory {
                if let text = textField.text {
                    if text != "" {
                        do {
                            try self.realm.write {
                                let newItem = Item()
                                newItem.title = text
                                newItem.dateCreated = Date()
                                currentCategory.items.append(newItem)
                            }
                        } catch {
                            print("Error savint new items, \(error)")
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


//MARK: - SearchBar Delegate Methods
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
