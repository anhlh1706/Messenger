//
//  MonthYearPickerView.swift
//  Base
//
//  Created by Hoàng Anh on 30/07/2020.
//  Copyright © 2020 Hoàng Anh. All rights reserved.
//

import UIKit

//let datePicker = MonthYearPickerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 216))
//datePicker.addTarget(self, action: #selector(didUpdateDate(_:)), for: .valueChanged)
//field.inputView = datePicker
@IBDesignable
final class MonthYearPickerView: UIControl {
    
    /// default is current date when picker created
    var date = Date() {
        didSet {
            let newDate = calendar.startOfDay(for: date)
            setDate(newDate, animated: true)
            sendActions(for: .valueChanged)
        }
    }
    
    /// default is current calendar when picker created
    var calendar = Calendar.autoupdatingCurrent {
        didSet {
            monthDateFormatter.calendar = calendar
            monthDateFormatter.timeZone = calendar.timeZone
            yearDateFormatter.calendar = calendar
            yearDateFormatter.timeZone = calendar.timeZone
        }
    }
    
    /// default is nil
    var locale: Locale? {
        didSet {
            calendar.locale = locale
            monthDateFormatter.locale = locale
            yearDateFormatter.locale = locale
        }
    }
    
    lazy fileprivate var pickerView: UIPickerView = { // swiftlint:disable:this modifier_order
        let pickerView = UIPickerView(frame: self.bounds)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return pickerView
    }()
    
    lazy fileprivate var monthDateFormatter: DateFormatter = { // swiftlint:disable:this modifier_order
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }()
    
    lazy fileprivate var yearDateFormatter: DateFormatter = { // swiftlint:disable:this modifier_order
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("y")
        return formatter
    }()
    
    fileprivate enum Component: Int {
        case year
        case month
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) { // swiftlint:disable:this modifier_order
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        addSubview(pickerView)
        calendar.timeZone = TimeZone.current
        setDate(date, animated: false)
    }
    
    /// if animated is YES, animate the wheels of time to display the new date
    func setDate(_ date: Date, animated: Bool) {
        guard let yearRange = calendar.maximumRange(of: .year),
            let monthRange = calendar.maximumRange(of: .month) else {
            return
        }
        let month = calendar.component(.month, from: date) - monthRange.lowerBound
        pickerView.selectRow(month, inComponent: Component.month.rawValue, animated: animated)
        let year = calendar.component(.year, from: date) - yearRange.lowerBound
        pickerView.selectRow(year, inComponent: Component.year.rawValue, animated: animated)
    }
    
}

extension MonthYearPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let yearRange = calendar.maximumRange(of: .year),
            let monthRange = calendar.maximumRange(of: .month) else {
            return
        }
        var dateComponents = DateComponents()
        dateComponents.year = yearRange.lowerBound + pickerView.selectedRow(inComponent: Component.year.rawValue)
        dateComponents.month = monthRange.lowerBound + pickerView.selectedRow(inComponent: Component.month.rawValue)
        guard let date = calendar.date(from: dateComponents) else {
            return
        }
        self.date = date
    }
    
}

extension MonthYearPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard let component = Component(rawValue: component) else { return 0 }
        switch component {
        case .month:
            guard let range = calendar.maximumRange(of: .month) else {
                return 0
            }
            return range.count
        case .year:
            guard let range = calendar.maximumRange(of: .year) else {
                return 0
            }
            return range.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = Component(rawValue: component) else { return nil }
        
        switch component {
        case .month:
            guard let range = calendar.maximumRange(of: .month) else {
                return nil
            }
            let month = range.lowerBound + row
            var dateComponents = DateComponents()
            dateComponents.month = month
            guard let date = calendar.date(from: dateComponents) else {
                return nil
            }
            return monthDateFormatter.string(from: date)
        case .year:
            guard let range = calendar.maximumRange(of: .year) else {
                return nil
            }
            let year = range.lowerBound + row
            var dateComponents = DateComponents()
            dateComponents.year = year
            guard let date = calendar.date(from: dateComponents) else {
                return nil
            }
            return yearDateFormatter.string(from: date)
        }
        
    }
    
}
