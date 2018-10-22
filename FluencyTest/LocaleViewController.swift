import UIKit

class LocaleViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var localePicker: UIPickerView!
    var localePickerData: [String] = [String]()
    var selectedLocale: String = "en-US"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.localePicker.delegate = self
        self.localePicker.dataSource = self
        
        localePickerData = ["United States", "United Kingdom", "Canada", "Australia", "New Zealand", "India", "Indonesia", "South Africa", "Singapore", "Ireland", "Philippines"]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return localePickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return localePickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(localePickerData[row])
        
        switch localePickerData[row] {
            case "United States":
                self.selectedLocale = "en-US"
            break
            case "United Kingdom":
                self.selectedLocale = "en-GB"
            break
            case "Canada":
                self.selectedLocale = "en-CA"
            break
            case "Australia":
                self.selectedLocale = "en-AU"
            break
            case "New Zealand":
                self.selectedLocale = "en-NZ"
            break
            case "India":
                self.selectedLocale = "en-IN"
            break
            case "Indonesia":
                self.selectedLocale = "en-ID"
            break
            case "South Africa":
                self.selectedLocale = "en-ZA"
            break
            case "Singapore":
                self.selectedLocale = "en-SG"
            break
            case "Ireland":
                self.selectedLocale = "en-IE"
            break
            case "Philippines":
                self.selectedLocale = "en-PH"
            break
            default:
                self.selectedLocale = "en-US"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ViewController {
            viewController.locale = self.selectedLocale
        }
    }

}
