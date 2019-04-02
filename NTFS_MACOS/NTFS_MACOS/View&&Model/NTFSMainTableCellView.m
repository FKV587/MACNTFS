//
//  NTFSMainTableCellView.m
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/20.
//  Copyright © 2019 付凯. All rights reserved.
//

#import "NTFSMainTableCellView.h"
#import "Disk.h"

@interface NTFSMainTableCellView()

@property (nonatomic , strong)NSImageView * iconImageView;
@property (nonatomic , strong)NSTextField * nameLabel;
@property (nonatomic , strong)NSTextField * diskStateLabel;
@property (nonatomic , strong)NSButton * unMountButton;

@property (nonatomic , strong)NSButton * openFenderButton;
@property (nonatomic , strong)NSView * sepView;

@end

@implementation NTFSMainTableCellView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self loadViews];
}

-(instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self loadViews];
    }
    return self;
}

- (void)loadViews{
    @weakify(self)
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self_weak_.nameLabel.mas_centerY);
        make.left.mas_offset(10.0);
        make.height.width.mas_offset(40.0);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(20.0);
//        make.centerY.equalTo(self_weak_.iconImageView.mas_centerY);
        make.left.equalTo(self_weak_.iconImageView.mas_right).mas_offset(10.0);
    }];
    
    [self.openFenderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self_weak_.nameLabel.mas_centerY);
        make.right.mas_offset(-20.0);
    }];
    
    [self.diskStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self_weak_.nameLabel.mas_centerY);
        make.right.equalTo(self_weak_.openFenderButton.mas_left).mas_offset(-20.0);
        make.left.equalTo(self_weak_.nameLabel.mas_right).mas_offset(2.0);
    }];
    
//    [self.unMountButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self_weak_.openFenderButton.mas_centerY);
//        make.left.equalTo(self_weak_.openFenderButton.mas_right).mas_offset(20.0);
//        make.right.mas_offset(-20.0);
//    }];
    
    [self.nameLabel setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.openFenderButton setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self.diskStateLabel setContentCompressionResistancePriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
//    [self.unMountButton setContentCompressionResistancePriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationHorizontal];

    [self.sepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self_weak_.nameLabel.mas_bottom).mas_offset(20.0);
        make.bottom.mas_offset(0.0);
        make.left.right.mas_offset(0.0);
        make.height.mas_offset(1.0);
    }];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)openFenderButtonAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainTableCellViewReback:)]) {
        [self.delegate mainTableCellViewReback:self.disk];
    }
}

- (void)unMountButtonAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainTableCellViewReback:)]) {
        [self.delegate mainTableCellViewUnMount:self.disk];
    }
}

#pragma mark -- setter getter --
- (void)setDisk:(Disk *)disk{
    _disk = disk;
//    _disk.volumePath
    self.nameLabel.stringValue = [NSString stringWithFormat:@"磁盘地址：%@",_disk.volumePath];
    if (![disk isNTFS]) {
        self.diskStateLabel.stringValue = @"磁盘状态：读写挂载成功";
        self.openFenderButton.title = @"在Fender中打开";
        self.diskStateLabel.textColor = [NSColor colorWithHex:0x1296db];
    }else if (disk.isNTFSWritable) {
//        self.mountButton.title = @"磁盘状态：已挂载";
//        self.mountButton.enabled = NO;
        self.diskStateLabel.stringValue = @"磁盘状态：读写挂载成功";
        self.openFenderButton.title = @"在Fender中打开";
        self.diskStateLabel.textColor = [NSColor colorWithHex:0x1296db];
    }else{
//        self.mountButton.title = @"磁盘状态：未挂载";
//        self.mountButton.enabled = YES;
        self.diskStateLabel.stringValue = @"磁盘状态：读写挂载失败";
        self.openFenderButton.title = @"挂载并打开";
        self.diskStateLabel.textColor = [NSColor colorWithHex:0xd81e06];
    }
}

- (NSTextField *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _nameLabel.editable = NO;
        _nameLabel.bordered = NO;
        _nameLabel.font = [NSFont systemFontOfSize:20.0];
        _nameLabel.backgroundColor = [NSColor clearColor];
        _nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        if (@available(macOS 10.11, *)) {
            _nameLabel.maximumNumberOfLines = 2;
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (NSTextField *)diskStateLabel{
    if (!_diskStateLabel) {
        _diskStateLabel = [[NSTextField alloc] initWithFrame:NSZeroRect];
        _diskStateLabel.editable = NO;
        _diskStateLabel.bordered = NO;
        _diskStateLabel.font = [NSFont systemFontOfSize:20.0];
        _diskStateLabel.backgroundColor = [NSColor clearColor];
        _diskStateLabel.lineBreakMode = NSLineBreakByCharWrapping;
        if (@available(macOS 10.11, *)) {
            _diskStateLabel.maximumNumberOfLines = 2;
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:_diskStateLabel];
    }
    return _diskStateLabel;
}

- (NSButton *)openFenderButton{
    if (!_openFenderButton) {
        _openFenderButton = [[NSButton alloc]init];
        [_openFenderButton setBezelStyle:NSBezelStyleRounded];
        [_openFenderButton setAction:@selector(openFenderButtonAction)];
        [_openFenderButton setTarget:self];
        if (@available(macOS 10.12.2, *)) {
            [_openFenderButton setBezelColor:[NSColor colorWithHex:0x1296db]];
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:_openFenderButton];
    }
    return _openFenderButton;
}

- (NSButton *)unMountButton{
    if (!_unMountButton) {
        _unMountButton = [[NSButton alloc]init];
        [_unMountButton setBezelStyle:NSBezelStyleRounded];
        [_unMountButton setAction:@selector(unMountButtonAction)];
        [_unMountButton setTarget:self];
        [_unMountButton setTitle:@"推出磁盘"];
        [self addSubview:_unMountButton];
    }
    return _unMountButton;
}

- (NSView *)sepView{
    if (!_sepView) {
        _sepView = [[NSView alloc]init];
        [_sepView setBackGroundColor:[NSColor grayColor]];
        [self addSubview:_sepView];
    }
    return _sepView;
}

- (NSImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[NSImageView alloc]init];
        _iconImageView.image = [NSImage imageNamed:@"disk"];
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

@end
