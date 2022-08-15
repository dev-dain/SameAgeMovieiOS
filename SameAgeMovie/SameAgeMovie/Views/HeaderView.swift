//
//  HeaderView.swift
//  SameAgeMovie
//
//  Created by Dain Kim on 2022/08/05.
//

import UIKit
import SnapKit

class HeaderView: UITableViewHeaderFooterView {
    private var yearList = Array(1919...2022)
    
    // MARK: Create UI Components
    private var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "안녕하세요! 몇년생이세요?"
        label.font = .preferredFont(forTextStyle: .title3)
        return label
    }()
    
    private var yearPicker: UIPickerView = UIPickerView()
    
    private var yearTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "탭해서 골라보세요"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 5.0
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.keyboardType = .numberPad
        textField.addPadding()
        textField.addTarget(self, action: #selector(changeTextFieldValue(_:)), for: [.editingChanged, .valueChanged])
        return textField
    }()
    
    private var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("보기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        button.setTitleColor(.lightGray, for: .disabled)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(tapSubmitButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private var cautionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 14.0, weight: .semibold)
        label.isHidden = true
        return label
    }()
    
    private var vStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private var textFieldButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    // MARK: override function
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        contentView.addGestureRecognizer(tap)
    
        yearPicker.delegate = self
        yearPicker.dataSource = self
        yearTextField.inputView = yearPicker
        yearPicker.selectRow(78, inComponent: 0, animated: true)
        
        setupHeaderView()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup function
    private func setupHeaderView() {
        textFieldButtonStackView.addArrangedSubview(yearTextField)
        textFieldButtonStackView.addArrangedSubview(submitButton)
        vStackView.addArrangedSubview(welcomeLabel)
        vStackView.addArrangedSubview(textFieldButtonStackView)
        vStackView.addArrangedSubview(cautionLabel)
        contentView.addSubview(vStackView)
    }
    
    private func configureLayout() {
        welcomeLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        yearTextField.snp.makeConstraints {
            $0.width.equalTo(200.0)
        }
        textFieldButtonStackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        vStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20.0)
            $0.leading.trailing.equalToSuperview().offset(16.0)
            $0.width.equalToSuperview().offset(-32.0)
        }
    }
    
    // MARK: Selector Method
    @objc func changeTextFieldValue(_ sender: UITextField) {
        guard let year = yearTextField.text else { return }
        if year.isEmpty {
            submitButton.isEnabled = false
        } else if !submitButton.isEnabled {
            submitButton.isEnabled = true
            if !cautionLabel.isHidden {
                cautionLabel.isHidden = true
            }
        }
    }
    
    @objc func selectYear() {
        
        contentView.endEditing(true)
    }
    
    @objc func tapSubmitButton(_ sender: UIButton) {
        guard let y = yearTextField.text else { return }
        guard let year = Int(y) else {
            cautionLabel.text = "숫자만 입력해 주세요."
            cautionLabel.isHidden = false
            return
        }
        yearTextField.resignFirstResponder()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "fetchMovie"), object: year)
    }
    
    @objc func dismissKeyboard() {
        contentView.endEditing(true)
    }

}

extension HeaderView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(yearList[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        yearTextField.text = String(yearList[row])
        submitButton.isEnabled = true
    }

}
