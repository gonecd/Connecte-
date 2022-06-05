//
//  ViewController.swift
//  Connecté ?
//
//  Created by Cyril DELAMARE on 02/12/2018.
//  Copyright © 2018 Cyril DELAMARE. All rights reserved.
//

import UIKit

var netatmo   : Netatmo  = Netatmo.init()
var xiaomi    : Xiaomi   = Xiaomi.init()
var withings  : Withings = Withings.init()
var nest      : Nest     = Nest.init()

let startChimios : Int = 1646866800
let oneWeek      : Int = 604800
let oneDay       : Int = 86400



class ViewController: UIViewController {

    @IBOutlet weak var boutonNetatmo: UIButton!
    @IBOutlet weak var boutonNest: UIButton!
    @IBOutlet weak var boutonWithings: UIButton!
    @IBOutlet weak var boutonXiaomi: UIButton!

    
    @IBOutlet weak var labelWithings: UILabel!
    @IBOutlet weak var labelNest: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        withings.askAuthorization()
        //nest.askAuthorization()

        initBouton(unBouton: boutonNetatmo, couleur : UIColor.blue)
        initBouton(unBouton: boutonNest, couleur : UIColor.darkGray)
        initBouton(unBouton: boutonWithings, couleur : UIColor.darkGray)
        initBouton(unBouton: boutonXiaomi, couleur : UIColor.darkGray)
        
        showPiles()
    }

    
    func showPiles() {
        labelWithings.text = withings.piles
        labelNest.text = nest.piles
    }
    
    
    
    func initBouton(unBouton : UIButton, couleur : UIColor) {
        // Ombre portée
        unBouton.layer.shadowColor = UIColor.black.cgColor
        unBouton.layer.shadowOpacity = 0.4
        unBouton.layer.shadowOffset = CGSize(width: 10.0, height: 10.0)
        unBouton.layer.shadowRadius = 10.0
        
        // Bordure
        unBouton.layer.borderColor = couleur.cgColor
        unBouton.layer.borderWidth = 2.0

        // Coins arrondis
        unBouton.layer.cornerRadius = 8.0
    }
    
    
    @IBAction func toggleDisplay(_ sender: Any) {
    }
    
   
    
    @IBAction func startNetatmo(_ sender: Any) {
        netatmo.askAuthorization()
        
    }
    
    @IBAction func startNest(_ sender: Any) {
        nest.askAuthorization()
        showPiles()
    }
    
    @IBAction func startWithings(_ sender: Any) {
        withings.askAuthorization()
        showPiles()
        
//        withings.loadMeasures(measure: withings.measureBodyTemp, start: startChimios+(6*oneWeek), end: startChimios+(7*oneWeek))
    }
    
    @IBAction func startXiaomi(_ sender: Any) {
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

