@class NSArray;

@interface CalendarOccurrencesCollection : NSObject <NSCopying> {
	
	NSArray* _occurrences;
	NSArray* _allDayOccurrences;
	NSArray* _timedOccurrences;
	
}

@property (nonatomic,readonly) NSArray * occurrences;                    //@synthesize occurrences=_occurrences - In the implementation block
@property (nonatomic,readonly) NSArray * allDayOccurrences;              //@synthesize allDayOccurrences=_allDayOccurrences - In the implementation block
@property (nonatomic,readonly) NSArray * timedOccurrences;               //@synthesize timedOccurrences=_timedOccurrences - In the implementation block
-(id)description;
-(id)copyWithZone:(NSZone*)arg1 ;
-(NSArray *)occurrences;
-(id)initWithOccurrences:(id)arg1 timedOccurrences:(id)arg2 allDayOccurrences:(id)arg3 ;
-(NSArray *)allDayOccurrences;
-(NSArray *)timedOccurrences;
@end
