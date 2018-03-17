//
//  ViewController.swift
//  sample-audio-player
//
//  Created by 知野雄二 on 2018/03/11.
//  Copyright © 2018年 知野雄二. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController,
MPMediaPickerControllerDelegate {

    var audioPlayer:AVAudioPlayer!

    @IBOutlet weak var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //*************************************
        // コントロールセンターに表示
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            // コントロールセンターで一時停止時
            if let player = self.audioPlayer {
                player.pause()
            }
            return .success
        }
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            // コントロールセンターで再生時
            if let player = self.audioPlayer {
                player.play()
            }
            return .success
        }
        //*************************************
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // メッセージラベルのテキストをクリア
        messageLabel.text = ""
    }

    @IBAction func pick(sender: AnyObject) {
        // MPMediaPickerControllerのインスタンスを作成
        let picker = MPMediaPickerController()
        // ピッカーのデリゲートを設定
        picker.delegate = self
        // 複数選択を不可にする。（trueにすると、複数選択できる）
        picker.allowsPickingMultipleItems = false
        // ピッカーを表示する
        present(picker, animated: true, completion: nil)
    }

    // メディアアイテムピッカーでアイテムを選択完了したときに呼び出される
    func mediaPicker(_ mediaPicker: MPMediaPickerController,didPickMediaItems mediaItemCollection: MPMediaItemCollection){
        
        // このfunctionを抜ける際にピッカーを閉じ、破棄する
        // (defer文はfunctionを抜ける際に実行される)
        defer {
            dismiss(animated: true, completion: nil)
        }

        // 選択した曲情報がmediaItemCollectionに入っている
        // mediaItemCollection.itemsから入っているMPMediaItemの配列を取得できる
        let items = mediaItemCollection.items
        if items.isEmpty {
            // itemが一つもなかったので戻る
            return
        }
        
        // 先頭のMPMediaItemを取得し、そのassetURLからプレイヤーを作成する
        let item = items[0]
        if let url = item.assetURL {
            do {
                // itemのassetURLからプレイヤーを作成する
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch  {
                // エラー発生してプレイヤー作成失敗
                // messageLabelに失敗したことを表示
                messageLabel.text = "このurlは再生できません"
                audioPlayer = nil
                // 戻る
                return
            }

            //*************************************
            //*** バックグラウンドでの再生を有効にする ***
            let session = AVAudioSession.sharedInstance()
            
            //ロック時も再生のカテゴリを指定
            do {
                try session.setCategory(AVAudioSessionCategoryPlayback)
            }
            catch let error as NSError {
                print(error.description)
            }
            
            do {
                //オーディオセッションを有効化
                try session.setActive(true)
            }
            catch let error as NSError {
                print(error.description)
            }
            //*************************************

            // 再生開始
            if let player = audioPlayer {
                player.play()
                
                // メッセージラベルに曲タイトルを表示
                // (MPMediaItemが曲情報を持っているのでそこから取得)
                let title = item.title ?? ""
                messageLabel.text = title
                
            }

        } else {
            // messageLabelに失敗したことを表示
            messageLabel.text = "アイテムのurlがnilなので再生できません"
            
            audioPlayer = nil
        }
        
    }

    //選択がキャンセルされた場合に呼ばれる
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
        print("mediaPickerDidCancel")
        // ピッカーを閉じ、破棄する
        dismiss(animated: true, completion: nil)
    }

    @IBAction func pushPlay(sender: AnyObject) {
        // 再生
        if let player = audioPlayer {
            player.play()
        }
    }

    @IBAction func pushPause(sender: AnyObject) {
        // 一時停止
        if let player = audioPlayer {
            player.pause()
        }
    }

    @IBAction func pushStop(sender: AnyObject) {
        // 停止
        if let player = audioPlayer {
            player.stop()
        }
    }

}

