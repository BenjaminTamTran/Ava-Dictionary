//
//  MNMediaManagement.h
//  Mana portal
//
//  Created by Tam Tran on 2/7/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNLeftViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MNMediaManagement : NSObject<UIImagePickerControllerDelegate,AVAudioPlayerDelegate>{
    NSURL *url;
}
@property(nonatomic,retain) NSURL *url;
- (NSString *) processRESTRequest:(NSString *)request;
- (NSString *) setVolumn:(NSMutableDictionary*)params;
- (NSString *) registerState:(NSMutableDictionary*)params;
- (NSString *) playMP3:(NSMutableDictionary*)params;
- (NSString *) stopmp3;
- (NSString *) pausemp3;
- (NSString *) resumemp3;
- (NSString *) getVolumn;
- (NSString *) getState;
- (NSString *) openCamera;
@end
