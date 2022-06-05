//
//  WithingsView.swift
//  Connecté ?
//
//  Created by Cyril DELAMARE on 26/04/2022.
//  Copyright © 2022 Cyril DELAMARE. All rights reserved.
//

import Foundation
import UIKit

class WithingsView: UIViewController {
    @IBOutlet weak var graphePoids: WithingsGraphe!
    @IBOutlet weak var grapheTemp: WithingsGraphe!
    @IBOutlet weak var grapheMeds: MedicamentsGraphe!
    
    @IBOutlet weak var chimioNumber: UISegmentedControl!
    @IBOutlet weak var weekNumber: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphePoids.receiveGrapheType(type: 0)
        grapheTemp.receiveGrapheType(type: 1)

        sendDates()
    }
    
    @IBAction func setChimio(_ sender: Any) {
        sendDates()
        
        graphePoids.setNeedsDisplay()
        grapheTemp.setNeedsDisplay()
        grapheMeds.setNeedsDisplay()
    }
    
    func sendDates() {
        var beg : Int = startChimios+(oneWeek*3*chimioNumber.selectedSegmentIndex)
        var end : Int = startChimios+(oneWeek*3*chimioNumber.selectedSegmentIndex)+(oneWeek*3)

        if (weekNumber.selectedSegmentIndex > 0) {
            beg = startChimios+(oneWeek*3*chimioNumber.selectedSegmentIndex)+(oneWeek*(weekNumber.selectedSegmentIndex-1))
            end = startChimios+(oneWeek*3*chimioNumber.selectedSegmentIndex)+(oneWeek*(weekNumber.selectedSegmentIndex-1))+oneWeek
        }
        
        graphePoids.receiveDates(debut: beg, fin: end)
        grapheTemp.receiveDates(debut: beg, fin: end)
        grapheMeds.receiveDates(debut: beg, fin: end)
    }
}


class WithingsGraphe : UIView {
    let origineX : CGFloat = 30.0
    let colorAxis : UIColor = .systemGray
    var data : (at : [Int], vals : [Int]) = ([], [])
    
    var start : Int = 0
    var end   : Int = 0
    
    let minPoids : Int = 81000
    let maxPoids : Int = 86000

    let minTemp : Int = 36000
    let maxTemp : Int = 39000

    var min : Int = 0
    var max : Int = 0
    var measure : Int = 0
    var couleur : UIColor = UIColor.systemGray
    var diametre : CGFloat = 3.0
    
    var modeWeek : Bool = false
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        // Get data
        data = withings.loadMeasures(measure: measure, start: start, end: end)

        // Drawing code here.
        self.traceCadre()
        self.tracePoints()
    }

    func receiveDates(debut: Int, fin : Int) {
        start = debut
        end = fin
        
        modeWeek = (fin - debut) < (2 * oneWeek)
    }
    
    func receiveGrapheType(type : Int) {
        if (type == 0) {
            min = minPoids
            max = maxPoids
            measure = withings.measureWeight
            couleur = UIColor.systemBlue
            diametre = 6.0
        }
        else {
            min = minTemp
            max = maxTemp
            measure = withings.measureBodyTemp
            couleur = UIColor.systemRed
            diametre = 3.0
        }
    }
    
    
    func traceCadre() {
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 5.0)
        let largeur : CGFloat = (self.frame.width - origineX - 5.0)
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: colorAxis]
        
        // Lignes
        colorAxis.setStroke()

        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 0.5
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()

        //
        // Aspects horizontaux
        //

        // Lignes achurées
        let nbLignes : Int = (max - min)/1000

        for i:Int in 1 ..< nbLignes {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.lineWidth = 0.5
            pathLine.move(to: CGPoint(x: origineX, y: origineY - (hauteur * CGFloat(i)/CGFloat(nbLignes))))
            pathLine.addLine(to: CGPoint(x: origineX + largeur, y: origineY - (hauteur * CGFloat(i)/CGFloat(nbLignes))))

            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }

        // Légende en Y
        for i:Int in 0 ..< nbLignes {
            let pds : NSString = String((min/1000)+i) as NSString
            pds.draw(in: CGRect(x: 8, y: origineY - (hauteur * CGFloat(i)/CGFloat(nbLignes)) - 7, width: 30, height: 10), withAttributes: textAttributes)
        }

        
        //
        // Aspects verticaux
        //
        let dateFormShort   = DateFormatter()
        dateFormShort.locale = Locale.current
        dateFormShort.dateFormat = "dd MMM"

        var nbSeperationsVerticales : Int = 0
        var increment : Int = 0

        if (modeWeek) {
            nbSeperationsVerticales = 7
            increment = oneDay
        } else {
            nbSeperationsVerticales = 3
            increment = oneWeek
        }
        
        // Labels
        for i:Int in 0 ..< nbSeperationsVerticales {
            let jour : NSString = String(dateFormShort.string(from: Date(timeIntervalSince1970: TimeInterval(start+(i*increment))))) as NSString
            jour.draw(in: CGRect(x: origineX - 5.0 + (largeur * (CGFloat(i)) / CGFloat(nbSeperationsVerticales)),
                                   y: self.frame.height - 25, width: 60, height: 12),
                        withAttributes: textAttributes)
        }

        // Lignes hachurées
        for i:Int in 1 ..< nbSeperationsVerticales {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbSeperationsVerticales)), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbSeperationsVerticales)), y: origineY - hauteur))

            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
    }


    func tracePoints() {
        for i:Int in 0 ..< data.at.count {
            traceUnPoint(at: data.at[i], val: data.vals[i])
        }
    }


    func traceUnPoint(at: Int, val: Int) {
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 10.0)
        let largeur : CGFloat = (self.frame.width - origineX - 5.0)

        if ( (at < start) || (at > end) ) { return }

        if (measure == withings.measureWeight) {
            couleur.setStroke()
        } else {
            if (val < 37000) { UIColor.systemGreen.setStroke() }
            else if (val < 37500) { UIColor.systemOrange.setStroke() }
            else { UIColor.systemRed.setStroke() }
        }
        
        let path : UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: origineX + (largeur * CGFloat(at-start) / CGFloat(end-start) + (diametre / 2) ),
                                        y: origineY - (hauteur * CGFloat(val-min) / CGFloat(max-min) ) - (diametre / 2) ),
                    radius: diametre / 2,
                    startAngle: 2 * .pi,
                    endAngle: 0,
                    clockwise: false)
        path.stroke()
    }
}



