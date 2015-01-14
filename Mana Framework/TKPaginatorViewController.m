//
//  TKPaginatorViewController.m
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import "TKPaginatorViewController.h"
#import "TKPageView.h"

@interface TKPaginatorViewController()
- (void)_initialize;
@end

@interface TKPaginatorViewController ()

@end

@implementation TKPaginatorViewController

@synthesize paginatorView = _paginator;

#pragma mark - NSObject

- (id)init {
	if ((self = [super init])) {
		[self _initialize];
	}
	return self;
}


- (void)dealloc {
	_paginator.dataSource = nil;
	_paginator.delegate = nil;
    [super dealloc];
}


#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self _initialize];
	}
	return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	_paginator.frame = self.view.bounds;
	[self.view addSubview:_paginator];
}


- (void)viewDidUnload {
	[super viewDidUnload];
	[_paginator removeFromSuperview];
}


#pragma mark - Private

- (void)_initialize {
	_paginator = [[TKPaginatorView alloc] initWithFrame:CGRectZero];
	_paginator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_paginator.dataSource = self;
	_paginator.delegate = self;
}


#pragma mark - TKPaginatorDataSource

- (NSInteger)numberOfPagesForPaginatorView:(TKPaginatorView *)paginator {
	return 0;
}


- (TKPageView *)paginatorView:(TKPaginatorView *)paginator viewForPageAtIndex:(NSInteger)page {
	return nil;
}

@end
