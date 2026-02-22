//
//  Localization.swift
//  SpendMate
//
//  Created by Berkay Dereci on 31.01.2026.
//

import Foundation
import SwiftUI

struct LocalizedString {
    private static let languageKey = "appLanguage"
    
    static var isTurkish: Bool {
        // Widget extension için UserDefaults'tan direkt oku
        // Ana uygulama için AppSettings kullanılabilir ama widget extension'da çalışmaz
        if let language = UserDefaults.standard.string(forKey: languageKey) {
            return language == "tr"
        }
        // Varsayılan: İngilizce
        return false
    }
    
    // MARK: - Common
    static var save: String { isTurkish ? "Kaydet" : "Save" }
    static var cancel: String { isTurkish ? "İptal" : "Cancel" }
    static var delete: String { isTurkish ? "Sil" : "Delete" }
    static var all: String { isTurkish ? "Tümü" : "All" }
    static var today: String { isTurkish ? "Bugün" : "Today" }
    static var yesterday: String { isTurkish ? "Dün" : "Yesterday" }
    static var error: String { isTurkish ? "Hata" : "Error" }
    static var ok: String { isTurkish ? "Tamam" : "OK" }
    static var yes: String { isTurkish ? "Evet" : "Yes" }
    static var no: String { isTurkish ? "Hayır" : "No" }
    
    // MARK: - Delete Confirmation
    static var deleteConfirmationMessage: String {
        isTurkish ? "Bu işlemi silmek istediğinize emin misiniz? Bu işlem geri alınamaz." : "Are you sure you want to delete this transaction? This action cannot be undone."
    }
    static var deleteConfirmationTitle: String {
        isTurkish ? "İşlemi Sil" : "Delete Transaction"
    }
    
    // MARK: - Period Types
    static var weekly: String { isTurkish ? "Haftalık" : "Weekly" }
    static var monthly: String { isTurkish ? "Aylık" : "Monthly" }
    static var dateRange: String { isTurkish ? "Tarih Aralığı" : "Date Range" }
    
    // MARK: - Filter Card
    static var period: String { isTurkish ? "Periyot" : "Period" }
    static var startDate: String { isTurkish ? "Başlangıç Tarihi" : "Start Date" }
    static var endDate: String { isTurkish ? "Bitiş Tarihi" : "End Date" }
    static var date: String { isTurkish ? "Tarih" : "Date" }
    static var monthSelection: String { isTurkish ? "Ay Seçimi" : "Month Selection" }
    static var year: String { isTurkish ? "Yıl" : "Year" }
    static var allYear: String { isTurkish ? "Tüm Yıl" : "All Year" }
    static var allCategories: String { isTurkish ? "Tüm Kategoriler" : "All Categories" }
    static var categories: String { isTurkish ? "Kategoriler" : "Categories" }
    
    // MARK: - Expense Form
    static var amount: String { isTurkish ? "Tutar" : "Amount" }
    static var category: String { isTurkish ? "Kategori" : "Category" }
    static var note: String { isTurkish ? "Not" : "Note" }
    static var optionalNote: String { isTurkish ? "Opsiyonel not" : "Optional note" }
    static var amountMustBeGreaterThanZero: String {
        isTurkish ? "Tutar 0'dan büyük olmalıdır" : "Amount must be greater than zero"
    }
    static var enterValidAmount: String {
        isTurkish ? "Geçerli bir tutar giriniz" : "Please enter a valid amount"
    }
    static var errorSaving: String {
        isTurkish ? "Kayıt sırasında hata oluştu" : "An error occurred while saving"
    }
    
    // MARK: - Content View
    static var noTransactionsInPeriod: String {
        isTurkish ? "Bu dönemde işlem yok" : "No transactions in this period"
    }
    static var pressPlusToAdd: String {
        isTurkish ? "Yeni işlem eklemek için + butonuna basın" : "Press the + button to add a new transaction"
    }
    
    // MARK: - Export
    static var export: String { isTurkish ? "Export" : "Export" }
    static var report: String { isTurkish ? "Rapor" : "Report" }
    static var exportReport: String { isTurkish ? "Raporu Dışarı Aktar" : "Export Report" }
    static var preparing: String { isTurkish ? "Hazırlanıyor..." : "Preparing..." }
    static var csvDescription: String {
        isTurkish ? "Excel ve diğer tablo uygulamalarında açılabilir basit CSV formatı" : "Simple CSV format that can be opened in Excel and other spreadsheet applications"
    }
    static var pdfDescription: String {
        isTurkish ? "Tam rapor: Liste, özet ve kategori dağılımı içeren PDF dosyası" : "Full report: PDF file containing list, summary and category distribution"
    }
    
