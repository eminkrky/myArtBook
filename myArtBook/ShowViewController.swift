//
//  ShowViewController.swift
//  myArtBook
//
//  Created by Emin on 3.09.2024.
//

import UIKit
import CoreData

class ShowViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var buttonView: UIButton!
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedId != nil {
            nameField.isEnabled = false
            authorField.isEnabled = false
            yearField.isEnabled = false
            buttonView.isHidden = true
            self.navigationItem.title = "Art"
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Database")
            let idString = selectedId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameField.text = name
                        }
                        if let author = result.value(forKey: "author") as? String {
                            authorField.text = author
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearField.text = String(year)
                        }
                        if let image = result.value(forKey: "image") as? Data {
                            imageView.image = UIImage(data: image)
                        }
                            
                    }
                }
            } catch {
                
            }
        } else {
            self.navigationItem.title = "Add Art"
            buttonView.isEnabled = false
            let selfGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            view.addGestureRecognizer(selfGesture)
            
            imageView.isUserInteractionEnabled = true
            let myGesture = UITapGestureRecognizer(target: self, action: #selector(getImage))
            imageView.addGestureRecognizer(myGesture)
        }

    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func getImage(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        buttonView.isEnabled = true
        self.dismiss(animated: true)
         }

    @IBAction func saveButton(_ sender: Any) {
        let name = nameField.text!
        let image = imageView.image?.jpegData(compressionQuality: 0.5)
        let author = authorField.text!
        let year = yearField.text!
        let id = UUID()
        
        let appDeletage = UIApplication.shared.delegate as! AppDelegate
        let context = appDeletage.persistentContainer.viewContext
        
        let newDatabase = NSEntityDescription.insertNewObject(forEntityName: "Database", into: context)
        
        newDatabase.setValue(name, forKey: "name")
        newDatabase.setValue(image, forKey: "image")
        newDatabase.setValue(author, forKey: "author")
        if let intYear = Int(year){
            newDatabase.setValue(intYear, forKey: "year")
        }
        newDatabase.setValue(id, forKey: "id")
        
        do {
            try context.save()
        } catch {
            print("Error")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

}
