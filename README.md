# Local Binary Pattern (LBP) — Verilog Implementation

這個專案實作 **Local Binary Patterns (LBP)** 演算法，使用 **Verilog HDL** 於硬體電路上完成影像從 **RGB → Gray → LBP** 的完整資料流處理。
LBP 是一種常見的影像特徵擷取方法，常用於臉部識別、紋理分類與影像分析中。
![Uploading image.png…]()

---

## 專案流程簡介

整體流程分為三個主要階段：

### 1. **RGB → Grayscale（灰階轉換）**

模組會從影像記憶體讀取 RGB24 bits（R,G,B 各 8 bits），並轉換成灰階值。

常用灰階轉換方式：
[
Gray = (R + G + B) / 3
]

轉換後存入內部的灰階記憶體 `gray_mem`，以便後續計算 LBP。

---

### 2. **Gray → LBP**

LBP 的核心概念是：
使用中心像素周圍的 8 個鄰點進行比較，若鄰點 ≥ 中心點，記為 1，否則記為 0。
最終得到一個 8-bit 的紋理描述子。

示意圖：

```
p0 p1 p2
p7  C p3
p6 p5 p4
```

比較結果組合成一個 8-bit binary → LBP feature。

---

### 3. **寫入 Output Memory（LBP 輸出）**

LBP 計算完成後，會將結果寫入：

* `lbp_addr`
* `lbp_data`
* `lbp_valid`

最後完成時輸出 `finish = 1`。

---
