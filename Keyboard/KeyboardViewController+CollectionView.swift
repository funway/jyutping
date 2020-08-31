import UIKit

extension KeyboardViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
                return 1
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return candidates.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                guard let cell: CandidateCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CandidateCell", for: indexPath) as? CandidateCollectionViewCell else {
                        return UICollectionViewCell()
                }
                cell.textLabel.text = candidates[indexPath.row].text
                cell.footnoteLabel.text = candidates[indexPath.row].footnote
                
                // works for emojis, but don't know why
                // cell.footnoteLabel.text = candidates[indexPath.row].text.first!.isLetter ? candidates[indexPath.row].footnote : nil
                
                let textColor: UIColor = isDarkAppearance ? .darkButtonText : .lightButtonText
                cell.textLabel.textColor = textColor
                cell.footnoteLabel.textColor = textColor
                return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                let candidate: Candidate = candidates[indexPath.row]
                textDocumentProxy.insertText(candidate.text)
                DispatchQueue.global().async {
                        AudioFeedback.perform(audioFeedback: .modify)
                }
                candidateSequence.append(candidate)
                currentInputText = String(currentInputText.dropFirst(candidate.input.count))
                if keyboardLayout == .candidateBoard && currentInputText.isEmpty {
                        collectionView.removeFromSuperview()
                        NSLayoutConstraint.deactivate(candidateBoardCollectionViewConstraints)
                        toolBar.reinit()
                        keyboardLayout = .jyutping
                }
                if currentInputText.isEmpty {
                        var combinedCandidate: Candidate = candidateSequence[0]
                        _ = candidateSequence.dropFirst().map { oneCandidate in
                                combinedCandidate += oneCandidate
                        }
                        candidateSequence = []
                        imeQueue.async {
                                self.lexiconManager.handle(candidate: combinedCandidate)
                        }
                }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
                // FIXME: - don't know why
                guard candidates.count > indexPath.row else { return CGSize(width: 55, height: 55) }
                
                let characterCount: Int = candidates[indexPath.row].count
                if self.keyboardLayout == .candidateBoard {
                        let fullWidth: CGFloat = collectionView.bounds.size.width
                        var itemCount: Int {
                                switch characterCount {
                                case 0:
                                        return 1
                                case 1:
                                        return Int(fullWidth) / 55
                                case 2:
                                        return Int(fullWidth) / 75
                                case 3:
                                        return Int(fullWidth) / 100
                                case 4:
                                        return Int(fullWidth) / 130
                                default:
                                        return Int(fullWidth) / (characterCount * 35)
                                }
                        }
                        guard itemCount > 1 else {
                                return CGSize(width: fullWidth - 4, height: 55)
                        }
                        return CGSize(width: fullWidth / CGFloat(itemCount), height: 55)
                } else {
                        switch characterCount {
                        case 1:
                                return CGSize(width: 55, height: 55)
                        case 2:
                                return CGSize(width: 75, height: 55)
                        case 3:
                                return CGSize(width: 110, height: 55)
                        case 4:
                                return CGSize(width: 135, height: 55)
                        default:
                                return CGSize(width: characterCount * 35, height: 55)
                        }
                }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
                return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
                return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
}
