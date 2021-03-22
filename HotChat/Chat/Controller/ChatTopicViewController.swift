//
//  ChatTopicViewController.swift
//  HotChat
//
//  Created by 风起兮 on 2021/3/17.
//  Copyright © 2021 风起兮. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/*
// 展示 UI 界面
msg.status = Msg_Status_Sending;
msg.name = [msg.innerMessage getShowName];
msg.avatarUrl = [NSURL URLWithString:[msg.innerMessage faceURL]];
if(dateMsg){
    _msgForDate = imMsg;
    [_uiMsgs addObject:dateMsg];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
}
[_uiMsgs addObject:msg];
[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                      withRowAnimation:UITableViewRowAnimationFade];
[self.tableView endUpdates];
[self scrollToBottom:YES];

int delay = 1;
if([msg isKindOfClass:[TUIImageMessageCellData class]]){
    delay = 0;
}
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    @strongify(self)
    if(msg.status == Msg_Status_Sending){
        [self changeMsg:msg status:Msg_Status_Sending_2];
    }
});
*/
class ChatTopicViewController: ChatViewController, UIPopoverPresentationControllerDelegate {
    
    
    
    override var inputBarHeight: CGFloat {
        return 49
    }
    
    var uiMessage: NSMutableArray?
    
    /// 全体禁言
    var allMuted: Bool = false {
        didSet {
            addOrRemoveMutedView()
        }
    }
    
