//
//  KeyGearItem.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-27.
//

import Apollo
import Flow
import Form
import Foundation
import Presentation
import UIKit

struct KeyGearItem {
    let id: String
    @Inject var client: ApolloClient

    func getGradientImage(gradientLayer: CAGradientLayer) -> UIImage? {
        var gradientImage: UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)

        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }

        UIGraphicsEndImageContext()

        return gradientImage
    }

    func addNavigationBar(
        scrollView _: UIScrollView,
        viewController: UIViewController
    ) -> (Disposable, UINavigationBar) {
        let bag = DisposeBag()

        let navigationBar = UINavigationBar()

        navigationBar.items = [viewController.navigationItem]

        navigationBar.tintColor = UIColor.clear
        navigationBar.barTintColor = UIColor.clear
        navigationBar.backIndicatorImage = Asset.backButtonWhite.image
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBar.barStyle = .blackTranslucent
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.setBackgroundImage(UIImage(), for: .compact)

        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        gradient.locations = [0, 1]

        let gradientView = UIView()
        gradientView.layer.addSublayer(gradient)
        viewController.view.addSubview(gradientView)

        bag += gradientView.didLayoutSignal.onValue { _ in
            gradient.frame = gradientView.frame

            gradientView.snp.makeConstraints { make in
                make.height.equalTo(navigationBar).offset(gradientView.safeAreaInsets.top)
                make.trailing.leading.equalToSuperview()
            }
        }

        viewController.view.addSubview(navigationBar)

        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(viewController.view.safeAreaLayoutGuide.snp.top)
            make.trailing.equalTo(viewController.view.safeAreaLayoutGuide.snp.trailing)
            make.leading.equalTo(viewController.view.safeAreaLayoutGuide.snp.leading)
        }

        return (bag, navigationBar)
    }

    class KeyGearItemViewController: UIViewController {
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }

        init() {
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewWillAppear(_ animated: Bool) {
            navigationController?.setNavigationBarHidden(true, animated: animated)
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }
}

extension KeyGearItem: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let viewController = KeyGearItemViewController()

        viewController.navigationItem.title = "TODO"

        let optionsButton = UIBarButtonItem()
        optionsButton.tintColor = .white
        optionsButton.image = Asset.menuIcon.image

        viewController.navigationItem.rightBarButtonItem = optionsButton

        let backButton = UIButton(type: .custom)
        backButton.setImage(Asset.backButtonWhite.image, for: .normal)
        backButton.tintColor = .white

        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(button: backButton)

        let view = UIView()
        view.backgroundColor = .primaryBackground
        viewController.view = view

        let dataSignal = client.watch(query: KeyGearItemQuery(id: id)).compactMap { $0.data?.keyGearItem }

        bag += dataSignal.onValue { data in
            print(data)
        }

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.backgroundColor = .primaryBackground

        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        bag += scrollView.scrollToRevealFirstResponder { view -> UIEdgeInsets in
            let rowInsets = alignToRow(view)

            return UIEdgeInsets(
                top: rowInsets.top,
                left: rowInsets.left,
                bottom: rowInsets.bottom - 20,
                right: rowInsets.right
            )
        }
        bag += scrollView.adjustInsetsForKeyboard()

        let form = FormView()

        bag += form.didLayoutSignal.take(first: 1).onValue { _ in
            form.dynamicStyle = DynamicFormStyle.default.restyled { (style: inout FormStyle) in
                style.insets = UIEdgeInsets(top: -scrollView.safeAreaInsets.top, left: 0, bottom: 20, right: 0)
            }
        }

        scrollView.embedView(form, scrollAxis: .vertical)

        let imagesSignal = dataSignal.map { $0.photos.compactMap { $0.file.preSignedUrl } }.compactMap { $0.compactMap { URL(string: $0) } }.readable(initial: [])

        bag += form.prepend(KeyGearImageCarousel(imagesSignal: imagesSignal)) { imageCarouselView in

            bag += scrollView.contentOffsetSignal.onValue { offset in
                let realOffset = offset.y + scrollView.safeAreaInsets.top

                if realOffset < 0 {
                    imageCarouselView.transform = CGAffineTransform(
                        translationX: 0,
                        y: realOffset * 0.5
                    ).concatenating(
                        CGAffineTransform(
                            scaleX: 1 + abs(realOffset / imageCarouselView.frame.height),
                            y: 1 + abs(realOffset / imageCarouselView.frame.height)
                        )
                    )
                } else {
                    imageCarouselView.transform = CGAffineTransform(
                        translationX: 0,
                        y: realOffset * 0.5
                    )
                }
            }
        }

        let formContainer = UIView()
        formContainer.backgroundColor = .primaryBackground
        form.append(formContainer)

        let innerForm = FormView()
        formContainer.addSubview(innerForm)

        innerForm.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        bag += innerForm.append(KeyGearItemHeader(presentingViewController: viewController))

        bag += innerForm.append(Spacing(height: 10))

        let coveragesSection = innerForm.appendSection(header: String(key: .KEY_GEAR_ITEM_VIEW_COVERAGE_TABLE_TITLE))
        coveragesSection.dynamicStyle = .sectionPlain

        bag += coveragesSection.append(KeyGearCoverage())

        bag += innerForm.append(Spacing(height: 15))

        let nonCoveragesSection = innerForm.appendSection(header: String(key: .KEY_GEAR_ITEM_VIEW_NON_COVERAGE_TABLE_TITLE))
        nonCoveragesSection.dynamicStyle = .sectionPlain

        bag += nonCoveragesSection.append(KeyGearCoverage())

        bag += innerForm.append(Spacing(height: 30))

        let nameSection = innerForm.appendSection()
        nameSection.dynamicStyle = .sectionPlain

        bag += nameSection.append(EditableRow(valueSignal: .static("Namn"), placeholderSignal: .static("Namn"))).onValue { _ in
            print("was saved")
        }

        let (navigationBarBag, navigationBar) = addNavigationBar(
            scrollView: scrollView,
            viewController: viewController
        )
        bag += navigationBarBag

        bag += navigationBar.didLayoutSignal.onValue { _ in
            scrollView.scrollIndicatorInsets = UIEdgeInsets(
                top: navigationBar.frame.height,
                left: 0,
                bottom: 0,
                right: 0
            )
        }

        return (viewController, Future { completion in
            bag += optionsButton.onValue {
                viewController.present(Alert(actions: [
                    Alert.Action(title: "Delete", style: .destructive, action: { _ in
                        completion(.success)
                    }),
                    Alert.Action(title: "Cancel", style: .cancel, action: { _ in

                    }),
                ]), style: .sheet())
            }

            bag += backButton.onValue { _ in
                completion(.success)
            }

            return DelayedDisposer(bag, delay: 2.0)
        })
    }
}
