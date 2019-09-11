//
//  ViewController.swift
//  webview7
//
//  Created by Admin on 26/7/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
import UserNotifications
import LocalAuthentication


class ViewController: UIViewController {
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBAction func btnclk(_ sender: UIButton) {
        TouchID.authenticateUser();
    }

    @IBOutlet weak var myTxt: UITextField!
    
    var messageSubtitle = "Staff Meeting in 20 minutes";
    var lat: Double = 0;
    var long: Double =  0;
    let locationManager = CLLocationManager();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self;
        loadPage();
        getCurentLocation();
        valNotification();
    }
    
    func loadPage(){
        let localfilePath = Bundle.main.url(forResource: "index1.html", withExtension: "", subdirectory: "www");
        let request = NSURLRequest(url:localfilePath!);
        webView.load(request as URLRequest);
    }
    // MARK: Bridege Func
    func do_exchange(txt: String) {
        _ = call_js(function_name: "ios_to_js", param: txt);
    }
    
    func send_geolocation() {
        let mystring = String (lat) + " , " + String(long);
        let script = "ios_to_js('\(mystring)')";
        call_js(function_name: script, param:"");
    }
    
    // run javascript on the page with result = call_js("js_fn", param:"rarameter");
    func call_js(function_name: String, param: String) -> String{
        var result = "";
        let full_path = function_name + "('" + param + "')";
        print("Run javascript: \(full_path)");
        webView.evaluateJavaScript(full_path, completionHandler: {Result, Error in
            print ("didFinish js call " ,  Result);
            result = Result as? String ?? "fail result";
        })
       
        return result;
    }
    // popup a screen on top of main screen
    func pop_new_page(txt: String) {
        
        //create webview
        let myWebView:WKWebView = WKWebView(frame:CGRect(x:0, y:20, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height - 20 ))
        
        // format txt to NSURL
        let full_path = NSURL (string: txt);
        // detect the protocol
        let scheme = full_path!.scheme;
        //get filename put of it
        let filename = full_path!.lastPathComponent;
        // get path out of it
        let pathPrefix = full_path?.deletingLastPathComponent ;
        print((pathPrefix?.absoluteString)! + " " + filename!);
        
        //it is local file
        
        var myurl = Bundle.main.url( forResource: filename, withExtension: "", subdirectory: (pathPrefix?.absoluteString)!);
        //or a link?
        if (scheme == "http") || (scheme == "https") {
            myurl = full_path! as URL;
        }
        
        let requestObj = NSURLRequest(url: myurl!);
        //let requestObj = NSURLRequest(url: full_path as! URL);
        myWebView.load(requestObj as URLRequest);
        
        // add the webview into the uiviewcontroller
        let screen_name = "popup";
        // load uiview from nib
        let viewController = popup(nibName: screen_name, bundle: nil);
        viewController.view.addSubview(myWebView);
        viewController.view.sendSubviewToBack(myWebView);
        
        // slide in or popup
        
        if navigationController != nil {
            self.navigationController?.pushViewController(viewController, animated: true)
            
        } else {
            present(viewController, animated: true, completion: nil);
        }
    }
}
// MARK: LocalNotification Delegate
extension ViewController: UNUserNotificationCenterDelegate {
    func valNotification () {
        UNUserNotificationCenter.current().delegate = self;
        // user category 1 - response for "category": "custom1" in push payload
        let repeatAction = UNNotificationAction(identifier: "repeat", title: "Repeat", options: [])
        let changeAction = UNTextInputNotificationAction(identifier: "change", title: "Change Message", options: [])
        let category = UNNotificationCategory(identifier: "custom1",
                                              actions: [repeatAction, changeAction],
                                              intentIdentifiers: [], options: [])
        
        // user category 2 - response for "category": "custom2" in push payload
        let likeAction = UNNotificationAction(identifier: "like", title: "Like", options: [])
        let saveAction = UNNotificationAction(identifier: "save", title: "Save", options: [])
        let category2 = UNNotificationCategory(identifier: "custom2", actions: [likeAction, saveAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category, category2])
        
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        UNUserNotificationCenter.current().requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
            
        }
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if #available(iOS 11.0, *) {
                switch settings.showPreviewsSetting {
                case .always:
                    print("Always")
                case .whenAuthenticated:
                    print("When unlocked")
                case .never:
                    print("Never");
                default: return;
                }
            } else {
                // Fallback on earlier versions
            };
            switch settings.authorizationStatus {
                
            case .authorized: break;
            // Schedule Local Notification
            case .denied:
                print("Application Not Allowed to Display Notifications");
                
            case .provisional:
                return;
            case .notDetermined:
                print("no setting")
            @unknown default:
                return;
            }
            
            if settings.authorizationStatus != .authorized {
                print("Notifications not allowed");
            }
        }
    }
    
    func sendNotification(txt: String) {
        let content = UNMutableNotificationContent()
        content.title = "Notification Title";
        content.subtitle = messageSubtitle;
        content.body = txt;
        content.sound = UNNotificationSound.default;
        content.badge = 1;
        
        content.categoryIdentifier = "custom1";
        
        let imageName = "gear";
        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
        let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
        content.attachments = [attachment]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let requestIdentifier = "demoNotification";
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            // Handle error
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //abel.text = notification.request.content.body;
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive
        response: UNNotificationResponse, withCompletionHandler completionHandler:
        @escaping () -> Void) {
        //      print(response.actionIdentifier);
        switch response.actionIdentifier {
        case "repeat":
            self.sendNotification(txt: "Repeat Notification");
        case "change":
            let textResponse = response
                as! UNTextInputNotificationResponse
            messageSubtitle = textResponse.userText
            self.sendNotification(txt: "change subtitle")
        default:
            break
        }
        completionHandler()
    }
}



// MARK: webView Delegate
extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print(#function);
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: {Result, Error in
            if let userAgent = Result as? String {
                print ("didFinish navigation " ,  userAgent);
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString;
        let scheme = url?.components(separatedBy: ":") ?? [];
        print(scheme[0]);
        //the scheme is the first part of the document.location before the ':'
        //in JS can be anything predefined ie aaa bbb, in this case we use 'bridge:'
        
        if scheme[0] == bridge_theme
        {
            myrecord = process_scheme(url: url!);
            switch myrecord.function {
            case "ios_alert":alert(title: "Bridging" , message: myrecord.param) {};
            case "ios_popup": pop_new_page(txt: myrecord.param);
            case "ios_pop_message": sendNotification(txt: myrecord.param);
            case "exchange" : do_exchange(txt: myrecord.param);
            case "ios_geo": send_geolocation();
            case "ios_localValidation": TouchID.authenticateUser();
            default : print("Not defined: \(myrecord.function)")
            }
        }
        decisionHandler(.allow);
    }
}
// MARK: Location Delegate
extension ViewController:CLLocationManagerDelegate {
    func getCurentLocation () {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self;
            locationManager.requestWhenInUseAuthorization();
            //locationManager.requestAlwaysAuthorization();
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.startUpdatingLocation();
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //locationManager.startUpdatingLocation();
        let location = locations.last;
        long = location!.coordinate.longitude;
        lat = location!.coordinate.latitude;
    //    print (lat," , ",long);
        //locationManager.stopUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error: " + error.localizedDescription)
    }
}
