# 世界数据搜集任务清单

> 由 nightly-data-collector 定时任务维护。agent 每次运行认领一个 PENDING 任务，
> 完成后把状态改为 DONE 并登记产物路径。所有数据集存 `datasets/` 目录，
> 一个数据集一个 CSV（UTF-8，含表头，注明来源 URL 与采集日期）。

## 采集规范

- **防重复（最高优先级）**：每次运行开始先读 `/home/weii/world-data/collection-log.md` 全表——
  1. 若本次要采的 `主题+范围` 已有 SUCCESS 行，跳过，换下一个任务；
  2. 若是同一数据集的范围/年份扩展，允许，但在 ledger 备注列写明增量（如"补 2023-2024 两年"）；
  3. 采集完成后**立即**向 ledger 追加一行（时间/主题/数据集/范围/行数/来源URL/状态/备注），失败也记（状态=FAIL，备注写原因），失败记录不算已采集、可重试。
- 优先一手来源：政府官网、统计局、国际组织（UN/World Bank/WHO）、GitHub 上的权威数据集（如 datasets/world-cities、Natural Earth）
- 每行数据必须可溯源：CSV 头部注释写来源 URL + 采集日期
- 无法核实的数据不录入；来源之间冲突时两个都记并注明
- 单次运行只认领一个任务，做不完的拆分为新任务追加到清单末尾

## 任务队列

| # | 状态 | 主题 | 说明 | 产物 |
|---|---|---|---|---|
| 1 | DONE | 中国城市名录与人口 | 地级市以上：名称/省/人口(最新普查)/GDP | datasets/cn-cities.csv |
| 2 | DONE | 世界各国首都与人口 | UN 成员国：国家/首都/人口/大洲 | datasets/world-capitals.csv |
| 3 | DONE | 日本都道府县数据 | 47 都道府县：名称/人口/面积/首府 | datasets/jp-prefectures.csv |
| 4 | DONE | 美国各州数据 | 50 州：名称/缩写/人口/首府/加入年份 | datasets/us-states.csv |
| 5 | DONE | 世界主要城市人口年份序列 | 选 50 个大城市，2015-2024 人口逐年 | datasets/city-population-series.csv |
| 6 | DONE | 欧盟成员国基础数据 | 国名/加入年份/人口/货币/首都 | datasets/eu-members.csv |
| 7 | DONE | 世界河流长度榜 | 前 50 长河流：名称/长度/流经国家/注入 | datasets/world-rivers.csv |
| 8 | DONE | 各国 GDP 年份序列 | 主要经济体 2015-2024 名义 GDP (USD) | datasets/gdp-series.csv |
| 9 | DONE | 世界主要城市人口年份序列 | 选 50 个大城市，2015-2024 人口逐年 | 同 #5: datasets/city-population-series.csv |
| 10 | DONE | 中国省份基础数据 | 34 省级：名称/首府/人口(七普)/面积/GDP | datasets/cn-provinces.csv |
| 11 | DONE | 世界主要岛屿面积榜 | 前 50 大岛：名称/面积/所属国家/大洲 | datasets/world-islands.csv |
| 12 | DONE | 世界时区与 UTC 偏移 | 主要国家/地区标准时区表 | datasets/world-timezones.csv |
| 13 | DONE | 各国互联网用户与普及率 | 主要国家 2020-2024 | datasets/internet-users.csv |
| 14 | DONE | 诺贝尔奖统计 | 1901-2025 各国获奖人数按类别 | datasets/nobel-prizes.csv |
| 15 | DONE | 世界主要沙漠面积榜 | 前 30 大沙漠：名称/面积/大洲/类型 | datasets/world-deserts.csv |
| 16 | DONE | 各国汽车保有量 | 主要国家最新年份 | datasets/motor-vehicles.csv |
| 17 | DONE | 世界主要湖泊面积榜 | 前 30 大湖泊：名称/面积/大洲/所属国家/类型(淡水咸水) | datasets/world-lakes.csv |
| 18 | DONE | 各国互联网用户与普及率(合并去冲突) | 2026-11-09 以 World Bank API 单一口径重采覆盖: 190 国家/地区 × 2019-2024 逐年(users=rate%×人口推算), 已剔除79个聚合区; 校验0冲突 | datasets/internet-users.csv |
| 19 | DONE | 中国省份GDP补全 | 2026-11-09 补 33/34 省级 GDP(2024r+2023, 亿元人民币+百万美元, NBS 五经普修订口径, 转引维基省级GDP表); 台湾因口径不同留空 | datasets/cn-provinces.csv |
| 20 | DONE | cn-provinces 质量修补: 西藏行 | 西藏行已补齐(七普3653919人/面积1228400km2/拉萨/藏); 台湾density复核651.17正确; GDP错位数据已挪回GDP列 | datasets/cn-provinces.csv |
| 21 | DONE | 世界最高火山 | 184 座(按海拔) | datasets/world-highest-volcanoes.csv |
| 22 | DONE | 各国铁路网长度 | 主要国家铁路总长/电气化率/高铁里程 | datasets/world-railways.csv |
| 23 | DONE | 世界主要运河 | 名称/长度/连接水域/通航年份 | datasets/world-canals.csv |
| 24 | DONE | 各国高等教育入学率 | 主要国家 2015-2023 | datasets/tertiary-enrollment.csv |
| 25 | DONE | 世界大战与重大冲突年表 | 1900-2025 主要冲突：名称/年份/参战方/死亡估计 | datasets/major-conflicts.csv |
| 26 | PENDING | 冲突年表 1990-2002 + 2003-present 补采 | 与已采 1900-1989 同格式 | datasets/major-conflicts.csv (追加) |
| 27 | PENDING | 各国人均预期寿命 | World Bank SP.DYN.LE00 2015-2023 | datasets/life-expectancy.csv |
| 28 | PENDING | 世界主要语言分布国家数 | 各语言作为官方语言的国家列表 | datasets/official-languages.csv |
| 29 | PENDING | 下钻: 深圳市 | 各区人口/面积/GDP(世界/中国/广东/深圳) | datasets/cn-gd-shenzhen-districts.csv |
| 30 | PENDING | 下钻: 广州市 | 各区人口/面积(世界/中国/广东/广州) | datasets/cn-gd-guangzhou-districts.csv |
| 31 | PENDING | 下钻: 江苏/浙江/山东省级 | 同广东格式各省(世界/中国/省份) | datasets/cn-{prov}-cities.csv ×3 |
