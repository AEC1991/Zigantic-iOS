//
//  DashboardViewController.swift
//  Bityo
//
//  Created by Chirag Ganatra on 30/11/17.
//  Copyright © 2017 Chirag Ganatra. All rights reserved.
//

import UIKit
import Charts


class DashboardViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var pieView: UIView!
    @IBOutlet weak var lblDaily: UILabel!
    
    
    var pieChart : PieChartView?
    var lineChart : LineChartView?
    
    var pieChartYear : [String] = ["Electronics", "Beauty", "Crypto Currency", "Misc"]
    var pieChartValue : [Double] = [10.0, 16.0, 20.0, 60.0]
    
    var lineX : [Double] = [0 , 1, 2, 3, 5, 7]
    var XString : [String] = []
    var lineY : [Double] = [ 0.0, 4.0, 16.0, 20.0, 60.0, 40.0 ]
    var lineYEl = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.lineX = []
        self.XString = []
        self.lineY = []
        for i in 1...1{
            
            var monthString = ""
            var dayCountOfMonth = 0
            switch i {
            case 1:
                monthString = "jan"
                dayCountOfMonth = 5
                break
            case 2:
                monthString = "feb"
                dayCountOfMonth = 28
                break
            case 3:
                monthString = "mar"
                dayCountOfMonth = 31
                break
            case 4:
                monthString = "apr"
                dayCountOfMonth = 30
                break
            default :
                break
                
            }
            for j in 1...dayCountOfMonth{
                
                self.lineX.append(Double(lineYEl))
                lineYEl = lineYEl+1
                if (j%2) == 0 {
                    self.lineY.append(Double(j*2)*50)
                }else{
                    self.lineY.append(Double(j)*50)
                }
                
                if j == 1 || j==dayCountOfMonth
                {
                    
                    self.XString.append("\(j)\n\(monthString)")
                    
                }
                else
                {
                    self.XString.append("\(j)")
                }
                
            }
            
        }
        
        
        pieChart = PieChartView(frame: self.pieView.bounds)
        pieChart?.chartDescription?.text = ""
        pieChart?.drawCenterTextEnabled =    false
        
        self.setChart(dataPoints: self.pieChartYear, values: self.pieChartValue)
        pieChart?.legend.horizontalAlignment = .left
        
        pieChart?.legend.drawInside = false
        
        
        pieView.addSubview(pieChart!)
        print(lineY.count)
        print(lineX.count)
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        lineChart = LineChartView(frame: self.chartView.bounds)
        setupLineChart(x: lineX, y: lineY)
        self.chartView.addSubview(lineChart!)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        let fC = rgbaToUIColor(red: 207/255, green: 167/255, blue: 49/255, alpha: 1.0)
        let sC = rgbaToUIColor(red: 221/255, green: 180/255, blue: 63/255, alpha: 1.0)
        let tC = rgbaToUIColor(red: 207/255, green: 159/255, blue: 25/255, alpha: 1.0)
        let colorss = [themeOrangeColor,fC,sC,tC]
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count
        {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        var colors: [UIColor] = []
        for i in 0..<dataPoints.count {
            let color = themeOrangeColor.withAlphaComponent(CGFloat((i+1)/30))
            colors.append(color)
        }
        
        pieChartDataSet.colors = colorss
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChart?.data = pieChartData
        
        
//        let lineChartDataSet = LineChartDataSet(values: dataEntries, label: "xyz")
//        let lineChartData = LineChartData(dataSet: lineChartDataSet)
//        lineChart?.xAxis.labelPosition = .bottom
//        lineChart?.data = lineChartData
        
    }
    func setupLineChart(x : [Double], y : [Double]){
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<x.count{
            let de = ChartDataEntry(x: x[i], y: y[i])
            
            dataEntries.append(de)
        }
        
        let lineChartDataSet1 = LineChartDataSet(values: dataEntries, label: "Months")
        lineChartDataSet1.mode = .cubicBezier
        lineChartDataSet1.circleRadius = 0.0
        lineChartDataSet1.drawFilledEnabled = true
        lineChartDataSet1.label = ""
        lineChartDataSet1.fill = Fill.fillWithColor(themeOrangeColor.withAlphaComponent(1))
        lineChartDataSet1.fillAlpha  = 0.1
        
        lineChartDataSet1.setColor(themeOrangeColor.withAlphaComponent(1))
        lineChartDataSet1.lineWidth = 1.5
        
        
        
        let lineChartData = LineChartData(dataSet: lineChartDataSet1)
        
        lineChart?.xAxis.valueFormatter = IndexAxisValueFormatter(values:XString)
        lineChart?.rightAxis.drawLabelsEnabled = false
        
        lineChart?.xAxis.drawAxisLineEnabled = false
        lineChart?.xAxis.gridColor = .clear
        lineChart?.leftAxis.gridColor = themeLightGrayColor
        lineChart?.rightAxis.gridColor = themeLightGrayColor
        lineChart?.leftAxis.drawAxisLineEnabled = false
        lineChart?.rightAxis.drawAxisLineEnabled = false
        lineChart?.xAxis.labelPosition = .bottom
        lineChart?.data = lineChartData
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        self.sideMenuController().openMenu()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
