import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let registerButton = UIButton(type: .system)
    let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
    }
    
   
    func setupUI() {
        
        titleLabel.text = "Create Account"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.backgroundColor = UIColor.secondarySystemBackground
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.shadowColor = UIColor.black.cgColor
        emailTextField.layer.shadowOpacity = 0.1
        emailTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = UIColor.secondarySystemBackground
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.shadowColor = UIColor.black.cgColor
        passwordTextField.layer.shadowOpacity = 0.1
        passwordTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
      
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = UIColor.systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        registerButton.layer.cornerRadius = 10
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOpacity = 0.2
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
       
        let stackView = UIStackView(arrangedSubviews: [titleLabel, emailTextField, passwordTextField, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
  
    @objc func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Ошибка регистрации: \(error.localizedDescription)")
                return
            }
            print("Успешная регистрация: \(result?.user.email ?? "")")
         
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}
