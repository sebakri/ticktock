# Changelog

## [1.1.1](https://github.com/sebakri/ticktock/compare/v1.1.0...v1.1.1) (2026-02-17)


### Features

* add option to show current task in tray menu ([1b01ad9](https://github.com/sebakri/ticktock/commit/1b01ad9203cee1cca96a3583d707544c383b6541))
* implement macOS menu bar tray and multi-tag filtering ([f461164](https://github.com/sebakri/ticktock/commit/f461164c92090bf9f2375f1d9a7a345a0b390ba3))
* persist selected tag filters across sessions ([8b90ac7](https://github.com/sebakri/ticktock/commit/8b90ac793578c7c058d8c869ea4a9c9e3884e083))
* use monochrome template tray icon for macOS ([12ddc60](https://github.com/sebakri/ticktock/commit/12ddc60957e3ca6a6783475c97f19704729120ca))


### Bug Fixes

* correct tray icon monochrome rendering for macOS ([cb89cf9](https://github.com/sebakri/ticktock/commit/cb89cf97217fda4f815243b7fca9c0b41601ef6e))
* correctly bundle icons and enable dark mode logic ([6997566](https://github.com/sebakri/ticktock/commit/6997566e0f2bb654cfdfb62feabe15fa3ec5833a))
* ensure robust global hotkey registration and add verification test ([b531bcd](https://github.com/sebakri/ticktock/commit/b531bcd531427ed441aa0c637d8b1477eed630df))
* ensure tray icon has transparent background ([9734728](https://github.com/sebakri/ticktock/commit/9734728d848148567c7a43f58556a1721d8e7464))
* resolve test failures and layout overflow in custom time picker ([e6a762a](https://github.com/sebakri/ticktock/commit/e6a762a4628e0b89de3810f724c92e885d116202))

## [1.1.0](https://github.com/sebakri/ticktock/compare/v1.0.0...v1.1.0) (2026-02-04)


### Features

* add support for task tags and tag-based filtering, and switch to 24h time format ([4c21d0d](https://github.com/sebakri/ticktock/commit/4c21d0d8ac30b81025e5df76718bdfa7b279a85f))
* implement auto-releasing via conventional commits and release-please ([2b60fa2](https://github.com/sebakri/ticktock/commit/2b60fa2374adca8ad0130a61d7b7594926afc6d5))
* start app with minimal width (400px) and enforce minimum size constraints ([f6e8c51](https://github.com/sebakri/ticktock/commit/f6e8c51a77296332f8fda6625eebfc47f293fec9))
* toggle tracking now toggles the last active task ([e0834b7](https://github.com/sebakri/ticktock/commit/e0834b702fab265227a13ab62967644461cd7269))
* use 24h time format for session time blocks ([01f7eff](https://github.com/sebakri/ticktock/commit/01f7eff2aa02f39ca5aa64162c210d6faa7774ea))


### Bug Fixes

* use perfectly equally spaced timeline labels with fixed count distribution ([cf7ab51](https://github.com/sebakri/ticktock/commit/cf7ab516bebbf93b74df588fd9bde02f890be012))
