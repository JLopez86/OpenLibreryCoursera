//
//  PrincipalViewController.swift
//  OpenLibreryCoursera
//
//  Created by Jose Lopez on 8/1/18.
//  Copyright © 2018 Jose Lopez. All rights reserved.
//

import UIKit
import CoreData

class PrincipalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    var libros : [Libros] = []
    var fetchResultController : NSFetchedResultsController<Libros>!
    var refrescar : UIRefreshControl!
    
    @IBOutlet weak var tabla: UITableView!
    
    
    func conexion () -> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabla.delegate = self
        tabla.dataSource = self
        
        let contexto = conexion()
        let fetchRequest : NSFetchRequest<Libros> = Libros.fetchRequest()
        
        let orderByNombre = NSSortDescriptor(key: "tituloLibro", ascending: true)
        fetchRequest.sortDescriptors = [orderByNombre]
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: contexto, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            libros = fetchResultController.fetchedObjects!
        } catch let error as NSError {
            print("Hubo un error", error)
        }
        

        refrescar = UIRefreshControl()
        tabla.alwaysBounceVertical = true
        refrescar.tintColor = UIColor.green
        refrescar.addTarget(self, action: #selector(recargarDatos), for: .valueChanged)
        tabla.addSubview(refrescar)

    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tabla.reloadData()
    }
    
    
    @objc func recargarDatos(){
        tabla.reloadData()
        stop()
    }
    
    func stop(){
        refrescar.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libros.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tabla.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        let libro = libros[indexPath.row]
        celda.textLabel?.text = libro.tituloLibro
        celda.detailTextLabel?.text = libro.autoresLibro
        return celda
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
//    978-07-802-5996-6
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.endUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tabla.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let botonBorrar = UITableViewRowAction(style: .destructive, title: "Borrar") { (action, indexPath) in
            let contexto = self.conexion()
            let borrar = self.fetchResultController.object(at: indexPath)
            contexto.delete(borrar)
            
            do {
                try contexto.save()
            } catch {
                print("Error al borrar")
            }
        }

        
        return [botonBorrar]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "verDetalle" {
            if let indexPath = tabla.indexPathForSelectedRow {
                let objecto = fetchResultController .object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetalleViewController
                controller.detalleLibro = objecto
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    


    

    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tabla.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tabla.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    

    
}