class MedicamentsGraphe : UIView {
    let origineX : CGFloat = 30.0
    var data : (at : [Int], vals : [String]) = ([], [])
    
    var start : Int = 0
    var end   : Int = 0
    var modeWeek : Bool = false

    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)

        // Clean all
        subviews.forEach({ $0.removeFromSuperview() })
        
        // Get data
        data = readData()

        // Drawing code here.
        self.traceCadre()
        self.traceMedocs()
    }

    
    func receiveDates(debut: Int, fin : Int) {
        start = debut
        end = fin
        
        modeWeek = (fin - debut) < (2 * oneWeek)
    }
    
    
    func readData() -> (at : [Int], vals : [String]) {
        var at   : [Int] = []
        var vals : [String] = []
        let bundleURL = Bundle.main.bundleURL
        let dateFormatter = ISO8601DateFormatter()
        
        if FileManager.default.fileExists(atPath :  bundleURL.appendingPathComponent("note.csv").path) {
            let contents = try! String(contentsOfFile :  bundleURL.appendingPathComponent("note.csv").path)
            let rows = contents.components(separatedBy :  "\n")
            for row in rows {
                let columns = row.components(separatedBy :  ",")
                if (columns.count == 4) {
                    if ( (columns[1] != "-") && (columns[0] != "date") ){
                        let timestamp : Int = Int(dateFormatter.date(from: columns[0])!.timeIntervalSince1970)
                        let medoc : String = columns[1].replacingOccurrences(of: "[", with: "")
                                                        .replacingOccurrences(of: "]", with: "")
                                                        .replacingOccurrences(of: "\"", with: "")

                        at.append(timestamp)
                        vals.append(medoc)
                    }
                }
            }
        }

        return (at, vals)
    }
    
    
    func traceCadre() {
        let origineY :CGFloat = self.frame.height - 30.0
        let hauteur : CGFloat = (self.frame.height - 30.0 - 5.0)
        let largeur : CGFloat = (self.frame.width - origineX - 5.0)
        let textAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.systemGray]

        // Lignes
        UIColor.systemGray.setStroke()

        // Cadre
        let path : UIBezierPath = UIBezierPath()
        path.lineWidth = 0.5
        path.move(to: CGPoint(x: origineX, y: origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY-hauteur))
        path.addLine(to: CGPoint(x:origineX+largeur, y:origineY))
        path.addLine(to: CGPoint(x:origineX, y:origineY))
        path.stroke()

        //
        // Aspects verticaux
        //
        let dateFormShort   = DateFormatter()
        dateFormShort.locale = Locale.current
        dateFormShort.dateFormat = "dd MMM"

        var nbSeperationsVerticales : Int = 0
        var increment : Int = 0

        if (modeWeek) {
            nbSeperationsVerticales = 7
            increment = oneDay
        } else {
            nbSeperationsVerticales = 3
            increment = oneWeek
        }
        
        // Labels
        for i:Int in 0 ..< nbSeperationsVerticales {
            let jour : NSString = String(dateFormShort.string(from: Date(timeIntervalSince1970: TimeInterval(start+(i*increment))))) as NSString
            jour.draw(in: CGRect(x: origineX - 5.0 + (largeur * (CGFloat(i)) / CGFloat(nbSeperationsVerticales)),
                                   y: self.frame.height - 25, width: 60, height: 12),
                        withAttributes: textAttributes)
        }

        // Lignes hachurées
        for i:Int in 1 ..< nbSeperationsVerticales {
            let pathLine : UIBezierPath = UIBezierPath()
            pathLine.move(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbSeperationsVerticales)), y: origineY))
            pathLine.addLine(to: CGPoint(x: origineX + (largeur * CGFloat(i) / CGFloat(nbSeperationsVerticales)), y: origineY - hauteur))

            pathLine.setLineDash([10.0,10.0], count: 2, phase: 5.0)
            pathLine.stroke()
        }
    }
    
    func traceMedocs() {
        for i in 0..<data.at.count {
            traceUnMedoc(timestamp: data.at[i], medoc: data.vals[i])
        }
    }

    func traceUnMedoc(timestamp : Int, medoc: String) {
        let largeur : CGFloat = (self.frame.width - origineX - 5.0)
        let toto : UILabel = UILabel()

        if ( (timestamp < start) || (timestamp > end) ) { return }

        toto.text = medoc
        toto.font = UIFont.systemFont(ofSize: 9)
        toto.textColor = .systemBlue
        self.addSubview(toto)
        
        toto.transform = CGAffineTransform(rotationAngle: -1.555)
        toto.frame = CGRect(x: origineX + (largeur * CGFloat(timestamp-start) / CGFloat(end-start) ) - 6, y: self.frame.height - 160, width: 12, height: 120)
    }
}