    // MARK: - Export Service
    static var dateColumn: String { isTurkish ? "Tarih" : "Date" }
    static var categoryColumn: String { isTurkish ? "Kategori" : "Category" }
    static var amountColumn: String { isTurkish ? "Tutar" : "Amount" }
    static var noteColumn: String { isTurkish ? "Not" : "Note" }
    static var total: String { isTurkish ? "Toplam" : "Total" }
    static var transactionCount: String { isTurkish ? "İşlem Sayısı" : "Transaction Count" }
    static var dailyAverage: String { isTurkish ? "Günlük Ortalama" : "Daily Average" }
    static var dateRangeLabel: String { isTurkish ? "Tarih Aralığı" : "Date Range" }
    static var reportTitle: String { isTurkish ? "SpendMate - İşlem Raporu" : "SpendMate - Transaction Report" }
    static var summary: String { isTurkish ? "Özet" : "Summary" }
    static var categoryDistribution: String { isTurkish ? "Kategori Dağılımı" : "Category Distribution" }
    static var transactionList: String { isTurkish ? "İşlem Listesi" : "Transaction List" }
    static var percentage: String { isTurkish ? "Yüzde" : "Percentage" }
    
    // MARK: - Main Tab View
    static var home: String { isTurkish ? "Anasayfa" : "Home" }
    static var analysis: String { isTurkish ? "Analiz" : "Analysis" }
    
    // MARK: - Notifications
    static var monthlySummaryTitle: String {
        isTurkish ? "Aylık İşlem Özeti" : "Monthly Transaction Summary"
    }
    static var monthlySummaryBody: String {
        isTurkish ? "Aylık işlem özetiniz hazır. Detayları görmek için tıklayın." : "Your monthly transaction summary is ready. Tap to view details."
    }
    static var weeklySummaryTitle: String {
        isTurkish ? "Haftalık İşlem Özeti" : "Weekly Transaction Summary"
    }
    static var weeklySummaryBody: String {
        isTurkish ? "Yeni bir hafta başladı! Bir önceki haftanın raporunu görüntülemek için tıklayın." : "A new week has started! Tap to view the previous week's report."
    }
    
    // MARK: - Add Transaction View
    static var addExpense: String { isTurkish ? "Gider Ekle" : "Add Expense" }
    static var addIncome: String { isTurkish ? "Gelir Ekle" : "Add Income" }
    
    // MARK: - Summary Card
    static var income: String { isTurkish ? "Gelir" : "Income" }
    static var expense: String { isTurkish ? "Gider" : "Expense" }
    static var netBalance: String { isTurkish ? "Net Tutar" : "Net Balance" }
    static var transaction: String { isTurkish ? "işlem" : "transaction" }
    static var noTransactionsYet: String { isTurkish ? "Henüz işlem yok" : "No transactions yet" }
    
    // MARK: - Settings
    static var settings: String { isTurkish ? "Ayarlar" : "Settings" }
    static var language: String { isTurkish ? "Dil" : "Language" }
    static var currency: String { isTurkish ? "Para Birimi" : "Currency" }
    static var appearance: String { isTurkish ? "Görünüm" : "Appearance" }
    static var turkish: String { isTurkish ? "Türkçe" : "Turkish" }
    static var english: String { isTurkish ? "İngilizce" : "English" }
    static var turkishLira: String { isTurkish ? "Türk Lirası (₺)" : "Turkish Lira (₺)" }
    static var usDollar: String { isTurkish ? "ABD Doları ($)" : "US Dollar ($)" }
    static var euro: String { isTurkish ? "Euro (€)" : "Euro (€)" }
    static var darkMode: String { isTurkish ? "Karanlık" : "Dark" }
    static var lightMode: String { isTurkish ? "Aydınlık" : "Light" }
    static var systemMode: String { isTurkish ? "Sistem" : "System" }
    
    // MARK: - Export Sheet
    static var selectFormat: String { isTurkish ? "Format Seçin" : "Select Format" }
    
    // MARK: - Add Transaction View
    static var transactionType: String { isTurkish ? "İşlem Tipi" : "Transaction Type" }
    
    // MARK: - Analysis View
    static var transactionTrend: String { isTurkish ? "İşlem Trendi" : "Transaction Trend" }
    static var noDataToDisplay: String { isTurkish ? "Gösterilecek veri yok" : "No data to display" }
    static var noDataForSelectedCategories: String { isTurkish ? "Seçili kategorilerde bu periyot için veri bulunmamaktadır" : "No data available for selected categories in this period" }
    static var categoryTrends: String { isTurkish ? "Kategori Trendleri" : "Category Trends" }
    static var noTrendData: String { isTurkish ? "Trend verisi yok" : "No trend data" }
}

