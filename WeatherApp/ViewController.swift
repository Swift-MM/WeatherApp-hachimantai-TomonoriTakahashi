//
//  ViewController.swift
//  WeatherApp
//
//  Created by 高橋知憲 on 2016/11/13.
//  Copyright © 2016年 高橋知憲. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet var weatherImageCollection: [UIImageView]!
    @IBOutlet var weatherLabelCollection: [UILabel]!
    
    let weatherJsonUrl:String = "http://weather.livedoor.com/forecast/webservice/json/v1?city=030010"
    
    
    // 気温のラベル用テキストを生成します。
    func generateTemperatureText(_ temperature: JSON) -> String {
        
        var resultText = ""
        
        if let min = temperature["min"]["celsius"].string {
            resultText += min + "℃"
        } else {
            resultText += "-"
        }
        
        resultText += " / "
        
        if let max = temperature["max"]["celsius"].string {
            resultText += max + "℃"
        } else {
            resultText += "-"
        }
        
        return resultText
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Alamofireを利用して通信を行います。
        Alamofire.request(weatherJsonUrl).responseJSON { (response: DataResponse<Any>) in self.getWeather(response)}
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 閉じるボタンのみのアラートを表示します。
    func simpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    func getWeather(_ response: DataResponse<Any>){
          if response.result.isFailure {
                self.simpleAlert(title: "通信エラー", message: "通信に失敗しました")
                return
            }
            
            // "guard let 変数 〜 else" で変数の中身がnilの場合のみの処理が書けます。
            // ただし最後に必ずreturnで関数を終了させなければいけません。
            // 変数は以後の関数内でも利用できます。
            
            
            guard let val = response.result.value as? [String: Any] else {
                self.simpleAlert(title: "通信エラー", message: "通信結果がJSONではありませんでした")
                return
            }
            
            // responseJSONを使うと辞書形式でも扱えますが、今回はより簡単に扱うためにSwiftyJSONを利用します。
            let json = JSON(val)
            
            // タイトル部分
            if let title = json["title"].string {
                self.titleLabel.text = title
            }
        
            //天気の情報
            if let forecasts = json["forecasts"].array {
                for var i:Int in 0..<forecasts.count{
                        let weatherInfo:JSON = forecasts[i]
                        
                        self.weatherLabelCollection[i].text = weatherInfo["dateLabel"].stringValue + ":" + weatherInfo["telop"].stringValue + " " + self.generateTemperatureText(weatherInfo["temperature"])
                        if let imgUrl = weatherInfo["image"]["url"].string {
                            self.weatherImageCollection[i].sd_setImage(with: URL(string: imgUrl))
                        }
                    }
                
            }
        }
    
    }
    


