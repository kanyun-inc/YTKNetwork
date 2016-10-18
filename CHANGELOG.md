# Changelog

---

## 2.0.2 (link here)

#### Added

* New `debugLogEnabled` option in `YTKNetworkConfig` to enable/disable logging ([f0ee0b4](https://github.com/yuantiku/YTKNetwork/commit/f0ee0b4f49c1a38c6d89cec59b7e736a26fef1f8)).
* Exposed more errors when constructing `YTKBaseRequest` ([f210739](https://github.com/yuantiku/YTKNetwork/commit/f21073998eeff8a558aad73d61c87a2482824319)).

#### Updated

* Documentation is now organized and updated to reflect the latest code ([#236](https://github.com/yuantiku/YTKNetwork/pull/236) & [#230](https://github.com/yuantiku/YTKNetwork/pull/230)). 

#### Fixed

* When put inside `YTKBatchRequest` or `YTKChainRequest`, a single `YTKRequest` will have its completion blocks(delegates) cleared to prevent further confusing behaviour ([55d88ae](https://github.com/yuantiku/YTKNetwork/commit/55d88ae20a6401fad176b31203fee8cb2fe749b4)).