    /// 自己禁言
    var selfMuted: Bool = false {
        didSet {
            addOrRemoveMutedView()
        }
    }
    
    
    lazy var mutedButton: UIButton = {
        let button = UIButton(type: .custom)
        button.isEnabled = false
        button.setTitleColor(UIColor(hexString: "#999999"), for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(hexString: "#F3F3F3")
        button.layer.cornerRadius = 5
        return button
        
    }()
    
    func addOrRemoveMutedView() {
        
        let isMuted = allMuted || selfMuted
        
        guard let textView  = inputController.inputBar.value(forKeyPath: "inputTextView") as? UITextView  else {
            return
        }
        
        
        textView.isEditable = !isMuted
        textView.isHidden = isMuted
        inputController.inputBar.isUserInteractionEnabled = !isMuted
        
        if !isMuted {
            
            if mutedButton.superview != nil {
                mutedButton.removeFromSuperview()
            }
            return
        }
        
        
        inputController.inputBar.clearInput()
        
        if allMuted {
            mutedButton.setTitle("当前修整，请留意开放时间。", for: .disabled)
        }
        else if selfMuted {
            mutedButton.setTitle("您涉及言论违规已被禁言，请联系客服。", for: .disabled)
        }
        
        mutedButton.frame = textView.frame
        
        inputController.inputBar.addSubview(mutedButton)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uiMessage =  self.messageController.value(forKeyPath: "uiMsgs") as? NSMutableArray
        
        // 第一次来
        // 文明公告：本平台提倡健康文明交友，所有涉黄、诈骗、违法法规等行为，将被系统永久封禁账号及手机设备。
        
        self.messageController.rx.observe(Bool.self, "firstLoad")
            .filter{
                $0 == false
            }
            .first()
            .subscribe({ [weak  self] firstLoad in
                self?.addSystemMessage(content: "文明公告：本平台提倡健康文明交友，所有涉黄、诈骗、违法法规等行为，将被系统永久封禁账号及手机设备。")
            })
            .disposed(by: rx.disposeBag)
        

        V2TIMManager.sharedInstance()?.getGroupsInfo([self.conversationData.groupID], succ: {[weak self] results in
            
            if let groupInfoResult = results?.first, groupInfoResult.resultCode == 0 {
                self?.allMuted = groupInfoResult.info.allMuted
                if groupInfoResult.info.allMuted {
                    self?.requestNotice()
                }
            }
            
        }, fail: { (code, desc) in
            Log.print("\(code)  \(desc)")
        })
        
        /// groupID  data
        NotificationCenter.default.rx.notification(.init("V2TIMGroupNotify_onReceiveRESTCustomData"))
            .subscribe(onNext: { [weak self] notification in
                self?.handle(notification)
            })
            .disposed(by: rx.disposeBag)
        
        requestMutedStatus()
        
    }
    
    
    let gorupAPI = Request<GroupChatAPI>()
    
    func requestNotice()  {
        
        gorupAPI.request(.getNotice(groupId: self.conversationData.groupID), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                
                guard let self = self,
                      let title = response.data?["title"] as? String,
                      let content = response.data?["content"] as? String else {
                    return
                }
                
                let vc = ChatTopicNoticeViewController(noticeTitle: title, noticeContent: content)
                self.present(vc, animated: true, completion: nil)
                
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func requestMutedStatus()  {
        gorupAPI.request(.userGroupStatus(groupId: self.conversationData.groupID), type: Response<[String : Any]>.self)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                guard let resultCode = response.data?["resultCode"] as? Int else { return }
                if resultCode == 0 {
                    self?.selfMuted = false
                }
                else if resultCode == 1102 {
                    self?.selfMuted = true
                }
            }, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func handle(_ notification: Notification){
        
        guard let groupID = notification.userInfo?["groupID"] as? String,
              let contentData = notification.userInfo?["data"] as? Data,
              let json = try? JSONSerialization.jsonObject(with: contentData, options: .allowFragments) as? [String : Any] else {
            return
        }
        
        
        
        if groupID != self.conversationData.groupID {
            return
        }
        
        guard let type = json["type"] as? Int,
              let dataString = json["data"] as? String,
              let data = dataString.data(using: .utf8),
              let content = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String : Any]
        else {
            
            return
        }
        
        
        // 个人全群禁言
        if type == 103, let isGroupMute = content["isAllGroupMute"] as? Bool {
            self.selfMuted = isGroupMute
        }
        
        // 群内全体禁言
        if type == 104, let isGroupMute = content["isGroupMute"] as? Bool {
            self.allMuted = isGroupMute
        }
        
        // 群内运营公告
        if type == 105, let noticeText = content["noticeText"] as? String {
            
            addSystemMessage(content: noticeText)
        }
    }
    
    func addSystemMessage(content: String)  {
        
        self.messageController.tableView.beginUpdates()
        
        let systemData = SystemMessageCellData(direction: .MsgDirectionIncoming)
        systemData.status = .Msg_Status_Succ
        systemData.content = content
        
        guard let uiMessage = self.uiMessage else { return }
        
        uiMessage.add(systemData)
        self.messageController.tableView.insertRows(at: [IndexPath(row: uiMessage.count - 1, section: 0)], with: .fade)
        
        self.messageController.tableView.endUpdates()
        self.messageController.scroll(toBottom: true)
        

    }
    
    override func setupNavigationItem() {

        let memberItem = UIBarButtonItem(image: UIImage(named: "chat-member"), style: .plain, target: self, action: #selector(pushMember))
        navigationItem.rightBarButtonItems = [memberItem]
    }
    
    
    @objc
    func pushMember()  {
        
        let vc = ChatMemberContainerViewController(groupId: self.conversationData.groupID)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    let dynamicAPI = Request<DynamicAPI>()
    
    var disposeObject = DisposeBag()
    
    override func chatController(_ controller: ChatController!, onSelectMessageAvatar cell: TUIMessageCell!) {
        
        disposeObject = DisposeBag()
        
        let messageData = cell.messageData!
        
        userAPI.request(.checkFollow(userId: messageData.identifier), type: Response<[String : Any]>.self)
            .timeout(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)
            .verifyResponse()
            .subscribe(onSuccess: { [weak self] response in
                
                guard let isFollow = response.data?["isFollow"] as? Int else { return }
                
                var menus = ["@Ta", "资料", "关注", "举报"]
                
                if isFollow == 1 {
                    menus.remove(at: 2)
                }
                self?.presentChatTopicMenu(cell: cell, menus: menus, messageData: messageData)
                
            }, onError: { _ in
                
            })
            .disposed(by: disposeObject)
        
    }

    func follow(_ userId: String) {
        
        dynamicAPI.request(.follow(userId), type: ResponseEmpty.self)
            .subscribe(onSuccess: nil, onError: nil)
            .disposed(by: rx.disposeBag)
    }
    
    func presentChatTopicMenu(cell: TUIMessageCell, menus: [String], messageData: TUIMessageCellData){
        
       
        let sourceView = cell.avatarView!
        
        let vc = ChatTopicMenuViewController(menus: menus)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = CGRect(x: 4, y: 0, width: sourceView.bounds.width, height: sourceView.bounds.height)
        vc.popoverPresentationController?.backgroundColor = .white
        vc.popoverPresentationController?.canOverlapSourceViewRect = false
        
        vc.ondSelected.delegate(on: self) { (self, index) in
            self.action(for: menus[index], messageData: cell.messageData)
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    
    func action(for title: String, messageData: TUIMessageCellData)  {
        switch title {
        case "@Ta":
            at(messageData)
        case "资料":
            let userID = messageData.identifier
            let user = User()
            user.userId = userID
            
            let vc  = UserInfoViewController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        case "关注":
            follow(messageData.identifier)
        case "举报":
            let vc = ChatTopicReportViewController()
            present(vc, animated: true, completion: nil)
        default:  break
        }
        
    }
    
    func at(_ messageData: TUIMessageCellData) {
        
        inputController.inputBar.inputTextView.insertText("@\( messageData.name) ")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


/*
 - (void)sendMessage:(TUIMessageCellData *)msg
 {
     [self.tableView beginUpdates];
     V2TIMMessage *imMsg = msg.innerMessage;
     TUIMessageCellData *dateMsg = nil;
     if (msg.status == Msg_Status_Init)
     {
         //新消息
         if (!imMsg) {
             imMsg = [self transIMMsgFromUIMsg:msg];
         }
         dateMsg = [self transSystemMsgFromDate:imMsg.timestamp];

     } else if (imMsg) {
         //重发
         dateMsg = [self transSystemMsgFromDate:[NSDate date]];
         NSInteger row = [_uiMsgs indexOfObject:msg];
         [_heightCache removeObjectAtIndex:row];
         [_uiMsgs removeObjectAtIndex:row];
         [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]
                               withRowAnimation:UITableViewRowAnimationFade];
     } else {
         [self.tableView endUpdates];
         NSLog(@"Unknown message state");
         return;
     }
     // 设置推送
     V2TIMOfflinePushInfo *info = [[V2TIMOfflinePushInfo alloc] init];
     int chatType = 0;
     NSString *sender = @"";
     if (self.conversationData.groupID.length > 0) {
         chatType = 2;
         sender = self.conversationData.groupID;
     } else {
         chatType = 1;
         NSString *loginUser = [[V2TIMManager sharedInstance] getLoginUser];
         if (loginUser.length > 0) {
             sender = loginUser;
         }
     }
     NSDictionary *extParam = @{@"entity":@{@"action":@(APNs_Business_NormalMsg),@"chatType":@(chatType),@"sender":sender,@"version":@(APNs_Version)}};
     info.ext = [TUICallUtils dictionary2JsonStr:extParam];
     // 发消息
     @weakify(self)
     [[V2TIMManager sharedInstance] sendMessage:imMsg receiver:self.conversationData.userID groupID:self.conversationData.groupID priority:V2TIM_PRIORITY_DEFAULT onlineUserOnly:NO offlinePushInfo:info progress:^(uint32_t progress) {
         @strongify(self)
         for (TUIMessageCellData *uiMsg in self.uiMsgs) {
             if ([uiMsg.innerMessage.msgID isEqualToString:imMsg.msgID]) {
                 if([uiMsg isKindOfClass:[TUIImageMessageCellData class]]){
                     TUIImageMessageCellData *data = (TUIImageMessageCellData *)uiMsg;
                     data.uploadProgress = progress;
                 }
                 else if([uiMsg isKindOfClass:[TUIVideoMessageCellData class]]){
                     TUIVideoMessageCellData *data = (TUIVideoMessageCellData *)uiMsg;
                     data.uploadProgress = progress;
                 }
                 else if([uiMsg isKindOfClass:[TUIFileMessageCellData class]]){
                     TUIFileMessageCellData *data = (TUIFileMessageCellData *)uiMsg;
                     data.uploadProgress = progress;
                 }
             }
         }
     } succ:^{
         @strongify(self)
         dispatch_async(dispatch_get_main_queue(), ^{
             [self changeMsg:msg status:Msg_Status_Succ];
         });
     } fail:^(int code, NSString *desc) {
         @strongify(self)
         dispatch_async(dispatch_get_main_queue(), ^{
             [THelper makeToastError:code msg:desc];
             [self changeMsg:msg status:Msg_Status_Fail];
         });
     }];
     
     // 展示 UI 界面
     msg.status = Msg_Status_Sending;
     msg.name = [msg.innerMessage getShowName];
     msg.avatarUrl = [NSURL URLWithString:[msg.innerMessage faceURL]];
     if(dateMsg){
         _msgForDate = imMsg;
         [_uiMsgs addObject:dateMsg];
         [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                               withRowAnimation:UITableViewRowAnimationFade];
     }
     [_uiMsgs addObject:msg];
     [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_uiMsgs.count - 1 inSection:0]]
                           withRowAnimation:UITableViewRowAnimationFade];
     [self.tableView endUpdates];
     [self scrollToBottom:YES];

     int delay = 1;
     if([msg isKindOfClass:[TUIImageMessageCellData class]]){
         delay = 0;
     }
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         @strongify(self)
         if(msg.status == Msg_Status_Sending){
             [self changeMsg:msg status:Msg_Status_Sending_2];
         }
     });
 }
 **/
