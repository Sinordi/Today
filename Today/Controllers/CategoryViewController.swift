//
//  CategoryViewController.swift
//  Today
//
//  Created by Сергей Кривошапко on 13.08.2021.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Categories]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    
    
    
    //MARK: - TableView DataSourse Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //Создание
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    //Удаление
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            //CoreData удаляем наш объект в contex (перед тем как удаляем его из массива, иначе crash)
            context.delete(categoryArray[indexPath.row])
            
            categoryArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            //Сохраняем изменения в contex'e в нашу базу
            saveCategories()
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    //Указываем, какой VC должен быть выбран. Если было бы несколько, то нужен if (if withIdentifier = "goToItem" {let destinationVC = segue.destination as! TodoListViewController} .... )
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController

        if let indexPaht = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategories = categoryArray[indexPaht.row]
        }
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        
        //Блок do catch нужен, чтобы зашифровать данные
        do {
            try context.save()
        } catch  {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //(with request: NSFetchRequest<Item> = Item.fetchRequest()) -  если у нас в качестве аргумента нет ничего, при вызове функции, то используется Item.fetchRequest() (то, что стоит после =)
    func loadCategories(with request: NSFetchRequest<Categories> = Categories.fetchRequest()) {
        
        let request: NSFetchRequest<Categories> = Categories.fetchRequest()
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Добавь новую категорию", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Отменить", style: .destructive) { cancel in
            print("отменено")
        }
        
        let action = UIAlertAction(title: "Добавить", style: .default) { (action) in
            if let safeText = textField.text {
                
                let newCatedory = Categories(context: self.context)
                
                newCatedory.name = safeText
                
                self.categoryArray.append(newCatedory)
                self.saveCategories() //Вызываем метод для сохранения данных
                
            }
        }
        alert.addAction(cancel) //Добавляет кнопку действия к алерту
        alert.addAction(action)
        alert.addTextField { alertTextField in // Добавляет текстовое поле к алерту
            alertTextField.placeholder = "Создайте новую категорию" //Добавляет серый текст в текстовом поле
            textField = alertTextField
        }

        present(alert, animated: true) {
            
        }
    }
}


