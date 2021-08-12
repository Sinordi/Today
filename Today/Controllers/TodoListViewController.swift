//
//  ViewController.swift
//  Today
//
//  Created by Сергей Кривошапко on 06.08.2021.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    //путь к файлу, в котором будут хранится данные (сами его называем как хотим и создавать такие файлы для разных категорий)
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    
    var itemArray = [Item]()
    
    
    /*
     №1 (UserDefaults) Используется для сохранения малого кол-ва данных стандартного типа
     let defaults = UserDefaults.standard
     Вначале работали с ним, потом используем другой (FileManager)
     */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems() //Метод загрузки данных с нашего сохраненного файла
        
        // №1 (UserDefaults) Воспроизведение созраненного в памяти устройства массива (грубо говоря)
    
        /*
         if let items = defaults.array(forKey: "ToDoListArray") as? [Item] {
         itemArray = items
         }
         */
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
            itemArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            saveItems()
            
            // №1 (UserDefaults) Сохранение массива в памят устройства (грубо говоря) Только для стандартного типа
            //            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //Меняет состояние done (используется для галочки (chekmark))
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems() //Здесь этот метод вызываем, чтобы обновить данные о галочке и нашем файле
        
        //обновляет таблицу после того, как поменяли состояние done
        tableView.reloadData()
        
        // Анимация выбора строки (подсвечивает выбраную строку серым на 1 сек)
        
        
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
                
                let newItem = Item()
                
                newItem.title = safeText
                
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
        let encoder = PropertyListEncoder() //свойство для шифрования данных
        
        //Блок do catch нужен, чтобы зашифровать данные
        
        do {
            let data = try encoder.encode(self.itemArray) // Зашировываем данные
            try data.write(to: self.dataFilePath!) // Записываем их в файл (определили его вначале, можем вывести его (print) и посмотреть путь)
        } catch  {
            print("Error encoding item array, \(error)")
        }
        
        // №1 (UserDefaults) Сохранение массива в памят устройства (грубо говоря) Только для стандартного типаСохранение массива в памят устройства (грубо говоря)
        //self.defaults.set(self.itemArray, forKey: "ToDoListArray")
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print(error)
            }
            
        }
    }
}

