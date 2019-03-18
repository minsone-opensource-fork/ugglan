//
//  Referrals.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-15.
//

import Foundation
import Presentation
import UIKit
import Flow
import Firebase
import FirebaseDynamicLinks
import FirebaseFirestore
import Apollo
import Form

enum ReferralsFailure: LocalizedError {
    case failedToCreateLink
}

struct Referrals {
    let client: ApolloClient
    
    init(
        client: ApolloClient = HedvigApolloClient.shared.client!
    ) {
        self.client = client
    }
    
    func createInvitationLink(memberId: String) -> Future<String> {
        return Future { completion in
            let remoteConfigContainer = RemoteConfigContainer()
            let incentive = remoteConfigContainer.referralsIncentive()
            
            guard let link = URL(
                string: "https://hedvig.com/referrals?memberId=\(memberId)&incentive=\(incentive)"
            ) else {
                return NilDisposer()
            }
            
            let domainUriPrefix = remoteConfigContainer.dynamicLinkDomainPrefix()
                        
            let linkBuilder = DynamicLinkComponents(
                link: link,
                domainURIPrefix: domainUriPrefix
            )
            
            linkBuilder?.iOSParameters = DynamicLinkIOSParameters(
                bundleID: remoteConfigContainer.dynamicLinkiOSBundleId()
            )
            linkBuilder?.iOSParameters?.appStoreID = remoteConfigContainer.dynamicLinkiOSAppStoreId()
            linkBuilder?.androidParameters = DynamicLinkAndroidParameters(
                packageName: remoteConfigContainer.dynamicLinkAndroidPackageName()
            )
            
            linkBuilder?.shorten { url, warnings, error in
                if error != nil {
                    completion(.failure(ReferralsFailure.failedToCreateLink))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
            
            return NilDisposer()
        }
    }
    
    func writeReferralToStore(
        invitedByMmemberId: String,
        memberId: String
    ) -> Future<Void> {
        let db = Firestore.firestore()
        
        return Future { completion in
            db.collection("referrals").addDocument(data: [
                "invitedByMemberId": invitedByMmemberId,
                "memberId": memberId
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success)
                }
            }
            
            return NilDisposer()
        }
        
    }
}

extension Referrals: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        viewController.title = String(.REFERRALS_SCREEN_TITLE)
        
        let bag = DisposeBag()
        
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .offWhite
        
        let formView = FormView()
        formView.spacing = 20
        bag += viewController.install(
            formView,
            scrollView: scrollView
        )
        
        let referralsIllustration = ReferralsIllustration()
        bag += formView.prepend(referralsIllustration) { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(300)
            }
        }
        
        let referralsTitle = ReferralsTitle()
        bag += formView.append(referralsTitle)
        
        let referralsOfferSender = ReferralsOffer(mode: .sender)
        bag += formView.append(referralsOfferSender)
        
        let referralsOfferReceiver = ReferralsOffer(mode: .receiver)
        bag += formView.append(referralsOfferReceiver)
        
        let section = SectionView(rows: [], style: .sectionPlain)
        
        let termsRow = ReferralsTermsRow(
            presentingViewController: viewController
        )
        bag += section.append(termsRow)
        
        formView.append(section)
        
        bag += formView.append(Spacing(height: 50))
        
        let linkSignal = ReadWriteSignal<String?>(nil)
        
        bag += client.fetch(query: MemberIdQuery()).valueSignal.compactMap {
            $0.data?.member.id
        }.onValue { memberId in
            bag += self.createInvitationLink(memberId: memberId).bindTo(linkSignal)
        }
        
        let button = Button(
            title: String(.REFERRALS_SHARE_BUTTON),
            type: .standard(backgroundColor: .purple, textColor: .white)
        )
        
        bag += scrollView.add(button) { buttonView in
            buttonView.snp.makeConstraints({ make in
                make.bottom.equalTo(
                    viewController.bottomLayoutGuide.snp.bottom
                ).inset(20)
                make.centerX.equalToSuperview()
            })
            
            buttonView.transform = CGAffineTransform(translationX: 0, y: 100)
            
            bag += linkSignal.compactMap { $0 }.animated(
                style: SpringAnimationStyle.heavyBounce()
            ) {
                buttonView.transform = CGAffineTransform.identity
            }
            
            bag += button.onTapSignal.withLatestFrom(
                linkSignal.plain()
            ).compactMap { $1 }.onValue { link in
                let activityView = ActivityView(
                    activityItems: [String(.REFERRALS_SHARE_MESSAGE(link: link))],
                    applicationActivities: nil,
                    sourceView: buttonView,
                    sourceRect: buttonView.bounds
                )
                
                viewController.present(activityView)
            }
            
        }
        
        return (viewController, bag)
    }
}
