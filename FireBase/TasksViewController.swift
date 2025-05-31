import UIKit
import FirebaseAuth
import FirebaseFirestore

// Делегат протоколы
protocol TaskDetailViewControllerDelegate: AnyObject {
    func taskDetailViewControllerDidUpdateTask(_ controller: TaskDetailViewController)
}

class TasksViewController: UIViewController, TaskDetailViewControllerDelegate {

    let tableView = UITableView()
    var tasks: [(id: String, title: String, description: String)] = []

    // Батырмалар
    let profileButton = UIButton(type: .system)
    let addTaskButton = UIButton(type: .system)
    let tasksButton = UIButton(type: .system)
    let inProgressButton = UIButton(type: .system)
    let doneButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Тапсырмалар"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Шығу", style: .plain, target: self, action: #selector(signOut))

        setupUI()
        fetchTasks()
    }

    func setupUI() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 80)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.layer.cornerRadius = 15
        view.addSubview(tableView)

        let buttonSize: CGFloat = 40
        let buttonY = view.bounds.height - 60
        let padding: CGFloat = 50
        let centerX = view.center.x

        profileButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
        profileButton.tintColor = .systemBlue
        profileButton.frame = CGRect(x: centerX - buttonSize - padding, y: buttonY, width: buttonSize, height: buttonSize)
        profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        view.addSubview(profileButton)

        addTaskButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addTaskButton.tintColor = .systemGreen
        addTaskButton.frame = CGRect(x: centerX - buttonSize/2, y: buttonY, width: buttonSize, height: buttonSize)
        addTaskButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        view.addSubview(addTaskButton)

        tasksButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        tasksButton.tintColor = .systemGray
        tasksButton.frame = CGRect(x: centerX + padding, y: buttonY, width: buttonSize, height: buttonSize)
        tasksButton.addTarget(self, action: #selector(refreshTasks), for: .touchUpInside)
        view.addSubview(tasksButton)

        inProgressButton.setImage(UIImage(systemName: "clock.arrow.circlepath"), for: .normal)
        inProgressButton.tintColor = .systemOrange
        inProgressButton.frame = CGRect(x: 30, y: buttonY, width: buttonSize, height: buttonSize)
        inProgressButton.addTarget(self, action: #selector(showInProgressTasks), for: .touchUpInside)
        view.addSubview(inProgressButton)

        doneButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        doneButton.tintColor = .systemGreen
        doneButton.frame = CGRect(x: view.bounds.width - buttonSize - 30, y: buttonY, width: buttonSize, height: buttonSize)
        doneButton.addTarget(self, action: #selector(showDoneTasks), for: .touchUpInside)
        view.addSubview(doneButton)
    }

    func fetchTasks() {
        let db = Firestore.firestore()
        db.collection("tasks").getDocuments { snapshot, error in
            if let error = error {
                print("Қате тапсырмаларды алу: \(error.localizedDescription)")
                return
            }

            self.tasks = snapshot?.documents.compactMap {
                guard
                    let title = $0["title"] as? String,
                    let description = $0["description"] as? String
                else { return nil }
                return (id: $0.documentID, title: title, description: description)
            } ?? []

            self.tableView.reloadData()
        }
    }

    func fetchTasks(withStatus status: String) {
        let db = Firestore.firestore()
        db.collection("tasks").whereField("status", isEqualTo: status).getDocuments { snapshot, error in
            if let error = error {
                print("Қате: \(error.localizedDescription)")
                return
            }

            self.tasks = snapshot?.documents.compactMap {
                guard
                    let title = $0["title"] as? String,
                    let description = $0["description"] as? String
                else { return nil }
                return (id: $0.documentID, title: title, description: description)
            } ?? []

            self.tableView.reloadData()
        }
    }

    @objc func addTask() {
        let alert = UIAlertController(title: "Жаңа тапсырма", message: "Тапсырма атауын және сипаттамасын енгізіңіз", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Атау"
        }
        alert.addTextField { textField in
            textField.placeholder = "Сипаттама"
        }

        alert.addAction(UIAlertAction(title: "Болдырмау", style: .cancel))
        alert.addAction(UIAlertAction(title: "Қосу", style: .default) { _ in
            guard
                let title = alert.textFields?[0].text, !title.isEmpty,
                let description = alert.textFields?[1].text
            else { return }

            self.saveTask(title: title, description: description)
        })

        present(alert, animated: true)
    }

    func saveTask(title: String, description: String) {
        let db = Firestore.firestore()
        db.collection("tasks").addDocument(data: [
            "title": title,
            "description": description,
            "status": "todo"
        ]) { error in
            if let error = error {
                print("Тапсырманы сақтау қатесі: \(error.localizedDescription)")
            } else {
                self.fetchTasks()
            }
        }
    }

    func deleteTask(taskID: String, index: Int) {
        let db = Firestore.firestore()
        db.collection("tasks").document(taskID).delete { error in
            if let error = error {
                print("Тапсырманы өшіру қатесі: \(error.localizedDescription)")
            } else {
                self.tasks.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }

    func updateTaskStatus(taskID: String, to status: String) {
        let db = Firestore.firestore()
        db.collection("tasks").document(taskID).updateData(["status": status]) { error in
            if let error = error {
                print("Статусты жаңарту қатесі: \(error.localizedDescription)")
            } else {
                self.fetchTasks()
            }
        }
    }

    @objc func refreshTasks() {
        fetchTasks()
    }

    @objc func goToProfile() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc func signOut() {
        do {
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true)
        } catch {
            print("Шығу қатесі: \(error.localizedDescription)")
        }
    }

    @objc func showInProgressTasks() {
        fetchTasks(withStatus: "inProgress")
    }

    @objc func showDoneTasks() {
        fetchTasks(withStatus: "done")
    }

    // Делегат әдісі
    func taskDetailViewControllerDidUpdateTask(_ controller: TaskDetailViewController) {
        fetchTasks()
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]

        let detailVC = TaskDetailViewController()
        detailVC.taskID = task.id
        detailVC.taskTitle = task.title
        detailVC.taskDescription = task.description
        detailVC.delegate = self // Делегатты тағайындау
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskID = tasks[indexPath.row].id

        let deleteAction = UIContextualAction(style: .destructive, title: "Өшіру") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            self.deleteTask(taskID: taskID, index: indexPath.row)
            completionHandler(true)
        }

        let inProgressAction = UIContextualAction(style: .normal, title: "Орындалуда") { [weak self] _, _, completionHandler in
            self?.updateTaskStatus(taskID: taskID, to: "inProgress")
            completionHandler(true)
        }
        inProgressAction.backgroundColor = .systemOrange

        let doneAction = UIContextualAction(style: .normal, title: "Дайын") { [weak self] _, _, completionHandler in
            self?.updateTaskStatus(taskID: taskID, to: "done")
            completionHandler(true)
        }
        doneAction.backgroundColor = .systemGreen

        let config = UISwipeActionsConfiguration(actions: [deleteAction, inProgressAction, doneAction])
        config.performsFirstActionWithFullSwipe = false

        return config
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}

// ------------------------------------------
