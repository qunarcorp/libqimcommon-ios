//
//  QIMDBLogger.h
//  QIMCommon
//
//  Created by 李露 on 10/11/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAbstractDatabaseLogger.h"

@class DatabaseOperator;

@interface QIMDBLogger : DDAbstractDatabaseLogger <DDLogger>
{
    @private
    NSString *logDirectory;
    NSMutableArray *pendingLogEntries;
    DatabaseOperator *dbOperator;
}

- (id)initWithLogDirectory:(NSString *)logDirectory WithDBOperator:(DatabaseOperator *)dbOperator;

@end
