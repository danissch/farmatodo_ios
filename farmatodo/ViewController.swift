//
//  ViewController.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate{
    
    @IBOutlet weak var labelTitleForm: UILabel!
    
    var window: UIWindow?
    @IBOutlet weak var operationTextField: UITextField!
    @IBOutlet weak var beginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        self.operationTextField.delegate=self
//        print("Operaciones válidas")
//        takeString(string: "1-1")
//        takeString(string: "1 -1")
//        takeString(string: "1- 1")
//        takeString(string: "1 - 1")
//        takeString(string: "1- -1")
//        takeString(string: "1 - -1")
//        takeString(string: "6 + -(4)")
//        takeString(string: "6 + -(-4)")
        //takeString(string: "(2 + (1 + 1)) * 6 +  - ( - 4)")
        //takeString(string: "6 * 3")
        //takeString(string: operationTextField.text!)
        
    }
    
    
    @IBAction func copyExample(_ sender: Any) {
        copiarEjemplo()
    }
    
    
    @IBAction func processOperation(_ sender: Any) {
        if(operationTextField.text != ""){
            takeString(string: operationTextField.text!)
        }else{
            labelTitleForm.textColor = .red
            labelTitleForm.text = "Ingresa una operación válida"
        }
        
    }
    
    func copiarEjemplo(){
        var ejemplo1:String = "(2 + (1 + 1)) * 6 +  - ( - 4)"
        operationTextField.text = ejemplo1
    }
    
    func assignbackground(){
        let background = UIImage(named: "94c3bd90b8037c3fe8acfd589c9af65f")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
    }
    
    func takeString(string:String){
        let expression = NSExpression(format:string)
        if let result = expression.expressionValue(with:nil,context: nil) as? NSNumber{
            print("\(string) = \(result)")
            if(result.intValue == 0){
                print("El número es \(result.intValue)")
                print("/v1/public/characters")
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "CharacterListViewController") as! CharacterListViewController
                next.resultado = result.intValue
                self.present(next, animated: true, completion: nil)
                
                
            }else if ((result.intValue % 3) == 0 || (result.intValue % 5) == 0) {
                
                print("El número \(result.intValue) es múltiplo de 3.")
                print("/v1/public/comics")
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "ComicListViewController") as! ComicListViewController
                next.resultado = result.intValue
                self.present(next, animated: true, completion: nil)
                
            }else if ((result.intValue % 7) == 0) {
                print("El número \(result.intValue) es múltiplo de 7.")
                print("/v1/public/creators")
                let next = self.storyboard?.instantiateViewController(withIdentifier: "CreatorListViewController") as! CreatorListViewController
                next.resultado = result.intValue
                self.present(next, animated: true, completion: nil)
                
            }else if ((result.intValue % 11) == 0) {
                print("El número \(result.intValue) es múltiplo de 11.")
                print("/v1/public/events")
                let next = self.storyboard?.instantiateViewController(withIdentifier: "EventListViewController") as! EventListViewController
                next.resultado = result.intValue
                self.present(next, animated: true, completion: nil)
                
            }else if ((result.intValue % 13) == 0) {
                print("El número \(result.intValue) es múltiplo de 13.")
                print("/v1/public/series")
                let next = self.storyboard?.instantiateViewController(withIdentifier: "SerieListViewController") as! SerieListViewController
                next.resultado = result.intValue
                self.present(next, animated: true, completion: nil)
                
            }else{
                print("default/invalid:/v1/public/stories")
                let next = self.storyboard?.instantiateViewController(withIdentifier: "StoriesListViewController") as! StoriesListViewController
                next.resultado = result.intValue
                self.present(next, animated: true, completion: nil)
            }
            
            
        }else{
            print("Error evaluando expresion:::")
        }
        
    }
    

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

//        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "CharacterListViewController") as? CharacterListViewController
//        self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
        print("Pase por aqui!!!")
        
        return true
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cList"{
            print("Pase por aqui 2!!!")
            
            //let dvc = segue.destination as! CharacterListViewController
            //print("Tambien por aqui !!!")
            //dvc.newImage = user_image.image
        }
        
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.rangeOfCharacter(from: CharacterSet.letters) == nil
    }
    

}

