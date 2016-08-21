//
//  FSSelectionField.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

@objc class FSSelectionField: UITextField, FSTextInput {
    var items: [String] = [] {
        didSet {
            self.picker.reloadAllComponents()
        }
    }
    var selectedValue: String? {
        guard self.items.count > self.picker.selectedRowInComponent(0) else {
            return nil
        }
        
        return self.items[self.picker.selectedRowInComponent(0)]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.inputAccessoryView = self.toolbar
        self.inputView = self.picker
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.inputAccessoryView = self.toolbar
        self.inputView = self.picker
    }
    
    lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "close", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.closeButtonDidTapped(_:)))
    }()
    
    lazy var toolbar: UIToolbar = {
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 44.0))
        toolbar.setItems([spacer, self.closeButton], animated: false)
        return toolbar
    }()
    
    lazy var picker: UIPickerView = {
        let result: UIPickerView = UIPickerView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.size.width, height: 216.0))
        result.delegate = self
        result.dataSource = self
        return result
    }()
    
    func closeButtonDidTapped(button: UIBarButtonItem) {
        self.resignFirstResponder()
    }
}

extension FSSelectionField: UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.items.count
    }
}

extension FSSelectionField: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard self.items.count > row else {
            return nil
        }
        return self.items[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard self.items.count > row else {
            self.text = nil
            return
        }
        
        guard let value: String = self.items[row] else {
            self.text = nil
            return
        }
        
        self.text = value
    }
}