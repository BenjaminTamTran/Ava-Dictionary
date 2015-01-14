//
//  TKPaginatorView.m
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import "TKPaginatorView.h"
#import "TKPageView.h"
#import "TKPaginatorScrollView.h"


@interface TKPaginatorView () <UIScrollViewDelegate>
- (void)_loadPage:(NSInteger)page;
- (void)_loadPagesToPreloadAroundPageAtIndex:(NSInteger)index;
- (CGFloat)_offsetForPage:(NSInteger)page;
- (void)_resetScrollViewContentSize;
- (void)_cleanup;
- (void)_removeViewAtIndex:(NSInteger)index;
- (void)_reuseViewAtIndex:(NSInteger)index;
- (void)_reusePages;
- (void)_setCurrentPageIndex:(NSInteger)targetPage animated:(BOOL)animated scroll:(BOOL)scroll forcePreload:(BOOL)forcePreload;
@end


@implementation TKPaginatorView{
	NSMutableDictionary  *_pages;
	NSMutableDictionary *_reuseablePages;
	BOOL _pageControlUsed;
	BOOL _pageSetViaPublicMethod;
}

@synthesize scrollView = _scrollView;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize pageGapWidth = _pageGapWidth;
@synthesize numberOfPagesToPreload = _pagesToPreload;
@synthesize swipeableRect = _swipeableRect;
@synthesize currentPageIndex = _currentPageIndex;
@synthesize paginationDirection = _paginationDirection;

- (void)setCurrentPageIndex:(NSInteger)targetPage {
	[self setCurrentPageIndex:targetPage animated:NO];
}


- (NSInteger)numberOfPages {
	return [self.dataSource numberOfPagesForPaginatorView:self];
}


- (void)setPageGapWidth:(CGFloat)pageGap {
//    NSLog(@"TKPaginatorView setPageGapWidth");
	_pageGapWidth = pageGap;
	
	CGRect rect = _scrollView.frame;
	CGFloat gapOffset = roundf(pageGap / 2.0f);
	if (_paginationDirection == TKPageViewPaginationDirectionHorizontal) {
		rect.origin.x -= gapOffset;
		rect.size.width += pageGap;
	} else {
		rect.origin.y -= gapOffset;
		rect.size.height += pageGap;
	}
	
	_scrollView.frame = rect;
	[self setNeedsLayout];
}


#pragma mark - NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.dataSource = nil;
	_scrollView.delegate = nil;
	
	[_reuseablePages removeAllObjects];
    [super dealloc];
}


#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame {
//    NSLog(@"TKPaginatorView initWithFrame");
	if ((self = [super initWithFrame:frame])) {
		self.clipsToBounds = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.numberOfPagesToPreload = 2;
		
		// Scroll view
		_scrollView = [[TKPaginatorScrollView alloc] initWithFrame:self.bounds];
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_scrollView.pagingEnabled = YES;
		_scrollView.showsVerticalScrollIndicator = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.scrollsToTop = NO;
		[(TKPaginatorScrollView *)_scrollView setPrivateDelegate:self];
		[self addSubview:_scrollView];
		
		// Setup views cache
		_pages = [[NSMutableDictionary alloc] init];
		_reuseablePages = [[NSMutableDictionary alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_cleanup)
													 name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}


- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self _resetScrollViewContentSize];
	
	for (NSNumber *key in _pages) {
		UIView *view = [_pages objectForKey:key];
		view.frame = [self frameForPageAtIndex:key.integerValue];
	}
	
	// Since the location of the current page will likely change during an orientation change (and since this is called
	// within the animation block during said change) setting the page index will assure all the necessary offsets
	// are calculated and assigned for the new view bounds
	[self setCurrentPageIndex:self.currentPageIndex];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (CGRectIsEmpty(_swipeableRect) == NO) {
		BOOL contains = CGRectContainsPoint(_swipeableRect, point);
		return contains;
	}
	return [super pointInside:point withEvent:event];
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
	[super willMoveToSuperview:newSuperview];
	if (!newSuperview) {
		[self _cleanup];
	}
}


