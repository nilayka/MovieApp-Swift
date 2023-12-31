//
//  DetailsVC.swift
//  MovieApp
//
//  Created by Nilay KADİROĞULLARI on 23.07.2023.
//

import UIKit
import AVKit


class DetailsViewController: UIViewController {
    
    var movie: Movie?
    var videoURL: URL?
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    @IBOutlet weak var popularityLabel: UILabel!
    
    @IBOutlet weak var movieSubTitle: UILabel!
    var defaults = UserDefaults.standard
    
    var isHeartFilled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isHeartFilled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isHeartFilled")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TapGesture()
        bind()
        heartImageView.image = UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal)
        setFillHeartImage()
        
        if let videoURL = videoURL {
            playVideo(url: videoURL)
        }
    }
    
    func bind() {
        movieTitleLabel.text = movie?.title
        descriptionLabel.text = movie?.overview
        movieImageView.sd_setImage(with: URL(string: "\(baseImageUrl)\(movie?.poster_path ?? "")"), placeholderImage: nil)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: movie?.release_date ?? "")
        dateFormatter.dateFormat = "d MMM EEEE yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        let resultString = dateFormatter.string(from: date!)
        movieSubTitle.text = resultString
        
        popularityLabel.text = "(\(movie?.original_language ?? ""))"
        voteLabel.attributedText = displayColoredRating()
        
        guard let defaultsFavorite = (self.defaults.object(forKey: "favoriteList") as? Data),
              let favoriteList = try? JSONDecoder().decode([Movie].self, from: defaultsFavorite) else { return }
        
        self.isHeartFilled = (favoriteList.first(where: { $0.id == self.movie?.id}) != nil)
    }
    
    private func TapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(heartImageViewTapped))
        heartImageView.addGestureRecognizer(tapGesture)
        heartImageView.isUserInteractionEnabled = true
    }
    
    @objc private func heartImageViewTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.heartImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { _ in
            
                self.setFavorite(movie: self.movie)

            UIView.animate(withDuration: 0.2) {
                self.heartImageView.transform = .identity
            }
        }
    }
    
    func setFavorite(movie: Movie?) {
        
        if let defaultFavoriteList = (defaults.object(forKey: "favoriteList") as? Data),  let favoriteList = try? JSONDecoder().decode([Movie].self, from: defaultFavoriteList){
            
            if !favoriteList.isEmpty {
                if isHeartFilled {
                    var newFavoriteList = favoriteList
                    if let movie = self.movie {
                        newFavoriteList.removeAll(where: { $0.id == movie.id})
                        self.defaults.set(try? JSONEncoder().encode(newFavoriteList), forKey: "favoriteList")
                        heartImageView.image = UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal)
                        isHeartFilled = false
                    }
                } else {
                    var newFavoriteList = favoriteList
                    if let movie = self.movie {
                        newFavoriteList.append(movie)
                    }
                    self.defaults.set(try? JSONEncoder().encode(newFavoriteList), forKey: "favoriteList")
                    heartImageView.image = UIImage(named: "heart.fill")?.withRenderingMode(.alwaysOriginal)
                    isHeartFilled = true
                }
            } else {
                self.defaults.set(try? JSONEncoder().encode([movie]), forKey: "favoriteList")
                heartImageView.image = UIImage(named: "heart.fill")?.withRenderingMode(.alwaysOriginal)
                isHeartFilled = true
            }

        } else {
            self.defaults.set(try? JSONEncoder().encode([movie]), forKey: "favoriteList")
            heartImageView.image = UIImage(named: "heart.fill")?.withRenderingMode(.alwaysOriginal)
            isHeartFilled = true
        }
    }
    
    private func changeHeartImage() {
        if isHeartFilled {
            heartImageView.image = UIImage(named: "heart.fill")?.withRenderingMode(.alwaysOriginal)
        } else {
            heartImageView.image = UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal)
        }
    }
    func setFillHeartImage() {
        if let defaultFavoriteList = (defaults.object(forKey: "favoriteList") as? Data),  let favoriteList = try? JSONDecoder().decode([Movie].self, from: defaultFavoriteList){
            
            if !favoriteList.isEmpty {
                for favoriMovie in favoriteList {
                    if favoriMovie.id == self.movie?.id {
                        heartImageView.image = UIImage(named: "heart.fill")?.withRenderingMode(.alwaysOriginal)
                        isHeartFilled = true
                    }
                }
            } else {
                heartImageView.image = UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal)
                isHeartFilled = false
            }

        } else {
            heartImageView.image = UIImage(named: "heart")?.withRenderingMode(.alwaysOriginal)
            isHeartFilled = false
        }
    }
    
    
    func playVideo(url: URL) {
        player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        
        if let playerViewController = playerViewController {
            addChild(playerViewController)
            playerViewController.view.frame = videoView.bounds
            videoView.addSubview(playerViewController.view)
            playerViewController.didMove(toParent: self)
            
            player?.play()
        }
    }
}

extension DetailsViewController {
    func displayColoredRating() -> NSAttributedString {
        let imdbPoint = String(format: "%.1f", movie?.vote_average ?? 0)
        if movie?.vote_average ?? 0.0 < 6.8 {
            voteLabel.textColor = .red
        } else if movie?.vote_average ?? 6.8 < 8.0 {
            voteLabel.textColor =  .orange
        } else {
            voteLabel.textColor = .green
        }
        return NSAttributedString(string: "imdb: \(imdbPoint)")
    }
}
