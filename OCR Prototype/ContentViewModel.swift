//
//  ContentViewModel.swift
//  OCR Prototype
//
//  Created by Mathieu Dubart on 26/03/2026.
//

import SwiftUI
import Vision
import Observation

@Observable
class ContentViewModel {
    var selectedImage: UIImage?
    var recognizedTextBlocks: [SynthetizedMobility] = []
    
    var field1Title = "Date"
    var field1Value = ""
    var field2Title = "Total"
    var field2Value = ""
    
    func processImage(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard error == nil else {
                print("Erreur OCR : \(error!.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var texts: [SynthetizedMobility] = []
            
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    texts.append(SynthetizedMobility(text: topCandidate.string, boundingBox: observation.boundingBox))
                }
            }
            
            DispatchQueue.main.async {
                self?.recognizedTextBlocks = texts
                self?.autofillFields()
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["fr-FR", "en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Erreur lors de l'exécution de la requête : \(error.localizedDescription)")
            }
        }
    }

    func autofillFields() {
        let allText = recognizedTextBlocks.map { $0.text }

        let datePatterns = [
            #"\b\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4}\b"#,
            #"\b\d{4}[\/\-\.]\d{1,2}[\/\-\.]\d{1,2}\b"#
        ]
        for line in allText {
            for pattern in datePatterns {
                if let range = line.range(of: pattern, options: .regularExpression) {
                    field1Value = String(line[range])
                    break
                }
            }
            if !field1Value.isEmpty { break }
        }

        let totalPattern = #"\d+([\.,]\d{1,4})?\s?[€$]"#
        for line in allText {
            if let match = line.range(of: totalPattern, options: .regularExpression) {
                let matched = String(line[match])
                let numPattern = #"\d+[\.,]\d{2}"#
                if let numRange = matched.range(of: numPattern, options: .regularExpression) {
                    field2Value = String(matched[numRange])
                    break
                }
            }
        }
    }
}

