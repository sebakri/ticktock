# Changelog

## [1.1.1](https://github.com/sebakri/ticktock/compare/v1.1.0...v1.1.1) (2026-02-11)


### Features

* add option to show current task in tray menu ([8514283](https://github.com/sebakri/ticktock/commit/85142830fa8f24dd48b0583c87353aeab39e66e7))
* implement macOS menu bar tray and multi-tag filtering ([a7c42e8](https://github.com/sebakri/ticktock/commit/a7c42e88321397ba9f24049c7cdcaf393b273256))
* persist selected tag filters across sessions ([40ac16d](https://github.com/sebakri/ticktock/commit/40ac16d4fe83a753b991efed62bb470cad463ada))
* use monochrome template tray icon for macOS ([5515a12](https://github.com/sebakri/ticktock/commit/5515a12c8c341bce27872d14278291aef7e11d67))


### Bug Fixes

* correct tray icon monochrome rendering for macOS ([c90966f](https://github.com/sebakri/ticktock/commit/c90966f86d2ea2f2c6352ac5a698eaeb70c1c2fe))
* correctly bundle icons and enable dark mode logic ([4a1e2a5](https://github.com/sebakri/ticktock/commit/4a1e2a5d9cc9b7c8f0714516b8b7e65d337d0291))
* ensure robust global hotkey registration and add verification test ([0507849](https://github.com/sebakri/ticktock/commit/0507849ab1e0500433d13adce68e718045861a5b))
* ensure tray icon has transparent background ([a52a37f](https://github.com/sebakri/ticktock/commit/a52a37f0b138793a9c6dd0e6d113145f275099ba))
* resolve test failures and layout overflow in custom time picker ([da11be4](https://github.com/sebakri/ticktock/commit/da11be4d03682b2adc5d82a4270172c914654b07))

## [1.1.0](https://github.com/sebakri/ticktock/compare/v1.0.0...v1.1.0) (2026-02-04)


### Features

* add support for task tags and tag-based filtering, and switch to 24h time format ([4c21d0d](https://github.com/sebakri/ticktock/commit/4c21d0d8ac30b81025e5df76718bdfa7b279a85f))
* implement auto-releasing via conventional commits and release-please ([2b60fa2](https://github.com/sebakri/ticktock/commit/2b60fa2374adca8ad0130a61d7b7594926afc6d5))
* start app with minimal width (400px) and enforce minimum size constraints ([f6e8c51](https://github.com/sebakri/ticktock/commit/f6e8c51a77296332f8fda6625eebfc47f293fec9))
* toggle tracking now toggles the last active task ([e0834b7](https://github.com/sebakri/ticktock/commit/e0834b702fab265227a13ab62967644461cd7269))
* use 24h time format for session time blocks ([01f7eff](https://github.com/sebakri/ticktock/commit/01f7eff2aa02f39ca5aa64162c210d6faa7774ea))


### Bug Fixes

* use perfectly equally spaced timeline labels with fixed count distribution ([cf7ab51](https://github.com/sebakri/ticktock/commit/cf7ab516bebbf93b74df588fd9bde02f890be012))
