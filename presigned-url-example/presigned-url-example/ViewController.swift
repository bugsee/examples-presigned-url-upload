//
//  ViewController.swift
//  presigned-url-example
//
//  Created by Dmitry Fink on 4/4/17.
//  Copyright © 2017 Dmitry Fink. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    let imagePicker = UIImagePickerController()

    var s3Link : URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

        requestForS3Link()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonClicked(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage

            uploadImageToS3(image: pickedImage)
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func uploadImageToS3(image: UIImage) {
        if (self.s3Link == nil) {
            return
        }

        if let imgData = UIImageJPEGRepresentation(image, 1.0) {
            var urlRequest = URLRequest.init(url: self.s3Link!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60);
            
            urlRequest.httpMethod = "PUT";
            urlRequest.setValue("", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue("\(([UInt8](imgData)).count)", forHTTPHeaderField: "Content-Length")
            urlRequest.setValue("iPhone-OS", forHTTPHeaderField: "User-Agent")
            urlRequest.setValue("testImage", forHTTPHeaderField: "fileName")

            URLSession.shared.uploadTask(with: urlRequest, from:imgData) { (data, response, error) in
                if error != nil {
                    print(error!)
                }else{
                    print(String.init(data: data!, encoding: .utf8)!);
                }
            }.resume();
        }
    }

    func requestForS3Link() {
        var urlRequest = URLRequest.init(url: URL.init(string: "http://192.168.1.74:3000/users/testUser/objects")!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60);
        urlRequest.httpMethod = "POST";

        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {

                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options:
                            JSONSerialization.ReadingOptions.mutableContainers)

                        if let jsonResult = jsonResult as? [String: Any] {
                            self.s3Link = URL.init(string: jsonResult["url"] as! String )!
                        }
                    } catch {
                        print("JSON parsing faild")
                    }
                }
            }
        }.resume()
    }
}

