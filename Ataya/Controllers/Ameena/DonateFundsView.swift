import SwiftUI

struct DonateFundsView: View {
    
    // MARK: - States
    @State private var amount: Int = 10
    @State private var selectedNGO: String = "Hoppal"
    @State private var selectedPayment: String = "Visa"
    
    let ngos = ["Hoppal", "Al Rahma", "Al Rayheen"]
    
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Amount
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter Amount")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Stepper(value: $amount, in: 1...100) {
                    Text("\(amount) BD")
                        .font(.headline)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // MARK: - NGO Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("NGO Name")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Picker("Select NGO", selection: $selectedNGO) {
                    ForEach(ngos, id: \.self) { ngo in
                        Text(ngo)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            // MARK: - Payment Methods
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Payment Method")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                PaymentOptionView(
                    title: "Visa •••• 8970",
                    subtitle: "Expires: 12/26",
                    isSelected: selectedPayment == "Visa"
                ) {
                    selectedPayment = "Visa"
                }
                
                PaymentOptionView(
                    title: "Apple Pay",
                    subtitle: "",
                    isSelected: selectedPayment == "ApplePay"
                ) {
                    selectedPayment = "ApplePay"
                }
            }
            
            Spacer()
            
            // MARK: - Confirm Button
            Button(action: {
                print("Confirm tapped")
            }) {
                Text("Confirm")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(14)
            }
        }
        .padding()
        .navigationTitle("Donate")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DonateFundsView()
    }
}
struct PaymentOptionView: View {
    
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .fontWeight(.medium)
                    
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.yellow : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
