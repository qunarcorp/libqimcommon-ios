//
//  QIMDatasourceItem.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/30.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMDatasourceItem.h"

@implementation QIMDatasourceItem

-(void)addChildNodesItem:(QIMDatasourceItem *)childNodes withChildDP:(NSString *)dp {
    if (self.childNodesDict == nil) {
        self.childNodesDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    [self.childNodesDict setObject:childNodes forKey:dp];
}

-(NSMutableArray *)expand {
    return [self.childNodesDict allKeys];
}



- (NSString *)description {
    return [NSString stringWithFormat:@"nodeName : %@, childs: %@", self.nodeName, self.childNodesDict];
    //    NSLog(@"nodeName : %@, childs: %@", self.nodeName, self.childNodesArray);
}

@end
