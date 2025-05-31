
import UIKit
import FirebaseFirestore

class TaskDetailViewController: UIViewController {

    var taskID: String? // Firestore құжатының ID-сі
    var taskTitle: String?
    var taskDescription: String?

    weak var delegate: TaskDetailViewControllerDelegate? // Делегат

    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()

    private var isEditingTask = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Тапсырма мәліметі"
        navigationController?.navigationBar.prefersLargeTitles = false

        setupUI()
        fillData()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
    }

    func setupUI() {
        titleTextField.frame = CGRect(x: 20, y: 120, width: view.bounds.width - 40, height: 40)
        titleTextField.borderStyle = .roundedRect
        titleTextField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleTextField.isEnabled = false
        view.addSubview(titleTextField)

        descriptionTextView.frame = CGRect(x: 20, y: 180, width: view.bounds.width - 40, height: 200)
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.isEditable = false
        view.addSubview(descriptionTextView)
    }

    func fillData() {
        titleTextField.text = taskTitle
        descriptionTextView.text = taskDescription
    }

    @objc func editButtonTapped() {
        if isEditingTask {
            // Сақтау режимінде, жаңарту жүргізу
            guard
                let id = taskID,
                let updatedTitle = titleTextField.text, !updatedTitle.isEmpty,
                let updatedDescription = descriptionTextView.text
            else {
                showAlert(title: "Қате", message: "Атауды бос қалдырмаңыз.")
                return
            }
            updateTaskInFirestore(id: id, title: updatedTitle, description: updatedDescription)
        } else {
            // Өңдеу режимін қосу
            setEditingMode(true)
        }
    }

    func setEditingMode(_ editing: Bool) {
        isEditingTask = editing
        titleTextField.isEnabled = editing
        descriptionTextView.isEditable = editing
        navigationItem.rightBarButtonItem?.title = editing ? "Сақтау" : "Өңдеу"
    }

    func updateTaskInFirestore(id: String, title: String, description: String) {
        let db = Firestore.firestore()
        db.collection("tasks").document(id).updateData([
            "title": title,
            "description": description
        ]) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Қате", message: "Жаңарту сәтсіз: \(error.localizedDescription)")
            } else {
                self?.taskTitle = title
                self?.taskDescription = description
                self?.setEditingMode(false)
                self?.showAlert(title: "Сәтті", message: "Тапсырма жаңартылды") {
                    self?.delegate?.taskDetailViewControllerDidUpdateTask(self!)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Жарайды", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
