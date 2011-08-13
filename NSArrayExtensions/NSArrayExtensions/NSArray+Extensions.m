// TODO: (ns): throw exceptions within functions if fn == nil
// TODO: (ns): make sure my library doesn't throw exceptions for weird array or fn input

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

#pragma mark - Private Functions

-(NSArray*)filter:(BOOL(^)(id obj))fn stopOnFind:(BOOL)stopOnFind
{
    __block NSMutableArray* filtered = [[[NSMutableArray alloc] init] autorelease];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (fn(obj))
        {
            [filtered addObject:obj];
            *stop = stopOnFind;
        }
    }];
    
    return filtered;
}

#pragma mark - Public Functions

-(BOOL)all:(BOOL(^)(id obj))fn
{    
    __block BOOL all = true;
    
    [self each:^(id obj) {
        all = all && fn(obj);
    }];
    
    return all;
}

-(BOOL)any:(BOOL(^)(id obj))fn
{
    return [[self contains:fn] autorelease];
}

-(NSArray*)collect:(id(^)(id obj))fn
{
    return [[self map:fn] autorelease];
}

-(BOOL)contains:(BOOL(^)(id obj))fn
{
    return [self count:fn] > 0;
}

-(NSUInteger)count:(BOOL(^)(id obj))fn
{
    __block NSUInteger count = 0;
    
    [self each:^(id obj) {
        if (fn(obj))
        {
            count++;
        }
    }];
    
    return count;
}

-(id)detect:(BOOL(^)(id obj))fn
{
    return [[self find:fn] autorelease];
}

-(NSArray*)drop:(NSUInteger)n
{
    __block NSMutableArray* notDropped = [[[NSMutableArray alloc] init] autorelease];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx >= n)
        {
            [notDropped addObject:obj];
        }
    }];
    
    return notDropped;
}

-(void)each:(void(^)(id obj))fn
{
    [self eachWithIndex:^(id obj, NSUInteger index) {
        fn(obj);
    }];
}

-(void)eachWithIndex:(void(^)(id obj, NSUInteger index))fn
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        fn(obj, idx);
    }];
}

-(NSArray*)filter:(BOOL(^)(id obj))fn
{
    return [[self filter:fn stopOnFind:NO] autorelease];
}

-(id)find:(BOOL(^)(id obj))fn
{
    NSArray* found = [self filter:fn stopOnFind:YES];
    return [found count] > 0 ? [found first] : nil;
}

-(NSArray*)findAll:(BOOL(^)(id obj))fn
{
    return [[self filter:fn] autorelease];
}

-(NSInteger)findIndex:(BOOL(^)(id obj))fn
{
    __block NSUInteger index = -1;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (fn(obj))
        {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

-(id)first
{
    return [self count] ? [self objectAtIndex:0] : nil;
}

-(NSArray*)first:(NSUInteger)n
{
    // TODO: (ns): Check for negative elements and error out if n < 0?
    
    __block NSMutableArray* firsts = [[[NSMutableArray alloc] init] autorelease];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        *stop = !(idx < n);
        if (!(*stop))
        {
            [firsts addObject:obj];
        }
    }];
    
    return firsts;
}

-(id)foldl:(id) acc fn:(id(^)(id acc, id obj))fn
{
    return [[self reduce:acc fn:fn] autorelease];
}

-(NSDictionary*)groupBy:(id(^)(id obj))fn
{    
    __block NSMutableDictionary* groups = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self each:^(id obj) {
        id key = fn(obj);
        NSMutableArray* val = (NSMutableArray*)[groups objectForKey:key];
        if (val == nil)
        {
            val = [[NSMutableArray alloc] initWithObjects:obj, nil];
            [groups setValue:val forKey:key];
        }
        else
        {
            [val addObject:obj];
        }
    }];
    
    return groups;
}

-(id)inject:(id) acc fn:(id(^)(id acc, id obj))fn
{
    return [[self reduce:acc fn:fn] autorelease];
}

-(NSArray*)map:(id(^)(id obj))fn
{
    __block NSMutableArray* map = [[[NSMutableArray alloc] initWithCapacity:[self count]] autorelease];
    
    [self each:^(id obj) {
        [map addObject:fn(obj)];
    }];
    
    return map;
}

-(BOOL)none:(BOOL(^)(id obj))fn
{
    return [self count:fn] == 0;
}

-(BOOL)one:(BOOL(^)(id obj))fn
{
    return [self count:fn] == 1;
}

-(NSArray*)partition:(BOOL(^)(id obj))fn
{
    __block NSMutableArray* trueVals = [[NSMutableArray alloc] init];
    __block NSMutableArray* falseVals = [[NSMutableArray alloc] init];
    
    [self each:^(id obj) {
        if (fn(obj))
        {
            [trueVals addObject:obj];
        }
        else
        {
            [falseVals addObject:obj];
        }
    }];
    
    NSArray* allVals = [[NSArray arrayWithObjects:trueVals, falseVals, nil] autorelease];
    
    return allVals;
}

-(id)reduce:(id) acc fn:(id(^)(id acc, id obj))fn
{
    // TODO: (ns): there is probably a memory leak in this function.
    __block id blockAcc = acc;
    [self each:^(id obj) {
        blockAcc = [fn(blockAcc, obj) retain];
    }];

    return [blockAcc autorelease];
}

-(NSArray*)select:(BOOL(^)(id obj))fn
{
    return [[self filter:fn] autorelease];
}

-(NSArray*)sort:(NSComparisonResult(^)(id obj1, id obj2))fn
{
    return [[self sortedArrayUsingComparator:fn] autorelease];
}

-(NSArray*)sortBy:(id(^)(id obj))fn
{
    // Sort in ascending order based on compare function.
    return [[self sort:^NSComparisonResult(id obj1, id obj2) {
        return [fn(obj1) compare:fn(obj2)];
    }] autorelease];
}

-(NSArray*)take:(NSUInteger)n
{
    return [[self first:n] autorelease];
}

-(NSArray*)takeWhile:(BOOL(^)(id obj))fn
{
    __block NSMutableArray* take = [[[NSMutableArray alloc] init] autorelease];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        *stop = !fn(obj);
        if (!(*stop))
        {
            [take addObject:obj];
        }
    }];
    
    return take;
}

-(NSArray*)unique:(id(^)(id obj))fn
{
    __block NSMutableDictionary* uniques = [[[NSMutableDictionary alloc] init] autorelease];
    
    [self each:^(id obj) {
        if ([uniques objectForKey:obj] == nil)
        {
            [uniques setValue:obj forKey:obj];
        }
    }];
    
    return [uniques allKeys];
}

@end