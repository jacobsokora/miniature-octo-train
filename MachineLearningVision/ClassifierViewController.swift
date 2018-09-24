//
//  ClassifierViewController.swift
//  MachineLearningVision
//
//  Created by Jacob Sokora on 9/13/18.
//  Copyright © 2018 Jacob Sokora. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ClassifierViewController: UIViewController {

    @IBOutlet weak var inputImageView: UIImageView!
    @IBOutlet weak var outputTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func takePhoto(_ sender: UIBarButtonItem) {
        presentPhotoPicker(for: .camera)
    }
    
    @IBAction func choosePhoto(_ sender: UIBarButtonItem) {
        presentPhotoPicker(for: .photoLibrary)
    }
    
    func presentPhotoPicker(for sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func identifyImage() {
        guard let image = inputImageView.image else {
            outputTextView.text += "\nNo image found, something went wrong here..."
            return
        }
        do {
            let model = try VNCoreMLModel(for: VGG16().model)
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNClassificationObservation] else {
                    self.outputTextView.text += "\nNo classifications returned"
                    return
                }
                for classification in results {
                    self.outputTextView.text += "\n\(classification.identifier): \(classification.confidence * 100)%"
                }
            }
            guard let data = image.pngData() else {
                outputTextView.text += "\nFailed to create data from image"
                return
            }
            let handler = VNImageRequestHandler(data: data)
            try handler.perform([request])
        } catch {
            outputTextView.text += "\n\(error.localizedDescription)"
        }
    }
}

extension ClassifierViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        for piece in info {
            if piece.value is UIImage {
                inputImageView.image = piece.value as? UIImage
                outputTextView.text = "Classifying image..."
                picker.dismiss(animated: true) {
                    DispatchQueue.main.async {
                        self.identifyImage()
                    }
                }
            }
        }
    }
}

extension ClassifierViewController: UINavigationControllerDelegate {
    
}
