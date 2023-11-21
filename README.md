
Alice is an HTTP Inspector tool for Flutter which helps debugging http requests.
---

This package is light version of Alice https://github.com/jhomlala/alice 


**Features:**  
✔️ Detailed logs for each HTTP calls (HTTP Request, HTTP Response)  
✔️ Inspector UI for viewing HTTP calls  
✔️ Statistics  
✔️ HTTP calls search


## Usage
### Alice configuration
1. Create Alice instance:

```dart
Alice alice = Alice();
```

2. Add navigator key to your application:

```dart
MaterialApp( 
    navigatorKey: alice.getNavigatorKey(), 
    home: ...
)
```

You need to add this navigator key in order to show inspector UI.
You can use also your navigator key in Alice:

```dart
Alice alice = Alice(navigatorKey: yourNavigatorKeyHere);
```

If you need to pass navigatorKey lazily, you can use:
```dart
alice.setNavigatorKey(yourNavigatorKeyHere);
```
This is minimal configuration required to run Alice. Can set optional settings in Alice constructor.


### HTTP Client configuration
If you're using Dio, you just need to add interceptor.

```dart
Dio dio = Dio();
dio.interceptors.add(alice.getDioInterceptor());
```

## Show inspector

```dart
alice.showInspector();
```