---
title: "Android.bp条件编译"
date: 2020-07-01T15:21:20+08:00
tags: [makefile]
categories: [Android]
---

Android的makefile越来越多的开始使用Android .bp，它的好处是编译速度快，计算依赖比Android.mk快速的多。

![Android编译系统](http://gityuan.com/images/android-p/soong.png)

但是，Android.bp添加条件编译是很麻烦的，需要借助go来实现。

# 无条件添加宏

Android.bp直接添加宏非常简单，只需要在cflags后面添加对应的宏就OK了。

```go
 cflags: ["-DXXX"] + [ // ANDROIDMK TRANSLATION ERROR: endif from unsupported contitional
    // endif
        "-Wno-error=implicit-function-declaration",
        "-DPRINT",
    ], 
```

# 有条件添加宏

添加go脚本

```go
package vold

import (
        "android/soong/android"
        "android/soong/cc"
        "fmt"
)

func init() {
    // for DEBUG
    fmt.Println("vold init start ")
    android.RegisterModuleType("vold_defaults", voldDefaultsFactory)
}

func voldDefaultsFactory() (android.Module) {
    module := cc.DefaultsFactory()
    android.AddLoadHook(module, voldDefaults)
    return module
}

func voldDefaults(ctx android.LoadHookContext) {
    type props struct {
        Cflags []string
    }
    p := &props{}
    p.Cflags = globalDefaults(ctx)
    ctx.AppendProperties(p)
}

func globalDefaults(ctx android.BaseContext) ([]string) {
    var cppflags []string

    fmt.Println("BUILD_WITH_SDCARD_READONLY:",
        ctx.AConfig().IsEnvTrue("BUILD_WITH_SDCARD_READONLY"))

    if ctx.AConfig().IsEnvTrue("BUILD_WITH_SDCARD_READONLY") {
          cppflags = append(cppflags, "-DSDCARD_READONLY=1")
    }

    return cppflags
}

```

Android.bp修改

```go
vold_defaults {
    name: "vold_defaults",
    defaults: [ "vold_default_flags" ],
}

bootstrap_go_package {
    name: "soong-vold",
    pkgPath: "android/soong/vold",
    deps: [
        "blueprint",
        "blueprint-pathtools",
        "soong",
        "soong-android",
        "soong-cc",
        "soong-genrule",
    ],  
    srcs: [
        "vold.go",
    ],  
    pluginFor: ["soong_build"],
}

cc_library_static {
    name: "libvold",
    defaults: [        
        "vold_default_libs",
        "vold_defaults",  // 添加依赖
    ],
```

go是从init开始运行的，它其实只是注册了XXXDefaultFactory对象，然后添加hook，在里面判断环境变量，然后赋值给cppflags，逻辑还是很清晰的。

