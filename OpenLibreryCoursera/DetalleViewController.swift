//
//  DetalleViewController.swift
//  OpenLibreryCoursera
//
//  Created by Jose Lopez on 8/1/18.
//  Copyright © 2018 Jose Lopez. All rights reserved.
//

import UIKit

class DetalleViewController: UIViewController {


    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var isbn: UILabel!
    @IBOutlet weak var autores: UILabel!
    @IBOutlet weak var portada: UIImageView!
    
    var detalleLibro: Libros? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    var port : Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func configureView() {
        // Update the user interface for the detail item.
        
        if let detalle = detalleLibro {
            if let labelTitulo = titulo {
                labelTitulo.text = detalle.tituloLibro
            }
            if let labelAutores = autores
            {
                labelAutores.text = detalle.autoresLibro
                
            }
            if let labelIsbn = isbn{
                labelIsbn.text = detalle.isbnLibro
            }
            
            port =  detalle.portadaLibro
            
            if port != nil {
                if let imagePortada = portada{
                    imagePortada.image = UIImage(data: detalle.portadaLibro! as Data)
                }
            }
            
            
            
        }
    }
    
    

}
