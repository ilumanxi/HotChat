//
//  ConversationListController.m
//  HotChat
//
//  Created by 风起兮 on 2021/4/26.
//  Copyright © 2021 风起兮. All rights reserved.
//

#import "ConversationListController.h"
#import "TUIConversationCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "TUILocalStorage.h"
#import "TIMUserProfile+DataProvider.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIColor+TUIDarkMode.h"
#import "NSBundle+TUIKIT.h"
#import "TUIConversationCellData+Intimacy.h"
#import "HotChat-Swift.h"
@import ImSDK;

static NSString *kConversationCell_ReuseId = @"TConversationCell";

@interface ConversationListController () <UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate>

/**
 * 会话数据
 */
@property (strong) NSArray<TUIConversationCellData *> *dataList;

@property(nonatomic,retain) IntimacyHelper *intimacyHelper;

@property(nonatomic,assign, getter=isIntimacy) BOOL intimacy;

@end

@implementation ConversationListController

- (instancetype)initWithIntimacy:(BOOL)isIntimacy {
    
    if (self = [super init]) {
        _intimacy = isIntimacy;
    }
    return  self;
}

- (IntimacyHelper *)intimacyHelper {
    if (!_intimacyHelper) {
        _intimacyHelper = [[IntimacyHelper alloc] init];
    }
    return _intimacyHelper;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataList = @[];
    
    [self setupViews];
    !self.dataChaned ? : self.dataChaned(self, self.dataList.copy);

    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(intimacyChanged) name:@"com.friday.Chat.intimacyDidChange" object:nil];
}

- (void)intimacyChanged {
    if (self.isIntimacy) {
        [self requestIntimacyList: self.viewModel.dataList success:^(NSArray<TUIConversationCellData *> * conversations) {
            self.dataList =  [self filteConversation: conversations];
            [self.tableView reloadData];
        }];
    }
    else {
        [self requestIntimacyList:self.dataList success:^(NSArray<TUIConversationCellData *> * conversations) {
            self.dataList = conversations;
            [self.tableView reloadData];
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [_tableView registerClass:[ConversationCell class] forCellReuseIdentifier:kConversationCell_ReuseId];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    @weakify(self)
    [RACObserve(self.viewModel, dataList) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        
        if (self.isIntimacy) {
            [self requestIntimacyList: self.viewModel.dataList success:^(NSArray<TUIConversationCellData *> * conversations) {
                self.dataList =  [self filteConversation: conversations];
                [self.tableView reloadData];
                !self.dataChaned ? : self.dataChaned(self, self.dataList.copy);
            }];
        }
        else {
            self.dataList = self.viewModel.dataList;
            [self requestIntimacyList:self.dataList success:^(NSArray<TUIConversationCellData *> * conversations) {
                self.dataList = conversations;
                [self.tableView reloadData];
                !self.dataChaned ? : self.dataChaned(self, self.dataList.copy);
            }];
        }
    }];
}

-  (void)requestIntimacyList:(NSArray<TUIConversationCellData *> *) conversations success: (void (^)(NSArray<TUIConversationCellData *> *))block {
    
    if (conversations.count == 0) {
        return;
    }
    
    NSMutableArray<NSString *> *userIDs = @[].mutableCopy;
    
    for (TUIConversationCellData *conversation in conversations) {
        [userIDs addObject:conversation.userID];
    }
    
    [self.intimacyHelper
     intimacyList:userIDs
        success:^(NSDictionary<NSString *,id> * _Nonnull intimacyList) {
        [self setConversations:conversations intimacyList:intimacyList];
        block(conversations);
    } failed:^(NSError * _Nonnull error) {
        
    }];
}


- (void)setConversations:(NSArray<TUIConversationCellData *> *) conversations intimacyList:(NSDictionary<NSString *,id> * _Nonnull )intimacyList {
    for (TUIConversationCellData *conversation in conversations) {
        NSDictionary<NSString *,id> *intimacy = intimacyList[conversation.userID];
        if (intimacy[@"userIntimacy"] != nil) {
            conversation.userIntimacy =  [intimacy[@"userIntimacy"] floatValue];
        }
    }
}

- (NSArray<TUIConversationCellData *> *)filteConversation:(NSArray<TUIConversationCellData *> *) conversations {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userIntimacy >= 4"];
    
    return  [conversations filteredArrayUsingPredicate: predicate];
}

- (TConversationListViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [TConversationListViewModel new];
    }
    return _viewModel;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataList[indexPath.row] heightOfWidth:Screen_Width];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TUILocalizableString(Delete);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        TUIConversationCellData *conv = self.dataList[indexPath.row];
        [self.viewModel removeData:conv];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }
}

- (void)didSelectConversation:(ConversationCell *)cell
{
    if(_delegate && [_delegate respondsToSelector:@selector(conversationListController:didSelectConversation:)]){
        [_delegate conversationListController:self didSelectConversation:cell];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:kConversationCell_ReuseId forIndexPath:indexPath];
    TUIConversationCellData *data = [self.dataList objectAtIndex:indexPath.row];
    if (!data.cselector) {
        data.cselector = @selector(didSelectConversation:);
    }
    [cell fillWithData:data];

    //可以在此处修改，也可以在对应cell的初始化中进行修改。用户可以灵活的根据自己的使用需求进行设置。
    cell.changeColorWhenTouched = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (indexPath.row == (self.dataList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
