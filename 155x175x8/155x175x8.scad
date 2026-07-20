// ========================================================
// 參數定義 (單位：mm)
// ========================================================
// 1. 上蓋平面尺寸
top_width   = 155; 
top_length  = 175; 
top_height  = 5;    // 維持你要求的 5mm 高度

// 2. 下層卡槽尺寸 (請根據你上次印出的粉橘色版本進行微調)
inner_width  = 125; 
inner_length = 139surface("/Users/len/Library/Mobile Documents/com~apple~CloudDocs/MacScreenshots/Screenshot 2026-07-02 at 7.02.34 PM.png");
; // previous 160
inner_height = 6;   

// 3. 避位缺口與「防鬆動卡榫」
bump_width   = 46;  // 白色凸起物的寬度
bump_length  = 26;  // 白色凸起物伸入內槽的長度
bump_height  = inner_height; 

// 【核心修正】卡榫厚度：在缺口兩側長出肉來夾緊白色凸起物
// 如果印出來還是太鬆，把這個數字調大（例如 1.5 或 2.0）
// 如果太緊塞不下去，就把這個數字調小（例如 0.5）
tightness_wall = 1.0; 

// 外觀圓角
round_radius = 15; 
$fn = 60;

// ========================================================
// 核心建模 (布林運算)
// ========================================================
difference() {
    // 【聯集】打造倒凸字型主體
    union() {
        // A. 上層大平面 (厚度 5mm)
        rounded_rectangle(top_width, top_length, top_height, round_radius);
        
        // B. 下層卡緊塊
        translate([(top_width - inner_width) / 2, (top_length - inner_length) / 2, -inner_height])
            rounded_rectangle(inner_width, inner_length, inner_height, round_radius - 2);
    }
    
    // 【差集】挖掉下半部的缺口（左右兩側各留下一道牆，用來卡緊白色凸起物）
    // 透過加上 tightness_wall，讓挖掉的洞變小，等於留下結構去「夾」住那個凸起物
    translate([
        (top_width - bump_width) / 2 + tightness_wall, 
        0, 
        -inner_height - 0.5
    ]) {
        cube([
            bump_width - (tightness_wall * 2), 
            bump_length, 
            bump_height + 0.5
        ]);
    }
}

// ========================================================
// 圓角矩形模組
// ========================================================
module rounded_rectangle(x, y, z, r) {
    translate([r, r, 0])
    minkowski() {
        cube([x - 2*r, y - 2*r, z / 2]);
        cylinder(r = r, h = z / 2);
    }
}