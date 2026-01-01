import UIKit

protocol NGOAboutMeDelegate: AnyObject {
    func didUpdateNGOInfo(name: String, email: String, phone: String, mission: String)
}


class NGOAboutMeViewController: UIViewController {

    @IBOutlet weak var nameTextBox: UITextField!
    
    @IBOutlet var emailTextBox: UITextField!
    
    @IBOutlet weak var phoneTextBox: UITextField!
    
    @IBOutlet weak var missionTextBox: UITextView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: NGOAboutMeDelegate?
    var ngo: NGO? // whole model

    private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the ngo model instead of currentName/currentEmail 
       if let ngo = ngo {
            nameTextBox.text = ngo.name
            emailTextBox.text = ngo.email
            phoneTextBox.text = ngo.phone
            missionTextBox.text = ngo.mission }
        
        // Initial state: fields locked, save button hidden
        setEditingMode(false)

    
    }

    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        setEditingMode(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        setEditingMode(false)
        
        // Pass updated info back to profile screen
        delegate?.didUpdateNGOInfo(
            name: nameTextBox.text ?? "",
            email: emailTextBox.text ?? "",
            phone: phoneTextBox.text ?? "",
            mission: missionTextBox.text ?? "")
    }
    
    private func setEditingMode(_ enabled: Bool) {
        isEditingMode = enabled
        
        // Toggle text fields
        nameTextBox.isUserInteractionEnabled = enabled
        emailTextBox.isUserInteractionEnabled = enabled
        phoneTextBox.isUserInteractionEnabled = enabled
        
        // Mission text view
        missionTextBox.isEditable = enabled
        missionTextBox.isSelectable = enabled // allow text selection only when editing
        missionTextBox.isScrollEnabled = true // always allow scrolling
   
        
        // Toggle buttons
        editButton.isEnabled = !enabled
        saveButton.isHidden = !enabled //  hide/show instead of tint trick
        saveButton.layer.cornerRadius = 8
    }
    
    
}
