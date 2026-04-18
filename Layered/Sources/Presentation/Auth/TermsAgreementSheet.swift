import SwiftUI
import SafariServices

struct TermsAgreementSheet: View {
    let onConfirm: (_ marketingConsent: Bool) -> Void
    let onCancel: () -> Void

    @State private var agreeAge = false
    @State private var agreeTerms = false
    @State private var agreePrivacy = false
    @State private var agreeMarketing = false

    @State private var viewingURL: URL?

    private var allChecked: Bool {
        agreeAge && agreeTerms && agreePrivacy && agreeMarketing
    }

    private var canProceed: Bool {
        agreeAge && agreeTerms && agreePrivacy
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 핸들 + 취소 버튼
            ZStack {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 5)

                HStack {
                    Spacer()
                    Button {
                        Haptic.light()
                        onCancel()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(.top, 8)

            // MARK: - 타이틀
            VStack(alignment: .leading, spacing: 6) {
                Text("서비스 이용 동의")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("겹겹 서비스 이용을 위해\n아래 항목에 동의해주세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)

            // MARK: - 전체 동의
            allAgreeRow
                .padding(.horizontal, 20)

            Divider()
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            // MARK: - 개별 항목
            VStack(spacing: 12) {
                checkRow(
                    checked: $agreeAge,
                    required: true,
                    title: "만 14세 이상입니다",
                    url: nil
                )
                checkRow(
                    checked: $agreeTerms,
                    required: true,
                    title: "이용약관 동의",
                    url: AppConstants.Legal.termsURL
                )
                checkRow(
                    checked: $agreePrivacy,
                    required: true,
                    title: "개인정보 처리방침 동의",
                    url: AppConstants.Legal.privacyURL
                )
                checkRow(
                    checked: $agreeMarketing,
                    required: false,
                    title: "마케팅 정보 수신 동의",
                    url: AppConstants.Legal.marketingURL
                )
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 24)

            // MARK: - 완료 버튼
            Button {
                Haptic.medium()
                onConfirm(agreeMarketing)
            } label: {
                Text("완료")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle(isEnabled: canProceed))
            .disabled(!canProceed)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .sheet(item: Binding(
            get: { viewingURL.map { URLItem(url: $0) } },
            set: { viewingURL = $0?.url }
        )) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
        .interactiveDismissDisabled(false)
    }

    // MARK: - Subviews

    private var allAgreeRow: some View {
        Button {
            Haptic.light()
            let next = !allChecked
            agreeAge = next
            agreeTerms = next
            agreePrivacy = next
            agreeMarketing = next
        } label: {
            HStack(spacing: 12) {
                Image(systemName: allChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(allChecked ? AppColors.primary : Color(.systemGray3))

                Text("전체 동의")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(16)
            .background(AppColors.primarySubtle)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func checkRow(
        checked: Binding<Bool>,
        required: Bool,
        title: String,
        url: URL?
    ) -> some View {
        HStack(spacing: 10) {
            Button {
                Haptic.light()
                checked.wrappedValue.toggle()
            } label: {
                Image(systemName: checked.wrappedValue ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(checked.wrappedValue ? AppColors.primary : Color(.systemGray3))
            }
            .buttonStyle(.plain)

            Text(required ? "(필수) " : "(선택) ")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(required ? .primary : .secondary)
            + Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()

            if let url {
                Button {
                    Haptic.light()
                    viewingURL = url
                } label: {
                    Text("보기")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .underline()
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            checked.wrappedValue.toggle()
        }
    }
}

private struct URLItem: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

// MARK: - Safari wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    Color.black
        .sheet(isPresented: .constant(true)) {
            TermsAgreementSheet(onConfirm: { _ in }, onCancel: {})
                .presentationDetents([.large])
        }
}