#pragma mark - Managing data

- (void)reloadData {
	[self reloadDataRemovingCurrentPage:YES];
}


- (void)reloadDataRemovingCurrentPage:(BOOL)removeCurrentPage {
//    NSLog(@"TKPaginatorView reloadDataRemovingCurrentPage");
	[self _resetScrollViewContentSize];
	
	NSInteger numberOfPages = [self numberOfPages];
	
	// Remove views
	NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
	[_pages enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (!removeCurrentPage && [key integerValue] == self.currentPageIndex) {
			return;
		}
		
		[obj removeFromSuperview];
		[keysToRemove addObject:key];
	}];
	[_pages removeObjectsForKeys:keysToRemove];
	
	// Reload current page
	NSUInteger newIndex = self.currentPageIndex;
	if (newIndex >= numberOfPages) {
		newIndex = numberOfPages - 1;
	}
	
	[self _setCurrentPageIndex:newIndex animated:NO scroll:YES forcePreload:YES];
}


- (void)setCurrentPageIndex:(NSInteger)targetPage animated:(BOOL)animated {
	_pageSetViaPublicMethod = YES;
	[self _setCurrentPageIndex:targetPage animated:animated scroll:YES forcePreload:NO];
}


- (CGRect)frameForPageAtIndex:(NSInteger)page {
//    NSLog(@"TKPaginatorView frameForPageAtIndex %d", page);
	CGSize size = _scrollView.frame.size;
	CGFloat offset = [self _offsetForPage:page];
	if (_paginationDirection == TKPageViewPaginationDirectionHorizontal) {
		return CGRectMake(offset, 0.0f, size.width - _pageGapWidth, size.height);
	} else {
		return CGRectMake(0.0f, offset, size.width, size.height - _pageGapWidth);
	}
}


- (TKPageView *)pageForIndex:(NSInteger)page {
//    NSLog(@"TKPaginatorView pageForIndex %d", page);
	return [_pages objectForKey:[NSNumber numberWithInteger:page]];
}


- (TKPageView *)dequeueReusablePageWithIdentifier:(NSString *)identifier {
//    NSLog(@"TKPaginatorView dequeueReusablePageWithIdentifier %@", identifier);
	if (!identifier) {
		return nil;
	}
	
	NSMutableSet *pages = [_reuseablePages objectForKey:identifier];
	if (!pages || [pages count] == 0) {
		return nil;
	}
	
	TKPageView *page = [pages anyObject];
	[pages removeObject:page];
	
	return page;
}


- (TKPageView *)currentPage {
	return [_pages objectForKey:[NSNumber numberWithInteger:self.currentPageIndex]];
}


#pragma mark - Properties

- (void)setDataSource:(id<TKPaginatorViewDataSource>)dataSource {
//    NSLog(@"TKPaginatorView setDataSource");
	_dataSource = dataSource;
	if (_dataSource) {
		[self reloadData];
	}
}


- (void)setPaginationDirection:(TKPageViewPaginationDirection)paginationDirection {
	BOOL directionChanged = (paginationDirection != _paginationDirection);
	
	_paginationDirection = paginationDirection;
	
	if (directionChanged) {
		if (_paginationDirection == TKPageViewPaginationDirectionHorizontal) {
			_scrollView.alwaysBounceHorizontal = YES;
			_scrollView.alwaysBounceVertical = NO;
		} else {
			_scrollView.alwaysBounceHorizontal = NO;
			_scrollView.alwaysBounceVertical = YES;
		}
		[self reloadData];
	}
}


#pragma mark - Private


