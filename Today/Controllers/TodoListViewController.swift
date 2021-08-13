//
//  ViewController.swift
//  Today
//
//  Created by Сергей Кривошапко on 06.08.2021.
//


//aaaaàäæ

import UIKit
import CoreData


class TodoListViewController: UITableViewController {
    
    //CoreData создаем context. (UIApplication.shared.delegate as! AppDelegate) - тут мы получаем доступ к AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Метод загрузки данных с нашего сохраненного файла
        loadItems()
    }
    
    
    
    
    
    //MARK: - TableView Datasource methods
    
    //В этой статье можно освежить про добавление UITableView https://www.ioscreator.com/tutorials/delete-rows-table-view-ios-tutorial-ios12
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    //Создание
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        //Используется, чтобы не писать каждый раз много кода
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        
        
        // Для того, чтобы поставить галочку (chekmark) при нажатии и убрать, если она была.
        
        /*
         value = condition ? valueTrue : valueFalse
         Значение cell.accessoryType равно checkmark если item.done = true и наоборот
         */
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            //CoreData удаляем наш объект в contex (перед тем как удаляем его из массива, иначе crash)
            context.delete(itemArray[indexPath.row])
            
            itemArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            //Сохраняем изменения в contex'e в нашу базу
            saveItems()
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Меняет состояние done (используется для галочки (chekmark))
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //Здесь этот метод вызываем, чтобы обновить данные о галочке и нашем файле
        saveItems()
        
        //обновляет таблицу после того, как поменяли состояние done
        tableView.reloadData()
        
    }
    
    
    // MARK: - Add new Item
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Добавь новую задачу", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Отменить", style: .destructive) { cancel in
            print("отменено")
        }
        
        let action = UIAlertAction(title: "Добавить", style: .default) { (action) in
            if let safeText = textField.text {
                
                let newItem = Item(context: self.context)
                
                newItem.title = safeText
                newItem.done = false //Это добавили, когда начали использовать CoreData, т.к. в файле нет начального значения (и это сво-во у нас не optional)
                self.itemArray.append(newItem)
                self.saveItems() //Вызываем метод для сохранения данных
                
            }
            
            
        }
        
        
        
        
        alert.addAction(cancel) //Добавляет кнопку действия к алерту
        alert.addAction(action)
        alert.addTextField { alertTextField in // Добавляет текстовое поле к алерту
            alertTextField.placeholder = "Создайте новую заметку" //Добавляет серый текст в текстовом поле
            textField = alertTextField
        }
        
        
        
        present(alert, animated: true) {
            
        }
    }
    
    //MARK: - method for saving and loading data
    
    
    func saveItems() {
        
        //Блок do catch нужен, чтобы зашифровать данные
        do {
            try context.save()
        } catch  {
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //(with request: NSFetchRequest<Item> = Item.fetchRequest()) -  если у нас в качестве аргумента нет ничего, при вызове функции, то используется Item.fetchRequest() (то, что стоит после =)
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    
    
}

//MARK: - SearchBar methods

extension TodoListViewController:  UISearchBarDelegate {
    
    
// Запускает сортировку, при нажатии на кнопку поиск на клавиатуре
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//
//        //title CONTAINS %@ (title содержит searchBar.text!) (https://static.realm.io/downloads/files/NSPredicateCheatsheet.pdf тут есть подробнее про разные знаки, типа CONTAINS %@) [cd] используется, чтобы включить и маленькие и заглавные буквы
//
//        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request)
//    }
    
    
    // Запускает сортировку при каждом изменении текста в searchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            //запускаем в главной очереди
            DispatchQueue.main.async {
                //Используем, чтобы скрыть клавиатуру и убрать курсор с searchBar (этот метод намного глубже, чем я понял)
                searchBar.resignFirstResponder()
            }
        } else {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            
            //title CONTAINS %@ (title содержит searchBar.text!) (https://static.realm.io/downloads/files/NSPredicateCheatsheet.pdf тут есть подробнее про разные знаки, типа CONTAINS %@) [cd] используется, чтобы включить и маленькие и заглавные буквы
            
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            self.loadItems(with: request)
        }
    }
}

