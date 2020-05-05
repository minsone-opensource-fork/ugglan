//
//  FreeTextChat.swift
//  project
//
//  Created by Gustaf Gunér on 2019-05-22.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct FreeTextChat {
    @Inject var client: ApolloClient
}

extension FreeTextChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let chat = Chat()
        let (viewController, future) = chat.materialize()

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        bag += client.perform(mutation: TriggerFreeTextChatMutation()).onValue { _ in
            chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
                chat.chatState.subscribe()
            }
        }

        return (viewController, Future { completion in
            bag += future.onResult { result in
                completion(result)
            }

            return Disposer {
                future.cancel()
                bag.dispose()
            }
        })
    }
}