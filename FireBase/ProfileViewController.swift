import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    private let photoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let signOutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Профиль"

        setupUI()
        loadUserInfo()
    }

    func setupUI() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 60
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.borderColor = UIColor.systemGray4.cgColor
        photoImageView.backgroundColor = UIColor.systemGray5
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        nameLabel.textAlignment = .center

        emailLabel.font = UIFont.systemFont(ofSize: 18)
        emailLabel.textAlignment = .center
        emailLabel.textColor = .secondaryLabel

        signOutButton.setTitle("Шығу", for: .normal)
        signOutButton.setTitleColor(.systemRed, for: .normal)
        signOutButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)

        view.addSubview(photoImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(signOutButton)

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoImageView.heightAnchor.constraint(equalToConstant: 120),
            photoImageView.widthAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            signOutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 50),
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.heightAnchor.constraint(equalToConstant: 44),
            signOutButton.widthAnchor.constraint(equalToConstant: 200),
        ])
    }

    func loadUserInfo() {
        if let user = Auth.auth().currentUser {
            nameLabel.text = user.displayName ?? "Пайдаланушы аты жоқ"
            emailLabel.text = user.email ?? "Email жоқ"

            if let photoURL = user.photoURL {
                // URL-ден суретті жүктеу
                downloadImage(from: photoURL)
            } else {
                // Әдепкі сурет
                photoImageView.image = UIImage(systemName: "person.circle")
            }
        } else {
            nameLabel.text = "Пайдаланушы табылмады"
            emailLabel.text = ""
            photoImageView.image = UIImage(systemName: "person.circle")
        }
    }

    func downloadImage(from url: URL) {
        // URLSession-мен суретті фондық ағында жүктейміз
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.photoImageView.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self?.photoImageView.image = UIImage(systemName: "person.circle")
                }
                print("Суретті жүктеу қатесі: \(error?.localizedDescription ?? "белгісіз қате")")
            }
        }
        task.resume()
    }

    @objc func signOutTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true)
        } catch {
            print("Шығу қатесі: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Қате", message: "Шығу мүмкін болмады", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Жабу", style: .cancel))
            present(alert, animated: true)
        }
    }
}