- (void)_loadPage:(NSInteger)page {
//    NSLog(@"TKPaginatorView _loadPage %d", page);
	if (page < 0 || page >= self.numberOfPages) {
		return;
	}
	
	UIView *view = [self pageForIndex:page];
	if (!view) {
		view = [self.dataSource paginatorView:self viewForPageAtIndex:page];
		view.autoresizingMask = UIViewAutoresizingNone;
		
		if (view) {
			[_pages setObject:view forKey:[NSNumber numberWithInteger:page]];
			[_scrollView addSubview:view];
			view.frame = [self frameForPageAtIndex:page];
			
			[self _reusePages];
		}
	}
}


- (void)_loadPagesToPreloadAroundPageAtIndex:(NSInteger)index {
	if (self.numberOfPagesToPreload > 0) {
		for (NSInteger offset = 1; offset <= self.numberOfPagesToPreload; offset++) {
			[self _loadPage:index + offset];
			[self _loadPage:index - offset];
		}
	}
}


- (CGFloat)_offsetForPage:(NSInteger)page {
	CGFloat pageDelta = 0.0f;
	if (_paginationDirection == TKPageViewPaginationDirectionHorizontal) {
		pageDelta = _scrollView.bounds.size.width;
	} else {
		pageDelta = _scrollView.bounds.size.height;
	}
	return (page == 0) ? roundf(_pageGapWidth / 2.0f) : (pageDelta * page) + roundf(_pageGapWidth / 2.0f);
}


- (void)_resetScrollViewContentSize {
	NSInteger numberOfPages = [self numberOfPages];
	CGSize boundsSize = _scrollView.bounds.size;
	if (_paginationDirection == TKPageViewPaginationDirectionHorizontal) {
		boundsSize.width = (numberOfPages * boundsSize.width);
	} else {
		boundsSize.height = (numberOfPages * boundsSize.height);
	}
	_scrollView.contentSize = boundsSize;
}


- (void)_cleanup {
	NSMutableSet *keysToRemove = [[NSMutableSet alloc] init];
	for (NSNumber *key in _pages) {
		if (key.integerValue != self.currentPageIndex) {
			[keysToRemove addObject:key];
		}
	}
	
	for (NSNumber *key in keysToRemove) {
		[self _removeViewAtIndex:key.integerValue];
	}
	[keysToRemove release];
	[_reuseablePages removeAllObjects];
    
}


- (void)_removeViewAtIndex:(NSInteger)index {
	[[self pageForIndex:index] removeFromSuperview];
	[_pages removeObjectForKey:[NSNumber numberWithInteger:index]];
}


- (void)_reuseViewAtIndex:(NSInteger)index {
//    NSLog(@"TKPaginatorView _reuseViewAtIndex %d", index);
	TKPageView *view = [self pageForIndex:index];
	if (!view.reuseIdentifier) {
		NSAssert(view.reuseIdentifier, @"[TKPaginatorView] You should specify a reuse identifier for you TKPageViews.");
		[self _removeViewAtIndex:index];
		return;
	}
	
	[view removeFromSuperview];
	[_pages removeObjectForKey:[NSNumber numberWithInteger:index]];
	[view prepareForReuse];
	
	NSMutableSet *set = [_reuseablePages objectForKey:view.reuseIdentifier];
	if (!set)
    {
		set = [[[NSMutableSet alloc] init] autorelease];
		[_reuseablePages setObject:set forKey:view.reuseIdentifier];
	}
	
	[set addObject:view];
}


- (void)_reusePages {
	// Check for reuse
	// TODO: This could be faster
	NSArray *allKeys = [_pages allKeys];
	NSInteger numberOfKeys = allKeys.count;
	if (numberOfKeys - _pagesToPreload - _pagesToPreload <= 0) {
		return;
	}
    
	NSArray *sortedKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
	NSInteger currentIndex = [sortedKeys indexOfObject:[NSNumber numberWithInteger:self.currentPageIndex]];
	
	// Remove before current index
	NSInteger location = currentIndex + _pagesToPreload;
	NSInteger length = numberOfKeys - location - 1;
	if (location > 0 && length > 0 && numberOfKeys > location + length) {
		NSArray *keys = [sortedKeys subarrayWithRange:NSMakeRange(location, length)];
		for (NSNumber *key in keys) {
			[self _reuseViewAtIndex:key.integerValue];
		}
	}
	
	// Remove after current index
	numberOfKeys = allKeys.count;
	length = currentIndex - _pagesToPreload;
	if (currentIndex - _pagesToPreload > 0 && length > 0 && length < numberOfKeys) {
		NSArray *keys = [sortedKeys subarrayWithRange:NSMakeRange(0, length)];
		for (NSNumber *key in keys) {
			[self _reuseViewAtIndex:key.integerValue];
		}
	}
}


