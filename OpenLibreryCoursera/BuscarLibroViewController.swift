//
//  BuscarLibroViewController.swift
//  OpenLibreryCoursera
//
//  Created by Jose Lopez on 8/1/18.
//  Copyright © 2018 Jose Lopez. All rights reserved.
//

import UIKit
import CoreData
class BuscarLibroViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var tituloLabel: UILabel!
    @IBOutlet weak var autoresLabel: UILabel!
    @IBOutlet weak var portadaImageView: UIImageView!
    @IBOutlet weak var guardarButton: UIButton!
    
    var sinPortada = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        isbnTextField.delegate = self
        guardarButton.isEnabled = false
        
    }
    
    func conexion() -> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    
    func validarISBN(value: String) -> Bool{
        if(espaciosVacios(stringValue: value))
        {
            mostrarAlertas(title: "Aviso", message: "No se ha proporcionado un ISBN a buscar.")
            return false
        }
        if(!Reachability.isConnectedToNetwork())
        {
            mostrarAlertas(title: "Aviso", message: "No cuenta con acceso a la red, favor de reintentar posteriormente.")
            return false
        }
        return true
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(validarISBN(value: isbnTextField.text!))
        {
            busquedaISBN(isbn: isbnTextField.text!)
        }
        return true
    }
    

    func busquedaISBN(isbn: String)
    {
        let url:String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:" + isbn
        let urlToSearch = NSURL(string: url)
        let contentData:NSData? = NSData(contentsOf: urlToSearch! as URL)
        if(contentData == nil)
        {
            mostrarAlertas(title: "Aviso", message: "No se ha podido conectar al servicio. Favor de reintentar más tarde")
            return
        }
        do{
            let jsonResponse = try JSONSerialization.jsonObject(with: contentData! as Data, options: []) as! NSDictionary
            if(jsonResponse.count == 0 )
            {
                mostrarAlertas(title: "Aviso", message: "No se ha encontrado un libro con el ISBN proporcionado.")
                guardarButton.isEnabled = false
                return
            }
            let bookInfo = jsonResponse["ISBN:" + isbn] as! NSDictionary
            tituloLabel.text = bookInfo["title"] as? String
            
            let authors = (bookInfo["authors"] as! NSArray).mutableCopy() as! NSMutableArray
            var authorsName: String = ""
            for index in 0...authors.count-1
            {
                let author = authors[index] as! NSDictionary
                let name = author["name"] as? String
                authorsName = authorsName + name! + "\r\n"
            }
            autoresLabel.text = authorsName
            guardarButton.isEnabled = true
            if bookInfo["cover"] != nil {
                let covers = bookInfo["cover"] as! NSDictionary
                if(covers.count > 0)
                {
                    let coverImage = covers["medium"] as! NSString
                    portadaImageView.image = obtenerPortada(imageUrl: coverImage as String)
                    portadaImageView.isHidden = false
                    sinPortada = false
                }
                else{
                    portadaImageView.isHidden = true
                }
                
            } else {
                print("el libro no tiene imagen")
                sinPortada = true
            }

            
        }
        catch{
            limpiarCampos()
        }
        

        
    }
    
    func espaciosVacios( stringValue:String) -> Bool
    {
        var stringValue = stringValue
        var returnValue = false
        
        if stringValue.isEmpty  == true
        {
            returnValue = true
            return returnValue
        }
        stringValue = stringValue.trimmingCharacters(in: NSCharacterSet.whitespaces)
        if(stringValue.isEmpty == true)
        {
            returnValue = true
            return returnValue
            
        }
        return returnValue
        
    }
    

    
    func limpiarCampos()
    {
        autoresLabel.text = ""
        tituloLabel.text = ""
        portadaImageView.isHidden = true
        isbnTextField.text = ""
    }
    
    func mostrarAlertas(title: String, message:String)
    {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func obtenerPortada(imageUrl: String) -> UIImage {
        let url = NSURL(string: imageUrl)
        let imageContentData:NSData? = NSData(contentsOf: url! as URL)
        let image = UIImage(data:imageContentData! as Data)
        
        return image!
    }
    
    
    @IBAction func guardarButton(_ sender: UIButton) {

        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let nuevoLibro = NSEntityDescription.insertNewObject(forEntityName: "Libros", into: contexto) as! Libros
        
        nuevoLibro.isbnLibro = isbnTextField.text
        nuevoLibro.autoresLibro = autoresLabel.text
        nuevoLibro.tituloLibro = tituloLabel.text
        if sinPortada == false {
           nuevoLibro.portadaLibro =  UIImagePNGRepresentation(portadaImageView.image!)
        } else {
            print("se guardo sin portada")
        }
        
        
        
        
        do {
            try contexto.save()
            print("guardo correctmente")
            limpiarCampos()

        } catch let error as NSError {
            print("no guardo", error)
        }
        
        
        mostrarAlertas(title: "Aviso", message: "Libro guardado correctamente.")
        
        
    }

    
}
