//
//  TKPaginatorScrollView.m
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import "TKPaginatorScrollView.h"

@implementation TKPaginatorScrollView

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate {
//    NSLog(@"TKPaginatorScrollView setDelegate");
	return;
}


- (id<UIScrollViewDelegate>)privateDelegate {
//    NSLog(@"TKPaginatorScrollView privateDelegate");
	return [self delegate];
}


- (void)setPrivateDelegate:(id<UIScrollViewDelegate>)privateDelegate {
//    NSLog(@"TKPaginatorScrollView setPrivateDelegate");
	[super setDelegate:privateDelegate];
}

@end
