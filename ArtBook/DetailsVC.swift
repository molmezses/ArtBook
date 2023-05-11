//
//  DetailsVC.swift
//  ArtBook
//
//  Created by mustafa ölmezses on 10.05.2023.
//

import UIKit
import CoreData


class DetailsVC: UIViewController, UIImagePickerControllerDelegate  , UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTextF: UITextField!
    
    @IBOutlet weak var artistTextF: UITextField!
    
    @IBOutlet weak var yearTextF: UITextField!
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //+ butonuna tıklaındaıgında veri gelmemişse yani yeni bir nesne eklenecek ise +coreData işlemleri
        if chosenPainting != ""{
            
            saveButtonOutlet.isEnabled = false
            nameTextF.isEnabled = false
            artistTextF.isEnabled = false
            yearTextF.isEnabled = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            //Id yi data çevirme işlemleri
            
            let idString = chosenPaintingId?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)

            do{
                let results =  try context.fetch(fetchRequest)
                print("hadi")
                
                for result in results as! [NSManagedObject] {
                    
                    if let name = result.value(forKey: "name") as? String{
                        nameTextF.text = name
                    }
                        
                    if let artist = result.value(forKey: "artist") as? String{
                        artistTextF.text = artist
                    }
                    
                    if let year = result.value(forKey: "year") as? Int{
                        yearTextF.text = String(year)
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data{
                        let image = UIImage(data: imageData)
                        imageView.image = image
                    }
                        
                }
                
            }catch{
                print("Error : DetailsVC : 46")
            }
            
        }
        
        imageView.isUserInteractionEnabled  = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if chosenPainting != ""{
            imageView.isUserInteractionEnabled = false
        }
    }
    
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType  = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    
    //Görsel seçildikten sonra ne yapıalcağı
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true) //Foto çelince galeriyi kapat
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        //veri tabanı erşim
        
        let  appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(UUID(), forKey: "id")
        newPainting.setValue(nameTextF.text, forKey: "name")
        newPainting.setValue(artistTextF.text, forKey: "artist")
        
        if let year = Int(yearTextF.text!) {
            newPainting.setValue(year, forKey: "year")

        }
        
        let data  = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
            
        do{
            try context.save()
            print("success")
        }catch{
            print("Error : newPainting")
        }
        
        //newData adlı bildirim oluştur ve önceki viewControlllea geri dön 
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    

}
