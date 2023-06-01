//
//  ViewController.swift
//  ChatGPTStreamAPI
//
//  Created by iMac on 01/06/23.
//

import UIKit
import ChatGPTSwift

class ViewController: UIViewController, UITextViewDelegate {
        
    // MARK: - Chat GPT Helper Data
    enum FindType {
        case Text, Code
    }
    
    var isFind: FindType = .Text
    
    private var arrOfQuestionAnswer = [ChatGPT]()
    private var arrOfQuestionAnswerToDisplay: [ChatGPT] {
        return arrOfQuestionAnswer.reversed()
    }

    private struct ChatGPT {
        var questionAnswer: String
        let isSend: Bool
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var lblLoader: UILabel!
    @IBOutlet weak var tblAns: UITableView!

    @IBOutlet weak var cnstBottom: NSLayoutConstraint!
    @IBOutlet weak var lblAskme: UILabel!
    @IBOutlet weak var cnstQuestion: NSLayoutConstraint!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var txtQuestion: UITextView!
    @IBOutlet weak var lblPlaceHolder: UILabel!
    
    
    // MARK: - Viewcontroller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    //MARK: setupLayout
    func setupLayout() {
        self.lblLoader.isHidden = true
        self.txtQuestion.layer.cornerRadius  = 8
        self.btnSubmit.layer.cornerRadius  = 8
        self.tblAns.delegate = self
        self.tblAns.dataSource = self
        
        self.txtQuestion.delegate = self
        
        self.lblPlaceHolder.isHidden = false

        txtQuestion.addPadding(toTop: 10, toLeft: 6, toBottom: 10, toRight: 6)

        tblAns.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        observeKeyboardEvents()
    }
    
    //MARK: startBlink
    func startBlink() {
        self.lblLoader.isHidden = false
        UIView.animate(withDuration: 0.8,
              delay:0.0,
              options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.lblLoader.alpha = 0 },
              completion: nil)
    }
    
    //MARK: stopBlink
    func stopBlink() {
        self.lblLoader.isHidden = true
    }
    
    //MARK: Search
    func search(){
        submitText()
    }
    
    //MARK: submitText
    func submitText() {
        self.view.endEditing(true)
        self.lblAskme.isHidden = true
        if txtQuestion.text != "" {
            let strQuestion : String = self.txtQuestion.text?.trime() ?? ""

            self.startBlink()
            self.sendMessage(question: strQuestion, isSend: true)
            self.lblPlaceHolder.isHidden = false
            self.lblAskme.isHidden = true
            self.txtQuestion.text = ""

            getAnswer(strChat: strQuestion)
        } else {
            appDelegate.showAlert(strMessage: "Please enter something!", vc: self)
        }
    }

    func sendMessage(question: String, isSend: Bool) {
//    func sendMsg(){
        self.arrOfQuestionAnswer.append(ChatGPT(questionAnswer: question, isSend: isSend))
        //self.arrOfQuestionAnswerToDisplay = self.arrOfQuestionAnswer.reversed()
        reloadTbl()
    }

    func getAnswer(strChat : String){
        Task {
            do {
                let api = ChatGPTAPI(apiKey: OpenAISecretKey.SECRETKEY)
                
                let stream = try await api.sendMessageStream(text: strChat)
                
                for try await line in stream {
                    print(line)
                    stopBlink()
                    if var lastObject = arrOfQuestionAnswer.last {
                        // Last object is question
                        if lastObject.isSend {
                            let answerObject = ChatGPT(questionAnswer: line,isSend: false)
                            arrOfQuestionAnswer.append(answerObject)
                        } else {
                        // Last object is answer
                            lastObject.questionAnswer.append(line)
                            arrOfQuestionAnswer[arrOfQuestionAnswer.count - 1] = lastObject
                        }
                        reloadTbl()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func btnClearClick(_ sender: Any) {
        self.arrOfQuestionAnswer.removeAll()
//        self.arrOfQuestionAnswerToDisplay.removeAll()
        
        reloadTbl()
        self.lblAskme.isHidden = false
    }
    @IBAction func btnSubmitClick(_ sender: Any) {
        search()
    }
        
    //MARK: TextView Delegate Methods
    func textViewDidChange(_ textView: UITextView) {
        print("text changing...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.txtQuestion.contentSize.height < 40 {
                self.cnstQuestion.constant = 40
            } else if self.txtQuestion.contentSize.height > 70 {
                self.cnstQuestion.constant = 70
            } else {
                self.cnstQuestion.constant = self.txtQuestion.contentSize.height
            }
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.lblAskme.isHidden = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if txtQuestion.text.isEmpty {
            self.lblPlaceHolder.isHidden = false
        }
        
        if arrOfQuestionAnswerToDisplay.count == 0 {
            self.lblAskme.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.cnstQuestion.constant = 40
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.lblPlaceHolder.isHidden = true
        if !txtQuestion.text!.isEmpty {
            txtQuestion.text = ""
        }
    }
    
    //MARK: reload Table
    func reloadTbl(){
        self.tblAns.isHidden = false
        self.tblAns.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.arrOfQuestionAnswerToDisplay.count > 0 {
                
                let indexPath = IndexPath(row: 0, section: 0)
                self.tblAns.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }

    //MARK: KeyboardEvents Observer
    func observeKeyboardEvents() {
       NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) in
           guard let keyboardHeight = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
           print("Keyboard height in KeyboardWillShow method: \(keyboardHeight.height)")
           self?.cnstBottom.constant = keyboardHeight.height - 10.0
           }

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) in
            self?.cnstBottom.constant = 20.0
        }
   }
}

//MARK: tableview delegate and datasource
extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOfQuestionAnswerToDisplay.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.arrOfQuestionAnswerToDisplay[indexPath.row].isSend == true {
            let cell = tblAns.dequeueReusableCell(withIdentifier: "HumanCell") as! HumanCell
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            let question = arrOfQuestionAnswerToDisplay[indexPath.row].questionAnswer
            
            cell.lblQuestion.text = question
            return cell
        }else{
            
            let cell = tblAns.dequeueReusableCell(withIdentifier: "BotCell") as! BotCell
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            let answer = arrOfQuestionAnswerToDisplay[indexPath.row].questionAnswer
            cell.lblAnswer.text = answer
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: HumanCell
class HumanCell: UITableViewCell {
    @IBOutlet weak var lblQuestion: UILabel!
    override func awakeFromNib() {
        
    }
}
//MARK: BotCell
class BotCell: UITableViewCell {
    @IBOutlet weak var lblAnswer: UILabel!
    override func awakeFromNib() {
        
    }
}
extension UITextView {
    func addPadding(toTop : CGFloat, toLeft : CGFloat, toBottom : CGFloat, toRight : CGFloat) {
        self.textContainerInset = UIEdgeInsets(top: toTop, left: toLeft, bottom: toBottom, right: toRight)
    }
}
