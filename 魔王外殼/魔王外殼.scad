// ========================================================
// The Handy 一代外殼 - 【內徑 68mm ＋ 45mm 精準合身版】(A1 mini 一盤流)
// ========================================================

part_to_show = "ALL_SEPARATED"; 

$fn = 100; // 圓弧精細度
overlap = 0.05; 

// --- 【全新雙重修正參數】 ---
total_h     = 170;   // 外殼總高度 170mm
inner_d     = 68;    // 1. 內膽全新內徑 -> 68mm (緊緻貼合機身)
outer_d     = 74;    // 外殼外徑同步調整 -> 74mm (維持 3mm 剛性牆厚)

// ========================================================
// 子模組：精準雙修正半圓筒
// ========================================================
module multi_groove_half_cylinder() {
    difference() {
        // 主外殼
        cylinder(h = total_h, d = outer_d, center = false);
        
        // 內膽空心挖除 (直徑 68mm)
        translate([0, 0, -1]) 
            cylinder(h = total_h + 2, d = inner_d, center = false);
        
        // 【2. 主綁帶槽：起始點抬高至 60mm，寬度縮緊至 45mm】
        // 高度從 60mm 到 105mm，寬度 45mm (比原廠寬 5mm)。下方 0-60mm 完美平整避讓底座！
        translate([0, 0, 60])
            difference() {
                cylinder(h = 45, d = outer_d + 2, center = false);
                cylinder(h = 45, d = outer_d - 3, center = false); // 內陷 1.5mm
            }
            
        // 【輔助綁帶槽：上方加固防滑區】(高度 130mm 到 155mm，寬度 25mm)
        translate([0, 0, 130])
            difference() {
                cylinder(h = 25, d = outer_d + 2, center = false);
                cylinder(h = 25, d = outer_d - 3, center = false); // 內陷 1.5mm
            }
            
        // 切除另一半，只留下乾淨的半圓筒
        translate([-outer_d, -outer_d, -1]) 
            cube([outer_d, outer_d * 2, total_h + 2]);
    }
}

// ========================================================
// 最終生產排版輸出
// ========================================================
if (part_to_show == "LEFT") {
    multi_groove_half_cylinder();
} 
else if (part_to_show == "RIGHT") {
    mirror([1, 0, 0]) multi_groove_half_cylinder();
} 
else {
    // 【A1 mini 縱向平行排隊流 - 雙修正完美排版】
    union() {
        // 1. 左外殼 (精準平移至 X = -40)
        translate([-40, 0, 0]) rotate([0, 0, 180]) color("LightBlue") multi_groove_half_cylinder();
        
        // 2. 右外殼 (精準平移至 X = 40)
        translate([40, 0, 0]) rotate([0, 0, -180]) color("LightPink") mirror([1, 0, 0]) multi_groove_half_cylinder();
        
        // 3. 【紅色防倒連體加固橋】（針對全新腰身外型優化位置）
        color("Red") {
            // 底部防倒橋 (Z = 15mm，安全平整區)
            translate([-43, -outer_d/2, 15]) cube([86, 0.4, 8]);
            translate([-43, outer_d/2 - 0.4, 15]) cube([86, 0.4, 8]);
            
            // 上部防倒橋 (Z = 112mm，中部主槽與頂部槽之間的實心過渡牆)
            translate([-43, -outer_d/2, 112]) cube([86, 0.4, 6]);
            translate([-43, outer_d/2 - 0.4, 112]) cube([86, 0.4, 6]);
        }
    }
}