Using the Vzaar Framework Binary
================================

Using pre-compiled framework binaries is the preferred way
to use the Vzaar framework in your application. However, if 
you'd like to include the raw source code directly in your 
application, see "Using the Vzaar Source" below.

To compile the Vzaar framework for Mac OS X and iPhone OS,
compile the "Vzaar Framework Distribution" target with the 
"Base SDK" and "Release" settings.

This will give a folder called "Vzaar-Release" in the project's 
build folder, containing four files:

- Vzaar.framework: The Mac OS X Framework
- libVzaar.a: The iPhone OS static library
- Vzaar.h: Headers for use with the iPhone OS library

Using the Mac OS X Framework
----------------------------

Add the Vzaar.framework bundle to your Xcode project. Next,
find your application in the Targets list, right-click and
choose Add > New Build Phase > New Copy Files Build Phase.
Double-click this new build phase and set the destination to 
Frameworks. Finally, drag the Vzaar framwork from wherever it 
is in your Xcode files list to this new build phase. 

Vzaar.framework will now be embedded in your application when
you build your app. To use Vzaar in code, #import <Vzaar/Vzaar.h>.

Using the iPhone OS Static Library
----------------------------------

Add the libVzaar.a and Vzaar.h files to 
your Xcode project. Next, find your application in the Targets 
list, right-click and choose Add > New Build Phase > 
New Copy Files Build Phase. Double-click this new build phase 
and set the destination to Frameworks. Finally, drag libVzaar.a
from wherever it is in your Xcode files list to this new build phase. 

Next, you need to link your application to the iPhone OS compenents 
libVzaar uses. To do this, right-click your application in the 
"Targets" list, choose Get Info and make sure the General tab is selected.
In the bottom "Linked Libraries" pane, click the '+' button and add the
following framworks:

- libz.dylib
- libxml2.dylib
- CFNetwork.framework
- MobileCoreServices.framework
- SystemConfiguration.framework

Finally, in the Get Info window, switch to the "Build" tab and add the
following flags to the "Other Linker Flags" setting:

"-ObjC"
"-all_load"

The Vzaar library will now be embedded and linked to your application
when you build your app. To use Vzaar in code, #import "Vzaar.h".

Using the Vzaar Source
======================

To use the Vzaar source in your application, add the entire contents 
of the "src" folder to your Xcode project, making sure the files are
added to the correct target(s). If you're using Mac OS X, you can safely
remove the Reachability and ASIAuthenticationDialog classes.

Next, you need to link your application to the required system frameworks.
To do this, right-click your application in the "Targets" list, choose 
Get Info and make sure the General tab is selected. In the bottom 
"Linked Libraries" pane, click the '+' button and add the following 
framworks for your target operating system as listed below.

Finally, get info on your application's target and add 
"/usr/include/libxml2" to the "Header Search Paths" setting.

You can then use Vzaar in your code with #import "Vzaar.h".

iPhone OS Linked Frameworks
---------------------------

- libz.dylib
- libxml2.dylib
- CFNetwork.framework
- MobileCoreServices.framework
- SystemConfiguration.framework

Mac OS X Linked Frameworks
--------------------------

- Foundation.framework
- SystemConfiguration.framework
- CoreServices.framework
- libz.dylib
- libxml2.dylib