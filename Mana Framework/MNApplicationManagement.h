//
//  MNApplicationManagement.h
//  Mana Framework
//
//  Created by Tam Tran on 2/20/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MNApplicationManagement : NSObject<MFMessageComposeViewControllerDelegate>{
    
}

- (NSString *) processRESTRequest:(NSString *)request withparams:(NSMutableDictionary *)params;
- (NSString *) exitApplication;
- (NSString *) sendSMS:(NSMutableDictionary*)params;
- (NSString *) executejs:(NSMutableDictionary*)params;
@end
