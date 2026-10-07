# Google Play IAP — PauseCart

Package: `com.PauseCartMNG.PauseCart`

Remote config: `https://api2.blwsmartware.net/N307.json`  
If JSON field `disable` is `1`, hide Google Play purchase popups. Shop stays open for coin unlocks.

## Consumable coin packs (buy many times)

| Product ID | Coins |
| --- | --- |
| `pc_pack_1` | 50 |
| `pc_pack_2` | 100 |
| `pc_pack_3` | 200 |
| `pc_pack_4` | 350 |
| `pc_pack_5` | 500 |
| `pc_pack_6` | 750 |
| `pc_pack_7` | 1000 |
| `pc_pack_8` | 1500 |
| `pc_pack_9` | 2200 |
| `pc_pack_10` | 3000 |

## One-time

| Product ID | Unlock |
| --- | --- |
| `pc_remove_ads` | Hide the banner |
| `pc_pro` | More than 8 custom waiting items |

Create these IDs in Play Console → Monetize → In-app products. Coin packs must be **consumable**. Remove ads and Pro must be **non-consumable**.
