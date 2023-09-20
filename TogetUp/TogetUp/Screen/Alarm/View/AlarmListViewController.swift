//
//  ViewController.swift
//  TogetUp
//
//  Created by 이예원 on 2023/08/14.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import RealmSwift

class AlarmListViewController: UIViewController {
    // MARK: - UI Components
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var groupView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addAlarmButton: UIButton!
    
    let realm = try! Realm()
    
    // MARK: - Properties
    private let viewModel = AlarmListViewModel()
    private let disposeBag = DisposeBag()
    private lazy var leadingDistance: NSLayoutConstraint = {
        return underLineView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor)
    }()
    private lazy var underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "primary300")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAndSaveAlarmsIfFirstLaunch()
        setUpNavigationBar()
        customSegmentedControl()
        setCollectionViewFlowLayout()
        self.groupView.layer.cornerRadius = 12
//                try! realm.write {
//                    let alarms = realm.objects(Alarm.self)
//                    realm.delete(alarms)
//                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchAlarmsFromRealm()
        setCollectionView()
    }
    
    // MARK: - Custom Method
    private func setCollectionView() {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
        viewModel.alarms.bind(to: collectionView.rx.items(cellIdentifier: AlarmListCollectionViewCell.identifier, cellType: AlarmListCollectionViewCell.self)) { index, alarm, cell in
            cell.setAttributes(with: alarm)
        }
        .disposed(by: disposeBag)
    }
    
    private func fetchAndSaveAlarmsIfFirstLaunch() {
        print("fetchAndSaveAlarmsIfFirstLaunch if AppStatusManager.shared.isFirstLaunch: \(AppStatusManager.shared.isFirstLaunch)")
        if AppStatusManager.shared.isFirstLaunch {
            viewModel.getAndSaveAlarmList(type: "personal")
            AppStatusManager.shared.markAsLaunched()
        }
    }
    
    private func setCollectionViewFlowLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: 124)
        layout.minimumLineSpacing = 16
        collectionView.collectionViewLayout = layout
    }
        
    private func setUpNavigationBar() {
        let titleLabel = UILabel()
        titleLabel.textColor = UIColor.black
        titleLabel.text = "알람"
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 26)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
    private func customSegmentedControl() {
        segmentedControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segmentedControl.setDividerImage(UIImage(), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "neutral400")!,
            NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)!
        ], for: .normal)
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)!
        ], for: .selected)
        
        // 오토레이아웃
        self.view.addSubview(underLineView)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        underLineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            underLineView.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            underLineView.heightAnchor.constraint(equalToConstant: 2),
            leadingDistance,
            underLineView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments))
        ])
    }
    
    // MARK: - @
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let sheet = UIAlertController(title: "알람 삭제", message: "알람을 삭제하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            if let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first,
               let alarmToDelete = try? self.viewModel.alarms.value()[selectedIndexPath.row] {
                self.viewModel.deleteAlarm(alarmId: alarmToDelete.id)
            }
        }
        sheet.addAction(okAction)
        present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        let segmentIndex = CGFloat(sender.selectedSegmentIndex)
        let segmentWidth = sender.frame.width / CGFloat(sender.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.leadingDistance.constant = leadingDistance
            self?.view.layoutIfNeeded()
        })
        
        if sender.selectedSegmentIndex == 0 {
            self.groupView.isHidden = true
            self.collectionView.isHidden = false
            self.addAlarmButton.isHidden = false
        } else {
            self.groupView.isHidden = false
            self.collectionView.isHidden = true
            self.addAlarmButton.isHidden = true
        }
    }
    
    @IBAction func createAlarmBtnTapped(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "CreateAlarmViewController") as? CreateAlarmViewController else { return }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.isNavigationBarHidden = true
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
        
        present(navigationController, animated: true)
    }
}
