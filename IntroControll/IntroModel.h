#import <Foundation/Foundation.h>

@interface IntroModel : NSObject

@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *descriptionText;
@property (nonatomic, strong) NSString *imageUrl;

- (id) initWithTitle:(NSString*)title description:(NSString*)desc imageUrl:(NSString*)imageUrl;

@end
