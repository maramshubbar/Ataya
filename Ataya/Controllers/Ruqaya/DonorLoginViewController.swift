//
//  DonorLoginViewController.swift
//  AtayaTest
//
//  Created by Ruqaya Habib on 17/12/2025.
//

import UIKit

class DonorLoginViewController: UIViewController {

    
    
    
    
    @IBOutlet weak var rememberCheckButton: UIButton!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var forgetPasswordLabel: UILabel!
    
    @IBOutlet weak var signUpLabel: UILabel!

    private let atayaYellow = UIColor(red: 0xF7/255, green: 0xD4/255, blue: 0x4C/255, alpha: 1)
    private let baseGray   = UIColor(red: 0x5A/255, green: 0x5A/255, blue: 0x5A/255, alpha: 1)
    private let eyeGray  = UIColor(red: 0xB8/255.0, green: 0xB8/255.0, blue: 0xB8/255.0, alpha: 1.0)


    private var isPasswordVisible = false
    
    private var isRememberChecked = false




    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupForgetPasswordTap()
        setupPasswordEye()
        setupSignUpLabel()
        setuploginButton()

        setupRememberCheckbox()
        updateRememberUI()
        
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
        emailTextField.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsChanged), for: .editingChanged)


        signUpLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSignUp))
        signUpLabel.addGestureRecognizer(tap)


    }
    
    private func setupForgetPasswordTap() {
        forgetPasswordLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(forgetPasswordTapped))
        forgetPasswordLabel.addGestureRecognizer(tap)
    }

    @objc private func forgetPasswordTapped() {
        performSegue(withIdentifier: "donorForgotSegue", sender: self)
    }


    @objc private func openSignUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "DonorSignUpViewController"
        )
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc private func textFieldsChanged() {
        let emailFilled = !(emailTextField.text ?? "").isEmpty
        let passwordFilled = !(passwordTextField.text ?? "").isEmpty

        let shouldEnable = emailFilled && passwordFilled

        loginButton.isEnabled = shouldEnable
        loginButton.alpha = shouldEnable ? 1.0 : 0.5
    }

    
    private func setupRememberCheckbox() {
        rememberCheckButton.layer.cornerRadius = 4
        rememberCheckButton.layer.borderWidth = 1
        rememberCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
        rememberCheckButton.backgroundColor = .white
        rememberCheckButton.setImage(nil, for: .normal)
        rememberCheckButton.tintColor = .white

        rememberCheckButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        rememberCheckButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }

    private func updateRememberUI() {
        if isRememberChecked {
            rememberCheckButton.backgroundColor = UIColor(red: 0x4C/255.0, green: 0xAF/255.0, blue: 0x50/255.0, alpha: 1.0)
            rememberCheckButton.setImage(
                UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)),
                for: .normal
            )
            rememberCheckButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            rememberCheckButton.backgroundColor = .white
            rememberCheckButton.setImage(nil, for: .normal)
            rememberCheckButton.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }




    
    
    private func setuploginButton() {
        loginButton.layer.cornerRadius = 8
        }

    private func setupPasswordEye() {
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        config.baseForegroundColor = eyeGray
        config.image = UIImage(systemName: "eye.slash")
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 14)

        let eyeButton = UIButton(configuration: config)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        eyeButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        container.addSubview(eyeButton)

        passwordTextField.rightView = container
        passwordTextField.rightViewMode = .always
    }

    @objc private func togglePassword() {
        isPasswordVisible.toggle()

        let text = passwordTextField.text
        passwordTextField.isSecureTextEntry = !isPasswordVisible
        passwordTextField.text = text

        let imageName = isPasswordVisible ? "eye" : "eye.slash"
        if let container = passwordTextField.rightView,
           let button = container.subviews.first as? UIButton {
            var config = button.configuration
            config?.image = UIImage(systemName: imageName)
            button.configuration = config
        }
    }
    
    
    private func setupSignUpLabel() {
        let text = "Don’t have an account? Sign Up"
        let attr = NSMutableAttributedString(string: text)

        attr.addAttribute(.foregroundColor, value: baseGray, range: NSRange(location: 0, length: text.count))

        let SignUpRange = (text as NSString).range(of: "Sign Up")
        if SignUpRange.location != NSNotFound {
            attr.addAttribute(.foregroundColor, value: atayaYellow, range: SignUpRange)
        }

        signUpLabel.attributedText = attr
        signUpLabel.numberOfLines = 1
    }
    
    
    
    @IBAction func rememberCheckTapped(_ sender: UIButton) {
        isRememberChecked.toggle()
        updateRememberUI()
    }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
