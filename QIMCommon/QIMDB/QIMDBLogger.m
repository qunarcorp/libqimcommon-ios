//
//  QIMDBLogger.m
//  QIMCommon
//
//  Created by 李露 on 10/11/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMDBLogger.h"
//#import "DataBase.h"
#import "QIMPublicRedefineHeader.h"

@interface QIMDBLogger ()

- (void)validateLogDirectory;

@end

@interface QIMDBLogEntry : NSObject {
@public
    NSNumber * context;
    NSNumber * level;
    NSString * message;
    NSDate   * timestamp;
}

- (id)initWithLogMessage:(DDLogMessage *)logMessage;

@end

@implementation QIMDBLogEntry

- (id)initWithLogMessage:(DDLogMessage *)logMessage {
    if (self = [super init]) {
        context   = @(logMessage->_context);
        level     = @(logMessage->_flag);
        message   = logMessage->_message;
        timestamp = logMessage->_timestamp;
    }
    return self;
}

@end

@implementation QIMDBLogger

- (id)initWithLogDirectory:(NSString *)aLogDirectory WithDBOperator:(DatabaseOperator *)DBOperator;
{
    if ((self = [super init]))
    {
        dbOperator = DBOperator;
        logDirectory = [aLogDirectory copy];
        
        pendingLogEntries = [[NSMutableArray alloc] initWithCapacity:3];
        
        [self validateLogDirectory];
    }
    
    return self;
}

- (void)validateLogDirectory
{
    // Validate log directory exists or create the directory.
    
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:logDirectory isDirectory:&isDirectory])
    {
        if (!isDirectory)
        {
            QIMVerboseLog(@"%@: %@ - logDirectory(%@) is a file!", [self class], THIS_METHOD, logDirectory);
            
            logDirectory = nil;
        }
    }
    else
    {
        NSError *error = nil;
        
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:logDirectory
                                                withIntermediateDirectories:YES
                                                                 attributes:nil
                                                                      error:&error];
        if (!result)
        {
            QIMVerboseLog(@"%@: %@ - Unable to create logDirectory(%@) due to error: %@",
                  [self class], THIS_METHOD, logDirectory, error);
            
            logDirectory = nil;
        }
    }
}

#pragma mark AbstractDatabaseLogger Overrides

- (BOOL)db_log:(DDLogMessage *)logMessage
{
    // You may be wondering, how come we don't just do the insert here and be done with it?
    // Is the buffering really needed?
    //
    // From the SQLite FAQ:
    //
    // (19) INSERT is really slow - I can only do few dozen INSERTs per second
    //
    // Actually, SQLite will easily do 50,000 or more INSERT statements per second on an average desktop computer.
    // But it will only do a few dozen transactions per second. Transaction speed is limited by the rotational
    // speed of your disk drive. A transaction normally requires two complete rotations of the disk platter, which
    // on a 7200RPM disk drive limits you to about 60 transactions per second.
    //
    // Transaction speed is limited by disk drive speed because (by default) SQLite actually waits until the data
    // really is safely stored on the disk surface before the transaction is complete. That way, if you suddenly
    // lose power or if your OS crashes, your data is still safe. For details, read about atomic commit in SQLite.
    //
    // By default, each INSERT statement is its own transaction. But if you surround multiple INSERT statements
    // with BEGIN...COMMIT then all the inserts are grouped into a single transaction. The time needed to commit
    // the transaction is amortized over all the enclosed insert statements and so the time per insert statement
    // is greatly reduced.
    
    QIMDBLogEntry *logEntry = [[QIMDBLogEntry alloc] initWithLogMessage:logMessage];
    
    [pendingLogEntries addObject:logEntry];
    
    // Return YES if an item was added to the buffer.
    // Return NO if the logMessage was ignored.
    
    return YES;
}

- (void)db_save
{
    if ([pendingLogEntries count] == 0)
    {
        // Nothing to save.
        // The superclass won't likely call us if this is the case, but we're being cautious.
        return;
    }
    /* Mark DBUpadte
    [dbOperator syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSString *cmd = @"INSERT INTO logs (context, level, message, timestamp) VALUES (?, ?, ?, ?)";
        NSMutableArray *params = [[NSMutableArray alloc] init];
        for (QIMDBLogEntry *logEntry in self->pendingLogEntries) {
            NSMutableArray *param = [[NSMutableArray alloc] initWithCapacity:1];
            if (logEntry->context && logEntry->message && logEntry->timestamp) {
                [param addObject:logEntry->context];
                [param addObject:logEntry->level];
                [param addObject:logEntry->message];
                [param addObject:logEntry->timestamp];
                [params addObject:param];
            }
        }
        BOOL result = [database executeBulkInsert:cmd withParameters:params];
        if (!result) {
            QIMVerboseLog(@"Error inserting log entries");
        }
    }];
    */
    
    /*
    BOOL saveOnlyTransaction = ![database inTransaction];
    
    if (saveOnlyTransaction)
    {
        [database beginTransaction];
    }
    
    NSString *cmd = @"INSERT INTO logs (context, level, message, timestamp) VALUES (?, ?, ?, ?)";
    
    for (QIMDBLogEntry *logEntry in pendingLogEntries)
    {
        
        [database executeUpdate:cmd, logEntry->context,
         logEntry->level,
         logEntry->message,
         logEntry->timestamp];
    }
    
    [pendingLogEntries removeAllObjects];
    
    if (saveOnlyTransaction)
    {
        [database commit];
        
        if ([database hadError])
        {
            QIMVerboseLog(@"%@: Error inserting log entries: code(%d): %@",
                  [self class], [database lastErrorCode], [database lastErrorMessage]);
        }
    }
    */
}

- (void)db_delete
{
    if (_maxAge <= 0.0)
    {
        // Deleting old log entries is disabled.
        // The superclass won't likely call us if this is the case, but we're being cautious.
        return;
    }
    /* Mark DBUpdate
    [dbOperator syncUsingTransaction:^(QIMDataBase* _Nonnull database, BOOL * _Nonnull rollback) {
        NSDate *maxDate = [NSDate dateWithTimeIntervalSinceNow:(-1.0 * _maxAge)];
        NSString *deleteCMD = [NSString stringWithFormat:@"DELETE FROM logs WHERE timestamp < ?", maxDate];
        [database executeNonQuery:deleteCMD withParameters:nil];
    }];
    */
}

- (void)db_saveAndDelete
{
    [self db_delete];
    [self db_save];
    /*
    [database beginTransaction];
    
    [self db_delete];
    [self db_save];
    
    [database commit];
    
    if ([database hadError])
    {
        QIMVerboseLog(@"%@: Error: code(%d): %@",
              [self class], [database lastErrorCode], [database lastErrorMessage]);
    }
    */
}


@end
