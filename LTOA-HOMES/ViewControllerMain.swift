//
//  ViewControllerMain.swift
//  LTOA-HOMES
//
//  Created by Stephen Harb on 4/18/19.
//  Copyright © 2019 Stephen Harb. All rights reserved.
//

import UIKit

class ViewControllerMain: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var memberName: UILabel!
    
    var Name: String?
    var Address: String?
    var Number: String?
    var Email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Name)
        self.memberName.text = self.Name
    }
    //codeCommentRevision
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    @IBAction func personalInfoButton(_ sender: Any) {
        //self.performSegue(withIdentifier: "mainToPersonal" , sender: nil)
        var endpoint : String = "https://d1jq46p2xy7y8u.cloudfront.net/member/search"
        let url = URL(string: endpoint)
        var request = URLRequest(url: url!)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let loginData: [String?: Any] = ["memberName": Name]
        let loginJson: Data
        do {
            loginJson = try JSONSerialization.data(withJSONObject: loginData, options: [])
            request.httpBody = loginJson
        } catch {
            print("Error: cannot create JSON from Member data")
            return
        }
        
        exec(request: request, session: session)
        self.performSegue(withIdentifier: "mainToPersonal" , sender: nil)
        
    }
    
    func exec(request: URLRequest, session: URLSession)
    {
        let sem = DispatchSemaphore.init(value: 0)
        let task = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) in
            let json = try? JSONSerialization.jsonObject(with: (data ?? nil)!, options: []) as! [String: AnyObject]
            let jsonBodyAddress = json?["memberAddress"] as? String
            let jsonBodyNumber = json?["contactNumber"] as? String
            let jsonBodyEmail = json?["email"] as? String
            self.Address = jsonBodyAddress
            self.Number = jsonBodyNumber
            self.Email = jsonBodyEmail
            sem.signal()
        }
        )
        task.resume()
        sem.wait()
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let ViewControllerPersonal = segue.destination as? ViewControllerPersonal {
            ViewControllerPersonal.loginName = Name
            ViewControllerPersonal.address = Address
            ViewControllerPersonal.email = Email
            ViewControllerPersonal.number = Number
        }
    }}