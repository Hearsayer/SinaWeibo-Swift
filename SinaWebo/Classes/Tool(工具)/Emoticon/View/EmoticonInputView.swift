//
//  EmoticonInputView.swift
//  keyboard
//
//  Created by Hearsay on 2017/1/24.
//  Copyright © 2017年 Hearsay. All rights reserved.
//

import UIKit

private let cellId = "cellId"

/// 表情键盘
class EmoticonInputView: UIView {
    
    /// 表情视图
    @IBOutlet weak var collectionView: UICollectionView!

    /// 底部工具栏
    @IBOutlet weak var toolBar: EmoticonToolBar!
    
    /// 分页控件
    @IBOutlet weak var pageControl: UIPageControl!
    
    fileprivate var selectedEmotion: ((_ emotion: Emoticon?)->())?
    
    class func inputView(selectedEmotion: @escaping (_ emotion: Emoticon?)->()) -> EmoticonInputView {
        
        let nib = UINib(nibName: "EmoticonInputView", bundle: nil)
        
        let v = nib.instantiate(withOwner: nil, options: nil).first as! EmoticonInputView
        
        v.selectedEmotion = selectedEmotion
        
        return v
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        toolBar.delegate = self
        collectionView.register(EmoticonCell.self, forCellWithReuseIdentifier: cellId)
    }
}

extension EmoticonInputView: EmoticonToolBarDalegate {
    
    func emoticonToolBar(_ toolBar: EmoticonToolBar, didSelectedIndex index: Int) {
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension EmoticonInputView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return EmoticonManager.manager.emotiPackages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmoticonManager.manager.emotiPackages[section].numberOfPage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EmoticonCell
        cell.emoticons = EmoticonManager.manager.emotiPackages[indexPath.section].emoticon(page: indexPath.item)
        cell.delegate = self
        return cell
    }
}

extension EmoticonInputView: EmoticonCellDelegate {
    
    func emoticonCell(_ cell: EmoticonCell, didSelectedEmotion emoticon: Emoticon?) {
        selectedEmotion?(emoticon)
        
        if emoticon != nil && collectionView.indexPathsForVisibleItems[0].section != 0 {
            
            // 添加到最近表情页
            EmoticonManager.manager.recentEmoticon(em: emoticon!)
            // 刷新最近表情页
            var indexSet = IndexSet()
            indexSet.insert(0)
            collectionView.reloadSections(indexSet)
        }
    }
}
