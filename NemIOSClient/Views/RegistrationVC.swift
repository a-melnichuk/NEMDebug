import UIKit
class RegistrationVC: AbstractViewController
{
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var createPassword: UITextField!
    @IBOutlet weak var repeatPassword: UITextField!
    
    let dataManager : CoreDataManager = CoreDataManager()
    var showKeyboard :Bool = true
    
    var currentField :UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        userName.layer.cornerRadius = 2
        createPassword.layer.cornerRadius = 2
        repeatPassword.layer.cornerRadius = 2
        
        if State.fromVC != SegueToRegistrationVC
        {
            State.fromVC = SegueToRegistrationVC
        }
        
        State.currentVC = SegueToRegistrationVC

        NSNotificationCenter.defaultCenter().postNotificationName("Title", object: "New Account" )

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

    @IBAction func chouseTextField(sender: UITextField)
    {
        currentField = sender
    }


    @IBAction func closeKeyboard(sender: UITextField)
    {
        if userName.text == ""
        {
            userName.becomeFirstResponder()
        }else if createPassword.text == ""
        {
            createPassword.becomeFirstResponder()
        }else if repeatPassword.text == ""
        {
            repeatPassword.becomeFirstResponder()
        }
    }
    
    
    @IBAction func confirmPassword(sender: AnyObject)
    {

    }
    
    @IBAction func nextBtnPressed(sender: AnyObject)
    {        
        var alert :UIAlertView!
        
        if createPassword.text != "" && repeatPassword.text != "" && userName.text != ""
        {
            if Validate.password(createPassword.text)
            {
                if(createPassword.text == repeatPassword.text)
                {
                    WalletGenerator().createWallet(userName.text, password: createPassword.text)
                    
                    State.fromVC = SegueToRegistrationVC
                    State.toVC = SegueToLoginVC
                    
                    NSNotificationCenter.defaultCenter().postNotificationName("MenuPage", object: SegueToLoginVC )
                }
                else
                {
                    alert  = UIAlertView(title: "Validation", message: "Different passwords", delegate: self, cancelButtonTitle: "OK")

                    repeatPassword.text = ""
                    createPassword.text = ""
                }
            }
            else
            {
                alert  = UIAlertView(title: "Validation", message: "Your password must be at least 6 characters.", delegate: self, cancelButtonTitle: "OK")
                
                repeatPassword.text = ""
            }
        }
        else
        {
            alert  = UIAlertView(title: "Validation", message: "Input all fields", delegate: self, cancelButtonTitle: "OK")
        }
        
        
        if(alert != nil)
        {
            alert.show()
        }
        
    }
}
