//
//  ViewController.swift
//  presigned-url-example
//
//  Created by Dmitry Fink on 4/4/17.
//  Copyright © 2017 Dmitry Fink. All rights reserved.
//

import UIKit

let LocalServerAddress = "http://x.x.x.x:3000"

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!

    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self

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

            uploadImage(image: pickedImage)
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func uploadImage(image: UIImage) {

        if let imgData = UIImageJPEGRepresentation(image, 1.0) {
            requestSignedUrl(completion: {(_ url: URL, _ method: String) -> Void in
                self.uploadtoSignedUrl(imgData, url, method)
                })
        }
    }

    func uploadtoSignedUrl(_ data: Data, _ url: URL, _ method: String) {
        var urlRequest = URLRequest.init(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60);

        urlRequest.httpMethod = method;
        urlRequest.setValue("", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(([UInt8](data)).count)", forHTTPHeaderField: "Content-Length")
        urlRequest.setValue("iPhone-OS", forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("testImage", forHTTPHeaderField: "fileName")

        URLSession.shared.uploadTask(with: urlRequest, from:data) { (data, response, error) in
                if error != nil {
                    print(error!)
                }else{
                    print(response!);
                    print(String.init(data: data!, encoding: .utf8)!);
                }
            }.resume()
    }

    func requestSignedUrl(completion: @escaping ((_ url: URL, _ method: String) -> Void)) {
        var urlRequest = URLRequest.init(url: URL.init(string: "\(LocalServerAddress)/users/testUser/objects")!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 60);
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
                                completion(URL.init(string: jsonResult["url"] as! String )!, jsonResult["method"] as! String)
                        }
                    } catch {
                        print("JSON parsing faild")
                    }
                }
            }
        }.resume()
    }
}

