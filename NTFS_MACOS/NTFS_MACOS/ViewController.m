//
//  ViewController.m
//  NTFS_MACOS
//
//  Created by Master_K on 2019/3/16.
//  Copyright © 2019 付凯. All rights reserved.
//

#import "ViewController.h"
#import "NTFSMainTableCellView.h"
#import "Disk.h"
#import "FKLodingViewController.h"

@interface ViewController()<NSTableViewDelegate,NSTableViewDataSource,NTFSMainTableCellViewDelegate>

@property (nonatomic , strong)NSTableView * tableView;
@property (nonatomic , strong)NSScrollView * tableContainerView;
@property (nonatomic , strong)NSArray <Disk *>* ntfsDisks;
@property (nonatomic , strong)NSView * errorView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ntfsDisks = [[NTFSManager sharedManager].ntfsDisks copy];
    
    [self.tableContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_offset(10.0);
        make.bottom.right.mas_offset(-10.0);
        make.height.mas_offset(600.0);
        make.width.mas_greaterThanOrEqualTo(800.0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_offset(0.0);
        make.right.mas_offset(0.0);
        make.height.mas_offset(600.0);
    }];
    @weakify(self)
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self_weak_.view.mas_centerX);
        make.centerY.equalTo(self_weak_.view.mas_centerY);
//        make.top.mas_offset(50.0);
        make.left.right.mas_offset(0.0);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ntfsDiskAppeared:) name:NTFSDiskAppearedNotification object:nil];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)ntfsDiskAppeared:(NSNotification *)notification {
    self.ntfsDisks = [[NTFSManager sharedManager].ntfsDisks copy];
    [self.tableView reloadData];
}

#pragma mark -- NTFSMainTableCellViewDelegate --
- (void)mainTableCellViewReback:(Disk *)disk{
    if (disk.isNTFSWritable || ![disk isNTFS]) {
        FKLodingViewController * vc = [[FKLodingViewController alloc]init];
        [self presentViewControllerAsSheet:vc];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[NTFSManager sharedManager]openVolumePath:disk];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [vc dismiss];
            });
        });
    }else{
        NSString *msgText = [NSString stringWithFormat:@"检测到磁盘: %@", disk.volumeName];
        NSAlert *confirm = [[NSAlert alloc]init];
        [confirm addButtonWithTitle:@"确定"];
        [confirm addButtonWithTitle:@"取消"];
        [confirm setMessageText:msgText];
        [confirm setInformativeText:@"是否要为此磁盘启用NTFS写入模式?"];
        [confirm setAlertStyle:NSAlertStyleWarning];
        [confirm setIcon:[NSApp applicationIconImage]];
        [confirm beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn) {
                FKLodingViewController * vc = [[FKLodingViewController alloc]init];
                [self presentViewControllerAsSheet:vc];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [[NTFSManager sharedManager]ntfsDiskAppeared:disk];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                        [vc dismiss];
                    });
                });
            }
        }];
 
    }
}

- (void)mainTableCellViewUnMount:(Disk *)disk{
    [disk unmount];
}

#pragma mark -- NSTableViewDelegate,NSTableViewDataSource --
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.ntfsDisks.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    //获取表格列的标识符
    NTFSMainTableCellView *cell = [tableView makeViewWithIdentifier:@"NTFSMainTableCellView" owner:self];
    cell.delegate = self;
    cell.disk = self.ntfsDisks[row];
    return cell;
}

#pragma mark - 行高

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    NTFSMainTableCellView *cell = [tableView makeViewWithIdentifier:@"NTFSMainTableCellView" owner:self];
    cell.disk = self.ntfsDisks[row];
    return [cell fittingSize].height;
}

#pragma mark - 是否可以选中单元格
-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    
    //设置cell选中高亮颜色
//    NSTableRowView *myRowView = [self.tableView rowViewAtRow:row makeIfNecessary:NO];
//
//    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
//    [myRowView setEmphasized:NO];
//
//    NSLog(@"shouldSelect : %ld",row);
    return NO;
}

//选中的响应
-(void)tableViewSelectionDidChange:(nonnull NSNotification *)notification{
    NSTableView * tableView = notification.object;
    
    NSLog(@"didSelect：%ld",tableView.selectedRow);
}

#pragma mark -- setter getter --

- (NSTableView *)tableView{
    if (!_tableView) {
        _tableView = [[NSTableView alloc]init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        NSTableColumn *column1 = [[NSTableColumn alloc] initWithIdentifier:@"columnFrist"];
        column1.title = @"设备列表";
        column1.headerCell.font = [NSFont systemFontOfSize:22.0];
        [_tableView addTableColumn:column1];
        _tableView.backgroundColor = [NSColor clearColor];
        [_tableView registerNib:[[NSNib alloc] initWithNibNamed:@"NTFSMainTableCellView" bundle:nil] forIdentifier:@"NTFSMainTableCellView"];
    }
    return _tableView;
}

- (NSScrollView *)tableContainerView{
    if (!_tableContainerView) {
        _tableContainerView = [[NSScrollView alloc] init];
        _tableContainerView.backgroundColor = [NSColor redColor];
        
        [_tableContainerView setDocumentView:self.tableView];
        [_tableContainerView setDrawsBackground:NO];//不画背景（背景默认画成白色）
        
        [_tableContainerView setHasVerticalScroller:YES];//有垂直滚动条
        //[_tableContainer setHasHorizontalScroller:YES];  //有水平滚动条
        _tableContainerView.autohidesScrollers = YES;//自动隐藏滚动条（滚动的时候出现）
        [self.view addSubview:_tableContainerView];
    }
    return _tableContainerView;
}

- (NSView *)errorView{
    if (!_errorView) {
        _errorView = [[NSView alloc]init];
        _errorView.hidden = YES;
        [self.view addSubview:_errorView];
        NSImageView * imageView = [[NSImageView alloc]init];
        imageView.image = [NSImage imageNamed:@"noData"];
        [_errorView addSubview:imageView];
        @weakify(self)
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(0.0);
            make.centerX.equalTo(self_weak_.errorView.mas_centerX);
            //            make.centerY.equalTo(self_weak_.errorView.mas_centerY);
        }];
        
        NSTextField * label = [[NSTextField alloc]init];
        label.editable = NO;
        label.bordered = NO;
        label.textColor = [NSColor colorWithHex:0x1296db];
        label.stringValue = @"没有检测到磁盘";
        label.backgroundColor = [NSColor clearColor];
        [_errorView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).mas_offset(5.0);
            make.centerX.equalTo(imageView.mas_centerX);
            make.bottom.mas_offset(0.0);
        }];
    }
    return _errorView;
}

- (void)setNtfsDisks:(NSArray<Disk *> *)ntfsDisks{
    _ntfsDisks = ntfsDisks;
    if (_ntfsDisks.count > 0) {
        self.errorView.hidden = YES;
        self.tableContainerView.hidden = NO;
    }else{
        self.errorView.hidden = NO;
        self.tableContainerView.hidden = YES;
    }
}

@end
