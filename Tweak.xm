/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

%hook ClassName

// Hooking a class method
+ (id)sharedInstance {
	return %orig;
}

// Hooking an instance method with an argument.
- (void)messageName:(int)argument {
	%log; // Write a message about this call, including its class, name and arguments, to the system log.

	%orig; // Call through to the original function with its original arguments.
	%orig(nil); // Call through to the original function with a custom argument.

	// If you use %orig(), you MUST supply all arguments (except for self and _cmd, the automatically generated ones.)
}

// Hooking an instance method with no arguments.
- (id)noArguments {
	%log;
	id awesome = %orig;
	[awesome doSomethingElse];

	return awesome;
}

// Always make sure you clean up after yourself; Not doing so could have grave consequences!
%end
*/


NSString *jsCode = @""
""
"function isTexImage(object) {\n"
"    var src = $(object).attr('src')\n"
"    return (src != undefined && src.startsWith('http://zhihu.com/equation'))\n"
"}\n"
"\n"
"function imgToTex() {\n"
"    var images = $('img');\n"
"    //var images = document.getElementsByTagName('img');\n"
""
"    var texImages = []\n"
"    var l = images.length;\n"
"    for (var i = 0; i < l; i++) {\n"
"        var object = images[i];\n"
"        if (isTexImage(object)) {\n"
"            texImages.push(object);\n"
"        }\n"
"    }\n"
""
"    texImages.forEach(function(object) {\n"
"        var tex = $(object).attr('alt')\n"
"        if (tex.indexOf('=') > -1 && tex.length > 4 ) {   \n"
"          // if contains '=', we put it in its own line \n"
"          if (object.previousSibling.tagName == 'BR') {      \n"
"              $(object.previousSibling).remove()             \n"
"          }                                              \n"
"          if (object.nextSibling.tagName == 'BR') {      \n"
"              $(object.nextSibling).remove()             \n"
"          }                                              \n"
"          $(object).replaceWith( ' \\\\[' + tex + '\\\\] ') \n"
"                                                         \n"
"        } else {                                        \n"
"          // or just inline                             \n"
"          $(object).replaceWith( ' \\\\(' + tex + '\\\\) ') \n"
"        }                                               \n"
"    });\n"
""
"}\n"
""
""
"function loadJS(url) {    \n"
"    var head = document.getElementsByTagName('head')[0];    \n"
"    var js = document.createElement('script');    \n"
"    js.setAttribute('type', 'text/javascript');    \n"
"    js.setAttribute('src', url);    \n"
"    head.appendChild(js);    \n"
"}    \n"
""
"$(document).ready(function(){\n"
"    var math_jax_src = 'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_SVG';\n"
"    imgToTex(); \n"
""
"    var head = document.getElementsByTagName('head')[0];    \n"
"    var js = document.createElement('script');    \n"
"    js.setAttribute('type', 'text/x-mathjax-config');    \n"
"    js.innerHTML = 'MathJax.Hub.Config({ SVG: { scale: 80, linebreaks: { automatic: true } }});';    \n"
"    head.appendChild(js);    \n"
""
"    loadJS(math_jax_src);          \n"
"})\n"
;

@interface ZHAvatarButton : UIWebView
@end


@interface ZHAnswerView : NSObject {} // We take NSObject here as to avoid any errors.
@property (nonatomic, strong, readwrite) UIWebView *contentWebView;
@end

%hook ZHAnswerView

- (void)bindWithObject:(id)arg1 visualContent:(id)arg2 userObjectID:(id)arg3 {
    
    %orig;
    // inject js
    %log(jsCode);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.contentWebView stringByEvaluatingJavaScriptFromString:jsCode];
    });
}

%end

@interface ZHArticleView : NSObject {} // We take NSObject here as to avoid any errors.
@property (nonatomic, strong, readwrite) UIWebView *contentWebView;
@end

%hook ZHArticleView

- (void)bindWithObject:(id)arg1 visualContent:(id)arg2 userObjectID:(id)arg3 {
    
    %orig;
    // inject js
    [self.contentWebView stringByEvaluatingJavaScriptFromString:jsCode];
}

%end



