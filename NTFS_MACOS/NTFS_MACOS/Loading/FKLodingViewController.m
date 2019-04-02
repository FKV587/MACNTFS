//
//  FKLodingViewController.m
//  NTFS_MACOS
//
//  Created by Fukai on 2019/3/21.
//  Copyright © 2019 付凯. All rights reserved.
//

#import "FKLodingViewController.h"

@interface FKLodingViewController ()
@property (weak) IBOutlet NSProgressIndicator *progressLoading;
@property (weak) IBOutlet NSTextField *messageLabel;

@end

@implementation FKLodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.progressLoading startAnimation:nil];
}

- (void)dismiss{
    [self.progressLoading stopAnimation:nil];
    [self dismissController:self];
}

@end
