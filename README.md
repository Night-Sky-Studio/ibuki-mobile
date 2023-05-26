<div align="center"><img src="docs/img/Ibuki logo.png" alt="Ibuki" height="256px"></img></div>
<h1 align="center">Ibuki</h1>
<p align="center">An ultimate, fully customizable Booru browser app for. Now in your phone.</p>

---
## What is the difference?
Unlike all the Booru applications out there where developer decided beforehand which Boorus are available to user, **Ibuki** is highly customizeable. You can yourself add whatever Booru out there to the **Ibuki** and it will display pictures from that Booru and retain full functionality (as long that Booru has a public REST API, of course). The application consumes a script file that has only one purpose - connect to the Booru API and return objects so even you with a bit of time can grab a Booru from *booru.org* and create a wrapper script for its API.

---
## Contribution
You are free to make any pull requests and code changes you want (as long it's within the licence), but keep in mind, that I'm working solo on this project in my spare time, so it would take a lot of time for me to review all the pull requests out there.

Ibuki is written in **C#** using **Visual Studio 2019** and **Xamarin Native** with heavy reliance on **IbukiBooruLibrary**. If you're using **Rider** (lucky you) or any other IDE, then please be careful with all the files that your IDE leaves behind. I have excluded most of the temp files via gitgnore, but may have left something behind...
