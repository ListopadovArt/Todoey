//
//  CategoryViewController.swift
//  Todoey
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    
    // MARK: - Properties
    var categoriesArray = [Categories]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigtionBarItems()
        loadCategories()
    }
    
    
    // MARK: - Core Data Methods
    func saveCategories(){
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Categories> = Categories.fetchRequest()){
        do {
            categoriesArray = try context.fetch(request)
        } catch {
            print("Error fetching data from categories: \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    //MARK: - TableView DataSource and Delegate Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? ToDoCell else {
            return UITableViewCell()
        }
        let category = categoriesArray[indexPath.row]
        cell.textLabel?.text = category.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ToDoListViewController") as? ToDoListViewController else {
            return
        }
        controller.selectedCategory = categoriesArray[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(categoriesArray[indexPath.row])
            self.categoriesArray.remove(at: indexPath.row)
            saveCategories()
            self.tableView.reloadData()
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
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            
            if let text = textField.text {
                if text != "" {
                    let newCategory = Categories(context: self.context)
                    newCategory.name = text
                    self.categoriesArray.append(newCategory)
                    self.saveCategories()
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