- (void)_setCurrentPageIndex:(NSInteger)targetPage animated:(BOOL)animated scroll:(BOOL)scroll forcePreload:(BOOL)forcePreload {
//    NSLog(@"TKPaginatorView _setCurrentPageIndex %d", targetPage);
	if (_currentPageIndex == targetPage && _pageSetViaPublicMethod != YES) {
		return;
	}
	
	if (scroll && _delegate && [_delegate respondsToSelector:@selector(paginatorViewDidBeginPaging:)]) {
		[_delegate paginatorViewDidBeginPaging:self];
	}
	
	NSInteger numberOfPages = [self numberOfPages];
	if (targetPage > numberOfPages) {
		targetPage = 0;
	} else if (targetPage > numberOfPages - 1) {
		targetPage = numberOfPages;
	}
	
	if (_currentPageIndex != targetPage || [self pageForIndex:targetPage] == nil || forcePreload) {
		_currentPageIndex = targetPage;
		
		[self _loadPage:targetPage];
		[self _loadPagesToPreloadAroundPageAtIndex:targetPage];
        
        if(_delegate && [_delegate respondsToSelector:@selector(paginatorView:willDisplayView:atIndex:)]){
            [_delegate paginatorView:self willDisplayView:[self pageForIndex:targetPage] atIndex:targetPage];
        }
	}
	
	if (scroll) {
		CGFloat targetOffset = [self _offsetForPage:targetPage] - roundf(_pageGapWidth / 2.0f);
		if (_paginationDirection == TKPageViewPaginationDirectionHorizontal) {
			if (_scrollView.contentOffset.x != targetOffset) {
				[_scrollView setContentOffset:CGPointMake(targetOffset, 0.0f) animated:animated];
				_pageControlUsed = YES;
			}
		} else {
			if (_scrollView.contentOffset.y != targetOffset) {
				[_scrollView setContentOffset:CGPointMake(0.0f, targetOffset) animated:animated];
				_pageControlUsed = YES;
			}
		}
		
		if (_delegate && [_delegate respondsToSelector:@selector(paginatorView:didScrollToPageAtIndex:)]) {
			[_delegate paginatorView:self didScrollToPageAtIndex:self.currentPageIndex];
		}
	}
	
	_pageSetViaPublicMethod = NO;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (_pageControlUsed) {
		return;
	}
	
	NSInteger pageIndex = 0;
	if (_paginationDirection == TKPageViewPaginationDirectionHorizontal) {
		CGFloat pageWidth = _scrollView.frame.size.width;
		pageIndex = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	} else {
		CGFloat pageHeight = _scrollView.frame.size.height;
		pageIndex = floor((_scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
	}
	
	[self _setCurrentPageIndex:pageIndex animated:NO scroll:NO forcePreload:NO];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (_delegate && [_delegate respondsToSelector:@selector(paginatorViewDidBeginPaging:)]) {
		[_delegate paginatorViewDidBeginPaging:self];
	}
	
	_pageControlUsed = NO;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (_delegate && [_delegate respondsToSelector:@selector(paginatorView:didScrollToPageAtIndex:)]) {
		[_delegate paginatorView:self didScrollToPageAtIndex:self.currentPageIndex];
	}
	
	[self _loadPagesToPreloadAroundPageAtIndex:self.currentPageIndex];
	
	_pageControlUsed = NO;
}

@end
