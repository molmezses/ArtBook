//
//  ViewController.swift
//  ArtBook
//
//  Created by mustafa ölmezses on 10.05.2023.
//

import UIKit
import CoreData


class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var artistArray = [String]()
    
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action:#selector(addButtonClicked) )
        
        
     getData()
    }
    
    
    //View vil lapper donksiyonu viewdidloadın aksine bir kez değil sayfa her açıldıgında çağırılır
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
     @objc func getData(){
         
         
         //sayfa her yüklendiğinde var olan önceki verileir silip güncel olarak tekrar yükler (veri tbaanı kendini telrar etmez)
         nameArray.removeAll(keepingCapacity: false)
         idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject]{
                
                if let name = result.value(forKey: "name") as? String {
                    nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID{
                    idArray.append(id)
                }
                
                if let artist = result.value(forKey: "artist") as? String{
                    artistArray.append(artist)
                }
                
                self.tableView.reloadData() // kendini güncelle kaarşim
                
            }

        }catch{
            print("Error : viewContoller : 41.line")
        }
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell()
            var content = cell.defaultContentConfiguration()
            content.text = nameArray[indexPath.row]
        content.secondaryText = artistArray[indexPath.row]
            cell.contentConfiguration = content
            return cell
    }
    
    
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }

    
    
    //segue edilerken verileri gödnerme
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenPainting = selectedPainting
            destinationVC.chosenPaintingId = selectedPaintingId
            
        }
    }
    
    //bir hüvreye tıklandıgında
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        
        let idString = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@ ", idString)
        
        do{
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject]{
                    
                    if result.value(forKey: "id") is UUID{
                        
                        context.delete(result)
                        nameArray.remove(at: indexPath.row)
                        idArray.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        
                        do{
                            try context.save()
                        }catch{
                            print("Error : context.save()")
                        }
                        
                    }
                    break
                }
                
            }
            
            
        }catch{
            print("Error : commit ")
        }

        
    }

}

