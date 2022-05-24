//
//  CategoryViewController.swift
//  Todoey
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    
    // MARK: - Properties
    let realm = try! Realm()
    var todoCategories: Results<Category>?
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigtionBarItems()
        loadCategories()
        tableView.rowHeight = 70
    }
    
    
    // MARK: - Realm Methods
    func save(category: Category){
        do {
            try realm.write () {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(){
        todoCategories = realm.objects(Category.self)
        self.tableView.reloadData()
    }
    
    
    //MARK: - TableView DataSource and Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoCategories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell else {
            return UITableViewCell()
        }
        
        if let category = todoCategories?[indexPath.row] {
            cell.backgroundColor = UIColor(category.color)
            cell.textLabel?.text = category.name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToDoListViewController") as? ToDoListViewController else {
            return
        }
        controller.selectedCategory = todoCategories?[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let currentCategory = todoCategories?[indexPath.row] {
                do {
                    try realm.write {
                        realm.delete(currentCategory)
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
        let navigationBar = navigationController?.navigationBar
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .systemBlue
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: UIFont.Weight(900)),
                                              NSAttributedString.Key.strikethroughColor: UIColor.white,
            ]
            navigationBar?.standardAppearance = appearance
            navigationBar?.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
        } else {
            let barAppearance = UINavigationBar.appearance()
            navigationBar?.barTintColor = .systemBlue
            navigationBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationBar?.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: UIFont.Weight(900))]
            barAppearance.setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: UIBarMetrics.defaultPrompt)
            barAppearance.shadowImage = UIImage()
        }
    }
    
    
    //MARK: - Add New Categories
    @available(iOS 14.0, *)
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            if let text = textField.text {
                if text != "" {
                    let newCategory = Category()
                    newCategory.name = text
                    newCategory.color = UIColor.random.hexString
                    self.save(category: newCategory)
                }
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
