import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var textToReadTextView: UITextView!
    @IBOutlet weak var transcribedTextView: UITextView!
    @IBOutlet weak var startTalkingButton: UIButton!
    
    var textToRead: String = ""
    var transcribedText: String = ""
    var textToReadParameterized: String = ""
    var transcribedTextParameterized: String = ""
    
    var biggestString: Double = 0.0
    
    var texts: [String]!
    
    var levenshtein: Double = 0.0
    var damerauLevenshtein: Double = 0.0
    var jaroWinkler: Double = 0.0
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    var request: SFSpeechAudioBufferRecognitionRequest?
    var task: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        texts = [
            "Small talk is light conversation. It can be about the weather, food, anything that isn’t too serious. If you’re in the same room as someone, in an elevator together or just standing near each other and you aren’t working, making small talk can open the conversation and form friendships and connections. It also saves you from uncomfortable silences!",
            "A paper published in the British Medical Journal in 2015 found that alcohol consumption was more likely to rise to risky levels among adults who work more than 48 hours a week compared with those who work average hours. That paper involved reviewing and analyzing 63 previously published studies on the association between long working hours and alcohol use.",
            "The best way to overcome a natural tendency to procrastinate is to create a hard deadline for yourself and then put it on the calendar. Having a scheduled deadline that you commit to will make it easier to get tasks completed. Treat the deadline the same as if your boss created it, and then honor it the same way you would if your boss were waiting for you to complete the task.",
            "Just 80 miles east of Silicon Valley, one of the wealthiest regions in the country, is Stockton, California — once known as America's foreclosure capital. Soon, the former bankrupt city will become the first in the country to participate in a test of Universal Basic Income, also known as UBI. Stockton will give 100 residents $500 a month for 18 months, no strings attached.",
            "Fall is here, and hotels are gearing up for the holidays. Business is about to pick up again after a shoulder season in which families stayed put for the start of the school year. But Thanksgiving and Christmas are just around the corner, and hotels are unveiling their latest renovations to attract the holiday crowds."
        ]
        
        textToRead = texts[Int.random(in: 0..<texts.count)]
        
        transcribedText = "Waiting..."
        
        textToReadTextView.text = textToRead
        transcribedTextView.text = transcribedText
    
        SFSpeechRecognizer.requestAuthorization { (status) in
            OperationQueue.main.addOperation {
                switch status {
                    
                case .authorized: self.startTalkingButton.isEnabled = true
                self.promptLabel.text = "Tap \"Start Talking\" to dictate..."
                    
                default: self.startTalkingButton.isEnabled = false
                self.promptLabel.text = "Dictation not authorized..."
                    
                }
            }
        }
        
        startTalkingButton.isEnabled = false
        speechRecognizer.delegate = self
    }
    
    @IBAction func startTalkingButtonClicked(_ sender: Any) {
        
        if audioEngine.isRunning {
            startTalkingButton.setTitle("Start Recording", for: .normal)
            promptLabel.text = "Tap the button to dictate..."
            
            request?.endAudio()
            audioEngine.stop()
        } else {
            startTalkingButton.setTitle("Stop Recording", for: .normal)
            promptLabel.text = "Go ahead. I'm listening..."
            
            startDictation()
        }
    }
    
    
    func startDictation() {
        
        task?.cancel()
        task = nil
        
        // Initializes the request variable
        request = SFSpeechAudioBufferRecognitionRequest()
        
        // Assigns the shared audio session instance to a constant
        let audioSession = AVAudioSession.sharedInstance()
        
        // Assigns the input node of the audio engine to a constant
        let inputNode = audioEngine.inputNode
        
        // If possible, the request variable is unwrapped and assigned to a local constant
        guard let request = request else { return }
        request.shouldReportPartialResults = true
        
        // Attempts to set various attributes and returns nil if fails
        try? audioSession.setCategory(AVAudioSessionCategoryRecord)
        try? audioSession.setMode(AVAudioSessionModeMeasurement)
        try? audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        // Initializes the task with a recognition task
        task = speechRecognizer.recognitionTask(with: request, resultHandler: { (result, error) in
            guard let result = result else { return }
            self.transcribedText = result.bestTranscription.formattedString
            self.transcribedTextView.text = self.transcribedText
            
            if error != nil || result.isFinal {
                self.audioEngine.stop()
                self.request = nil
                self.task = nil
                
                inputNode.removeTap(onBus: 0)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            startTalkingButton.isEnabled = true
        } else {
            startTalkingButton.isEnabled = false
        }
    }
    
    func calculateBiggestString(s1: String, s2:String) -> Double {
        if s1.count >= s2.count {
            return Double(s1.count)
        }
        return Double(s2.count)
    }
    
    @IBAction func checkButtonClicked(_ sender: Any) {
        
        removePontuaction()
        returnTheBiggestString()

        // distances
        let levenshteinDistance: Double = Double(textToReadParameterized.levDis(between: transcribedTextParameterized))
        let damerauLevenshteinDistance: Double = Double(textToReadParameterized.distanceDamerauLevenshtein(between: transcribedTextParameterized))
        let jaroWinklerDistance: Double = textToReadParameterized.distanceJaroWinkler(between: transcribedTextParameterized)
        
        levenshtein = (1 - (levenshteinDistance/biggestString)) * 100
        damerauLevenshtein = (1 - damerauLevenshteinDistance/biggestString) * 100
        jaroWinkler = textToReadParameterized.distanceJaroWinkler(between: transcribedTextParameterized) * 100
    }
    
    func removePontuaction() {
        textToReadParameterized = textToRead.lowercased()
            .replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "...", with: "").replacingOccurrences(of: "!", with: "").replacingOccurrences(of: "?", with: "").replacingOccurrences(of: ";", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "—", with: "")
        transcribedTextParameterized = transcribedText.lowercased()
            .replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "'", with: "").replacingOccurrences(of: "...", with: "").replacingOccurrences(of: "!", with: "").replacingOccurrences(of: "?", with: "").replacingOccurrences(of: ";", with: "").replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "—", with: "")
    }
    
    func returnTheBiggestString() {
        biggestString = calculateBiggestString(s1: textToReadParameterized, s2: transcribedTextParameterized)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resultViewController = segue.destination as? ResultViewController {
            resultViewController.levenshtein = levenshtein
            resultViewController.damerauLevenshtein = damerauLevenshtein
            resultViewController.jaroWinkler = jaroWinkler
        }
    }
    
    @IBAction func refreshText(_ sender: UIBarButtonItem) {
        textToRead = texts[Int.random(in: 0..<texts.count)]
        textToReadTextView.text = textToRead
    }
    
    
}
