//
//  commentViewController.swift
//  instagramapp2
//
//  Created by matsushitamasaki on 2021/10/06.
//

import UIKit
import Firebase
import FirebaseStorageUI

class commentViewController: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var articleImage: UIImageView!
    
    @IBOutlet weak var articleButton: UIButton!
    
    @IBOutlet weak var articleLilkeCount: UILabel!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var articleLabel: UILabel!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
     }
    //前画面からデータを受け取るための変数
        var postDataReceived: PostData?

        func setPostData(_ postData: PostData) {
            postDataReceived = postData
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            guard let postData = postDataReceived else {
                return
            }
            // 画像の表示
                   articleImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                   let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
                   articleImage.sd_setImage(with: imageRef)
            //キャプションのテキスト
            self.articleLabel.text = "\(postData.caption!)"
            //いいねの数
            let likeNumber = postData.likes.count
            articleLilkeCount.text = "\(likeNumber)"

            //いいねボタン
            if postData.isLiked {
                let buttonImage = UIImage(named: "like_exist")
                self.articleButton.setImage(buttonImage, for: .normal)
            } else {
                let buttonImage = UIImage(named: "like_none")
                self.articleButton.setImage(buttonImage, for: .normal)
            }
            var allcomment = ""
            
            //postData.commentsの中から要素をひとつずつ取り出すのを繰り返す、というのがcomment
            for comment in postData.Comment{
            allcomment += comment
            self.commentTextView.text = ("\(allcomment)\n")
            }
     }
    
    @IBAction func commentButton(_ sender: Any) {
        // 前画面から受け取ったデータを取り出す
              guard let postData = postDataReceived else {
                  return
              }
        let name:String! = Auth.auth().currentUser?.displayName
        //cell.textField.textがnilじゃなかったら、commentTextとする
        if let commentText = self.commentTextField.text  {
                   //であれば、postData.commentsにcommentTextをappend(追加)する
            postData.Comment.append("\(name!):\(commentText)\n")
               }
        
        // 増えたcommentsをFirebaseに保存する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        
       let postdic = [
        "Comment": "\(name!):\(self.commentTextField.text!)"]
    
        postRef.setData(postdic)
    
        var allcomment = ""
        //postData.commentsの中から要素をひとつずつ取り出すのを繰り返す、というのがcomment
               for comment in postData.Comment{
                allcomment += comment
                self.commentTextView.text = ("\(allcomment)\n")
               }
    
        commentTextField.text = ""
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
        override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            self.commentTextField.delegate = self
            commentTextField.returnKeyType = .done
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
           if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                   self.view.frame.origin.y -= keyboardSize.height
               }else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
          }
       }
       
       @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
           }
       }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
       }
    
   
   
   func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
       return false
   }
}

/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


