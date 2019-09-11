//
//  globalfuncs.swift
//  FeedBack
//
//  updated by Michael Tran on 7/3/18.
//  Copyright © 2018 Michael Tran. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration


/** Name: localStorageWrite
 for:  store data to local storage
 */
func localStorageWrite(myKey: String, value: String) {
    let localStorage = UserDefaults.standard;
    localStorage.set(value, forKey : myKey);
}
/** Name: localStorageRead
 for: Get data from local storage
 */
func localStorageRead(key: String) -> String{
    let localStorage = UserDefaults.standard;
    if let value: String = localStorage.object(forKey: key) as? String{
        return value;
    }
    return "";
}

/** Name: callNumber
for:
*/
func callNumber(phoneNumber:String) {
    if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
        
        let application:UIApplication = UIApplication.shared
        if (application.canOpenURL(phoneCallURL)) {
            if #available(iOS 10.0, *) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

// mimic VC message box
func msgBox (title: String, message: String ) {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
    }))
    appDelegate.window!.rootViewController?.present(alertController, animated: true, completion: nil)
}
// mimic js alert
func alert (title: String, message: String , callback:  @escaping () -> ()) {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        callback()
    }))
    appDelegate.window!.rootViewController?.present(alertController, animated: true, completion: nil)
}

// mimic yesno box
func YesNo (mytitle: String, mymessage: String, callback:  @escaping () -> ()) {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
    let refreshAlert = UIAlertController(title: mytitle, message: mymessage, preferredStyle: UIAlertController.Style.alert)
    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
        callback()
    }))
    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        print("cancelled")
    }))
    appDelegate.window!.rootViewController?.present(refreshAlert, animated: true, completion: nil)
}
// template only
func switchViewControllers(boardName: String, Id: String, nav: Bool) {
    // switch root view controllers
    let storyboard = UIStoryboard.init(name: boardName, bundle: nil)
    let nav = storyboard.instantiateViewController(withIdentifier: Id)
   // nav.correctPin = globalData.presetPin; // global debug data
   // nav.delegate = self;
   // navigationController?.pushViewController(nav, animated: true)
    
}
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
// usage: var color1 = hexStringToUIColor("#d3d3d3")
func hexStringToUIColor (hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue: UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIView{
    func showBlurLoader(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.startAnimating()
        
        blurEffectView.contentView.addSubview(activityIndicator)
        activityIndicator.center = blurEffectView.contentView.center
        
        self.addSubview(blurEffectView)
    }
    
    func removeBluerLoader(){
        self.subviews.compactMap {  $0 as? UIVisualEffectView }.forEach {
            $0.removeFromSuperview()
        }
    }
}

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
// LoadingOverlay.shared.showOverlay(view: UIApplication.shared.keyWindow!)
public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var bgView = UIView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showOverlay(view: UIView) {
        
        bgView.frame = view.frame
        bgView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        bgView.addSubview(overlayView)
        bgView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin,.flexibleHeight, .flexibleWidth]
        overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.center = view.center
        overlayView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin]
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
       
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        
        overlayView.addSubview(activityIndicator)
        view.addSubview(bgView)
        self.activityIndicator.startAnimating()
        
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        bgView.removeFromSuperview()
    }
}
// usage : let jsonString = JSONStringify(jsonObject)
func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String{
    let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
    if JSONSerialization.isValidJSONObject(value) {
        do{
            let data = try JSONSerialization.data(withJSONObject: value, options: options)
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return string as String
            }
        }catch {
            print("error convert json to jsonString")
            //Access error here
        }
    }
    return ""
}


func alertWithTF(_ callback: @escaping (_ in: String) -> ()) {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate;
    let alert = UIAlertController(title: "OurList", message: "Add new item", preferredStyle: UIAlertController.Style.alert)
    //Step : 2
    let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
        let textField = alert.textFields![0] as UITextField
     //   let textField2 = alert.textFields![1] as UITextField
        if textField.text != "" {
            //Read TextFields text data
            print(textField.text!)
            print("TF 1 : \(textField.text!)");
            callback(textField.text!);
        } else {
            print("TF 1 is Empty...")
        }
        
//        if textField2.text != "" {
//            print(textField2.text!)
//            print("TF 2 : \(textField2.text!)")
//        } else {
//            print("TF 2 is Empty...")
//        }
    }
    
    //Step : 3
    //For first TF
    alert.addTextField { (textField) in
        textField.placeholder = "Enter item for ourlist"
        textField.textColor = .red
    }
    //For second TF
//    alert.addTextField { (textField) in
//        textField.placeholder = "Enter your last name"
//        textField.textColor = .blue
//    }
    let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
    alert.addAction(cancel)
    //Step : 4
    alert.addAction(save)
    //Cancel action

    //OR single line action
    //alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })
    
     appDelegate.window!.rootViewController?.present(alert, animated:true, completion: nil)
    
}
extension UINavigationController {
    
    public func pushViewController(_ viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }
    
    public func popViewController(animated: Bool,
                                  completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
}

extension UIImageView {
    func downloadedFrom(url: String) {
        let url = URL(string: url)!
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                if let imageData = data {
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
}
/*
extension UIImageView {
    func downloadedFrom(url: String) {
        let url = URL(string: url)!
    let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        if let imageData = data {
           self.image = UIImage(data: imageData)
        }
}

   
func downloadedFrom(url: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        let url = URL(string: url)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
 
}

extension UIImageView {
    func downloadedFrom(url: String) {
        let url = URL(string: url)!
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
*/
