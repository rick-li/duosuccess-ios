#import "IntroModel.h"

@implementation IntroModel

@synthesize titleText;
@synthesize descriptionText;
@synthesize imageUrl;

- (id) initWithTitle:(NSString*)title description:(NSString*)desc imageUrl:(NSString*)imageUrl {
    self = [super init];
    if(self != nil) {
        titleText = title;
        descriptionText = desc;
        self.imageUrl = imageUrl;
    }
    return self;
}

@end
