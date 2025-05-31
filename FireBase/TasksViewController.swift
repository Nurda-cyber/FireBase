import UIKit
import FirebaseFirestore
import FirebaseAuth

class TasksViewController: UIViewController {

    let tableView = UITableView()
    var tasks: [(id: String, title: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        
        title = "Задания"
        navigationController?.navigationBar.prefersLargeTitles = true
  
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
        
 
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        
        setupUI()
        fetchTasks()
    }

    func setupUI() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.layer.cornerRadius = 15
        view.addSubview(tableView)
    }

    func fetchTasks() {
        let db = Firestore.firestore()
        db.collection("tasks").getDocuments { snapshot, error in
            if let error = error {
                print("Ошибка загрузки задач: \(error.localizedDescription)")
                return
            }
            
            self.tasks = snapshot?.documents.compactMap {
                guard let title = $0["title"] as? String else { return nil }
                return (id: $0.documentID, title: title)
            } ?? []
            
            self.tableView.reloadData()
        }
    }

    @objc func addTask() {
        let alert = UIAlertController(title: "Новое задание", message: "Введите название задания", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Название задания"
        }
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { _ in
            if let taskTitle = alert.textFields?.first?.text, !taskTitle.isEmpty {
                self.saveTask(title: taskTitle)
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    func saveTask(title: String) {
        let db = Firestore.firestore()
        db.collection("tasks").addDocument(data: ["title": title]) { error in
            if let error = error {
                print("Ошибка сохранения задания: \(error.localizedDescription)")
            } else {
                self.fetchTasks()
            }
        }
    }


    func deleteTask(taskID: String, index: Int) {
        let db = Firestore.firestore()
        db.collection("tasks").document(taskID).delete { error in
            if let error = error {
                print("Ошибка удаления задания: \(error.localizedDescription)")
            } else {
                self.tasks.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }

    
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
        
            let loginVC = LoginViewController() 
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print("Ошибка выхода из аккаунта: \(signOutError.localizedDescription)")
        }
    }
}

extension TasksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

   
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Өшіру") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            let taskID = self.tasks[indexPath.row].id
            self.deleteTask(taskID: taskID, index: indexPath.row)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
