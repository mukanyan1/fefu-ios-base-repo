
import UIKit

class SignUpController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var loginField: SignFEFUTextField!
    @IBOutlet weak var passwordField: SecureFEFUTextField!
    @IBOutlet weak var passwordConfirmField: SecureFEFUTextField!
    @IBOutlet weak var nameField: SignFEFUTextField!
    @IBOutlet weak var genderPicker: SignFEFUTextField!
    @IBOutlet weak var continueButton: ActivityFEFUButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    static private let encoder = JSONEncoder()
    
    private let genders = ["Мужской", "Женский"]
    private var genderNum = 0
    
    private let genderPickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        
        genderPicker.inputView = genderPickerView
        
        commonInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @IBAction func didTapContinueButton(_ sender: Any) {
        let login = loginField.text ?? ""
        let password = passwordField.text ?? ""
        let passwordConfirm = passwordConfirmField.text ?? ""
        let name = nameField.text ?? ""
        let gender = genderNum
        
        if passwordConfirm != password {
            let alert = UIAlertController(title: "Ошибка", message: "Пароли не совпадают", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ясно", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let body = UserRegBody(login: login, password: password, name: name, gender: gender)
        
        do {
            let reqBody = try AuthService.encoder.encode(body)
            let queue = DispatchQueue.global(qos: .utility)
            AuthService.register(reqBody) { user in
                queue.async {
                    UserDefaults.standard.set(user.token, forKey: "token")
                }
                DispatchQueue.main.async {
                    let vc = TabsViewController(nibName: "TabsViewController", bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            } onError: { err in
                DispatchQueue.main.async {
                    self.checkApiErrors(errors: err.errors)
                }
            }
        } catch {
            print(error)
        }
    }
    

    private func commonInit() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        genderPicker.tintColor = .clear
        
        continueButton.setTitle("Продолжить", for: .normal)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Регистрация"
        navigationItem.prompt = ""
        
        createNotifications()
    }
    
    private func checkApiErrors(errors: Dictionary<String, [String]>){
        var alertText = ""
        for (_, values) in errors.reversed() {
            for e in values {
                alertText += e + "\n"
            }
        }
        
        let alert = UIAlertController(title: "Проверьте поля", message: alertText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить попытку", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func createNotifications() {
        let notification = NotificationCenter.default
        
        notification.addObserver(self, selector: #selector(willShowKeyboard(_: )), name:UIWindow.keyboardWillShowNotification, object: nil)
        
        notification.addObserver(self, selector: #selector(willHideKeyboard(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func willShowKeyboard(_ sender: Notification) {
        let rawFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        guard let height = rawFrame?.cgRectValue.height else {
            return
        }
        
        scrollView.contentInset.bottom = height
    }
    
    @objc func willHideKeyboard(_ sender: Notification) {
        scrollView.contentInset.bottom = 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderPicker.text = genders[row]
        genderNum = row
        genderPicker.resignFirstResponder()
    }
}
