---
layout: post
title:  "Preparing Angular application for AOT compilation"
date:   2017-04-11 00:17:59 +0100
categories: jekyll update
---


## Angular compilation


The subject of compilation is often regarded as something both incredibly important and incredibly boring.
However the basics of Angular compilation are quite simple and becoming familiar with them can provide a better understanding of how the framework works as a whole.

The role of the Angular compiler is to convert an Angular application - consisting of separate components and their corresponding templates - to code that can be run in a browser.
Behind the scenes, the compiler takes an ngModule and produces ngModuleFactory - a recipe on how to create a module. In the process of creating module factories, for every component declared in a module, the compiler creates corresponding component factories later used to produce component instances, when the application is actually being run.


Tobias Bosch (one of the authors of the Angular compiler) gave a [fantastic presentation](https://www.youtube.com/watch?v=kW9cJsvcsGo) on this subject at AngularConnect 2016, which I highly recommend to anyone looking to learn more details about how the compiler works internally.

Angular compiler supports two ways of compilation: ***Just in Time (JIT)*** which takes place at runtime and ***Ahead of Time (AOT)*** performed as a part of the build process.



## AOT benefits

Using AOT compilation has a number of benefits that can considerably improve application performance, so it’s highly recommended for builds intended to be pushed to production environments:

  

-   Reduced bundle size
Since the compilation takes place at a build time, there is no need to ship the source of Angular compiler with the application. Angular itself is a relatively large framework comparing to other popular alternatives such as React or Vue, so this is very important especially that the compiler is the largest part of the framework. The below screenshot shows the visual analysis of the vendor bundle from the project I’ve recently been working on. While the Angular framework took up 89% of the total vendor bundle size, the compiler represented approximately 45% of the framework.
    

![](/assets/posts/2/size_breakdown.png){: .center-block }

-   Reduced boot time
Since there is no need to compile the code at run time, the application is loaded quicker.
    
-   Fewer network requests
HTML templates and CSS stylesheets files are inlined into the bundle during the compilation phase, so they don’t need to be fetched separately.
    
-   Increased security
With HTML templates and components precompiled, there is no need to dynamically read and evaluate potentially insecure client side HTML and Javascript which makes AOT compilation less susceptible to injection attacks than JIT compilation.
    
-   Early template error detection
Compilation involves static analysis of HTML which can identify template errors before the build is produced and shipped.
    

  
  

## AOT Caveats

Due to its numerous benefits, there is little reason not to use AOT and thus it’s enabled by default for Angular CLI production build process. However what many developers may find surprising is that their application which was working perfectly fine during development, suddenly fails to compile when generating a production build.

  

Since the compilation is made ‘ahead of time’, without actually executing the application, the application code needs to be written in a way allowing the compiler to statically analyse it. The JIT compilation (default for development) is much more permissive in this respect allowing developers to write non-AOT compliant constructs. It’s definitely worth learning about these caveats in advance, to save time that would otherwise be spent refactoring when preparing the production build:

  
  
  
  
  

 - Default exports are not supported by AOT compilation
   
      ```js
    // Unsupported
    export default class FooComponent { }
    
    // Supported
    export class FooComponent { }
      ```
  

-   Any field used in a template, has to be marked as public. This includes the use of ***@Input***, ***@Output***, ***@ViewChild***, ***@ContentChild*** or ***@HostBinding***.

	
      ```js
    // Unsupported
    export class FooComponent {
        @Input()
        private exampleInput;
    }
    
    // Supported
    export class FooComponent {
        @Input()
        public exampleInput;
    }
      ```


  

-   Accessing form controls and errors should be done using ***form.get()*** and ***control.hasError()*** functions respectively:


      ```html
    /* Unsupported */
    <div *ngIf="control.errors?.invalidAddress">Invalid address</div>
    
    /* Supported */
    <div *ngIf="control.hasError('invalidAddress')">Invalid address</div>
      ```

  
  

-   Providers cannot be declared using lambda functions. This can be easily fixed by using exported functions instead:
    


      ```js
    // Unsupported
    @NgModule({
        providers: [
            { provide: BarService, useFactory: () => { new BarService() } },
        ]
    })
    export class FooModule { }
    
    // Supported
    export function fancyBarServiceFactory() {
        return new FancyBarService();
    }
    
    @NgModule({
        providers: [
            { provide: BarService, useFactory: fancyBarServiceFactory },
        ]
    })
    export class FooModule { }
      ```

<br />

----------

<br />

**EDIT**: Few months after writing this post, I discovered a project called [Codelyzer](https://github.com/mgechev/codelyzer) created by Minko Gechev of Angular Mobile. It’s basically a set of TSLint rules, that (among other things) checks if the code is written in an [AOT friendly manner](https://twitter.com/mgechev/status/777887201258381312).
