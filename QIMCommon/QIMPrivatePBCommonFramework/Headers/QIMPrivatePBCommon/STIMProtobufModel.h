//
// Created by may on 2017/2/28.
// Copyright (c) 2017 May. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STIMGCDMulticastDelegate.h"
@class STIMPBStream;

@interface STIMProtobufModel : NSObject {
    STIMPBStream *pbstream;
    
    dispatch_queue_t moduleQueue;
    void *moduleQueueTag;
    
    id multicastDelegate;
}

@property(readonly) dispatch_queue_t moduleQueue;
@property(readonly) void *moduleQueueTag;

@property(strong, readonly) STIMPBStream *pbstreamPBStream;

- (id)init;

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (BOOL)activate:(STIMPBStream *)protobufStream;

- (void)deactivate;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously;

- (NSString *)moduleName;
@end
