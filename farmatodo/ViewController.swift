//
//  ViewController.swift
//  farmatodo
//
//  Created by Daniel Duran Schutz on 7/1/19.
//  Copyright © 2019 OsSource. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate {
    
    
    var window: UIWindow?
    @IBOutlet weak var operationTextField: UITextField!
    @IBOutlet weak var beginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    

    
    @IBAction func processOperation(_ sender: Any) {
        takeString(string: operationTextField.text!)
    }
    
    
    
    func takeString(string:String){
        let expression = NSExpression(format:string)
        if let result = expression.expressionValue(with:nil,context: nil) as? NSNumber{
            print("\(string) = \(result)")
            if(result.intValue == 0){
                print("El número es \(result.intValue)")
                print("/v1/public/characters")
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "CharacterListViewController") as! CharacterListViewController
                self.present(next, animated: true, completion: nil)
                
                
            }else if ((result.intValue % 3) == 0) {
                print("El número \(result.intValue) es múltiplo de 3.")
                print("/v1/public/comics")
            }else if ((result.intValue % 5) == 0) {
                print("El número \(result.intValue) es múltiplo de 5.")
                print("/v1/public/comics")
            }else if ((result.intValue % 7) == 0) {
                print("El número \(result.intValue) es múltiplo de 7.")
                print("/v1/public/creators")
            }else if ((result.intValue % 11) == 0) {
                print("El número \(result.intValue) es múltiplo de 11.")
                print("/v1/public/events")
            }else if ((result.intValue % 13) == 0) {
                print("El número \(result.intValue) es múltiplo de 13.")
                print("/v1/public/series")
            }else{
                print("default/invalid:/v1/public/stories")
                let next = self.storyboard?.instantiateViewController(withIdentifier: "StoriesListViewController") as! StoriesListViewController
                self.present(next, animated: true, completion: nil)
            }
            
            
        }else{
            print("Error evaluando expresion:::")
        }
        
    }
    

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        //let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "CharacterListViewController") as! CharacterListViewController
        //self.navigationController!.pushViewController(secondViewController, animated: true)
        
        
        let mapViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "CharacterListViewController") as? CharacterListViewController
        self.navigationController?.pushViewController(mapViewControllerObj!, animated: true)
        
        
        
        print("Pase por aqui!!!")
        
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "characterList"{
            print("Pase por aqui 2!!!")
            
            //let dvc = segue.destination as! CharacterListViewController
            //print("Tambien por aqui !!!")
            //dvc.newImage = user_image.image
        }
        
        
    }
    

}

