//
//  QIMManager+Helper.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMManager+Helper.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QIMPrivateHeader.h"

@implementation QIMManager (Helper)
static SystemSoundID _ringSystemSoundID;

- (void)playHongBaoSound {
    if (![self isNewMsgNotify] && ![self isNewMsgVibrate]) {
        return;
    }
    if ([self isNewMsgVibrate]) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    if ([self isNewMsgNotify]) {
        UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
        if (applicationState == UIApplicationStateActive) {
            // 非租车业务才播放声音
            SystemSoundID soundID;
            // 读文件获取SoundID
            NSString *filePath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"hongbao" ofType:@"aac"];
            if (filePath != nil) {
                
                //声音
                AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:filePath], &soundID);
                AudioServicesPlaySystemSound(soundID);
            }
        }
    }
}

void ringStopRing()
{
    if (_ringSystemSoundID != 0) {
        //移除系统播放完成后的回调函数
        AudioServicesRemoveSystemSoundCompletion(_ringSystemSoundID);
        //销毁创建的SoundID
        AudioServicesDisposeSystemSoundID(_ringSystemSoundID);
        _ringSystemSoundID = 0;
    }
}

static void ringAudioServicesSystemSoundCompletionProc(SystemSoundID ssID, void *clientData)
{
    ringStopRing();
}

- (void)playSound {
    
    if (![self isNewMsgNotify] && ![self isNewMsgVibrate]) {
        return;
    }
    
    if ([self isNewMsgVibrate]) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    if ([self isNewMsgNotify]) {
        static NSTimeInterval lastPlay;
        
        if ([[NSDate date] timeIntervalSince1970] - lastPlay > 2.0) {
            UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
            if (applicationState == UIApplicationStateActive) {
                NSString *soundName = [[QIMManager sharedInstance] soundName];
                if (!soundName) {
                    // 非租车业务才播放声音
                    SystemSoundID soundID;
                    // 读文件获取SoundID

                    NSString *filePath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"msg" ofType:@"wav"];
                    if (filePath != nil) {
                        //声音
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient
                                                               error:nil];
                        AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:filePath], &_ringSystemSoundID);
                        AudioServicesAddSystemSoundCompletion(_ringSystemSoundID, NULL, NULL, ringAudioServicesSystemSoundCompletionProc, NULL);
                        //通过创建的soundID打开对应的音频文件
                        AudioServicesPlayAlertSound(_ringSystemSoundID);
                    }
                } else {
                    if ([soundName isEqualToString:@"default"]) {
                        //定义一个SystemSoundID
                        //http://iphonedevwiki.net/index.php/AudioServices
                        // 非租车业务才播放声音
                        SystemSoundID soundID;
                        // 读文件获取SoundID
                        NSString *soundFirstName = [[soundName componentsSeparatedByString:@"."] firstObject];
                        NSString *soundLastName = [[soundName componentsSeparatedByString:@"."] lastObject];
                        NSString *filePath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:@"in" ofType:@"caf"];
                        if (filePath != nil) {
                            //声音
                            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient
                                                                   error:nil];
                            AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:filePath], &_ringSystemSoundID);
                            AudioServicesAddSystemSoundCompletion(_ringSystemSoundID, NULL, NULL, ringAudioServicesSystemSoundCompletionProc, NULL);
                            //通过创建的soundID打开对应的音频文件
                            AudioServicesPlayAlertSound(_ringSystemSoundID);
                        }
                    } else {
                        // 非租车业务才播放声音
                        SystemSoundID soundID;
                        // 读文件获取SoundID
                        NSString *soundFirstName = [[soundName componentsSeparatedByString:@"."] firstObject];
                        NSString *soundLastName = [[soundName componentsSeparatedByString:@"."] lastObject];
                        NSString *filePath = [NSBundle qim_myLibraryResourcePathWithClassName:@"QIMCommonResource" BundleName:@"QIMCommonResource" pathForResource:soundFirstName ofType:soundLastName];
                        if (filePath != nil) {
                            //声音
                            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient
                                                                   error:nil];
                            AudioServicesCreateSystemSoundID((__bridge CFURLRef) [NSURL fileURLWithPath:filePath], &_ringSystemSoundID);
                            AudioServicesAddSystemSoundCompletion(_ringSystemSoundID, NULL, NULL, ringAudioServicesSystemSoundCompletionProc, NULL);
                            //通过创建的soundID打开对应的音频文件
                            AudioServicesPlayAlertSound(_ringSystemSoundID);
                        }
                    }
                }
            }
            lastPlay = [[NSDate date] timeIntervalSince1970];
        }
    }
}

/**
 *  窗口抖动
 */
- (void)shockWindow:(int)shockCount {
    UIView *rootView = [[[[[UIApplication sharedApplication] delegate] window] rootViewController] view];
    [UIView animateWithDuration:0.02 animations:^{
        CGRect frame = rootView.frame;
        switch (shockCount % 4) {
            case 0: {
                frame.origin.x -= 2;
                frame.origin.y += 2;
            }
                break;
            case 1: {
                frame.origin.x += 2;
                frame.origin.y -= 2;
            }
                break;
            case 2: {
                frame.origin.x += 2;
                frame.origin.y += 2;
            }
                break;
            case 3: {
                frame.origin.x -= 2;
                frame.origin.y -= 2;
            }
                break;
            default:
                break;
        }
        [rootView setFrame:frame];
    }                completion:^(BOOL finished) {
        if (shockCount < 40) {
            if (shockCount % 10 == 0) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            [self shockWindow:shockCount + 1];
        } else {
            CGRect frame = rootView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            [rootView setFrame:frame];
        }
    }];
}

- (void)shockWindow {
    [self shockWindow:0];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        NSError *error = nil;
        BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        if (!success) {
            QIMErrorLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    return NO;
}

@end
