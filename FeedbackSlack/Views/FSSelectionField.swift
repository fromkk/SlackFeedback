//
//  FSSelectionField.swift
//  SlackTest
//
//  Created by Ueoka Kazuya on 2016/08/21.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

@objc class FSSelectionField: UITextField {
    var items: [String] = [] {
        didSet {
            self.picker.reloadAllComponents()
            self.text = self.selectedValue
        }
    }
    var selectedValue: String? {
        guard self.items.count > self.picker.selectedRow(inComponent: 0) else {
            return nil
        }

        return self.items[self.picker.selectedRow(inComponent: 0)]
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selectionFieldCommonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionFieldCommonInit()
    }

    private func selectionFieldCommonInit() {
        self.inputAccessoryView = self.toolbar
        self.inputView = self.picker
    }

    override var text: String? {
        didSet {
            guard let text = self.text else {
                return
            }

            guard text != self.selectedValue else {
                return
            }

            if let index: Int = self.items.firstIndex(of: text) {
                self.picker.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }

    lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "close", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.closeButtonDidTapped(_:)))
    }()

    lazy var toolbar: UIToolbar = {
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 44.0))
        toolbar.setItems([spacer, self.closeButton], animated: false)
        return toolbar
    }()

    lazy var picker: UIPickerView = {
        let result: UIPickerView = UIPickerView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 216.0))
        result.delegate = self
        result.dataSource = self
        return result
    }()

    @objc func closeButtonDidTapped(_ button: UIBarButtonItem) {
        self.resignFirstResponder()
    }
}

extension FSSelectionField: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.items.count
    }
}

extension FSSelectionField: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard self.items.count > row else {
            return nil
        }
        return self.items[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard self.items.count > row else {
            self.text = nil
            return
        }

        if row > self.items.count {
            self.text = nil
            return
        }

        let value: String = self.items[row]
        self.text = value
    }
}
