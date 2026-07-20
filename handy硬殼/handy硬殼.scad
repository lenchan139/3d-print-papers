// ========================================================
// The Handy 原廠軟杯專屬 - 【內徑 47mm 舒適避讓版·精準 40mm 槽·內建 Brim】
// ========================================================

part_to_show = "ALL_SEPARATED"; 

$fn = 100; // 圓弧精細度
overlap = 0.05; 

// --- 【全新 47mm 舒適版尺寸參數】 ---
sleeve_h       = 65;    // 總高度：10 (下) + 40 (槽) + 15 (上) = 65mm
sleeve_inner_d = 47;    // 1. 內膽全新內徑 -> 47mm (留出緩衝空間，絕不擠壓變形)
sleeve_outer_d = 53;    // 外殼外徑同步調整 -> 53mm (維持 3mm 剛性牆厚)

// --- 【內建 Brim 參數】 ---
brim_thickness = 0.2;   // 0.2mm 單層厚度，好印好撕
brim_width     = 8;     // 裙邊寬度 8mm

// ========================================================
// 子模組：帶有 40mm 低重心精準槽的舒適半圓筒
// ========================================================
module sleeve_holder_half() {
    difference() {
        // 主杯殼外軀
        cylinder(h = sleeve_h, d = sleeve_outer_d, center = false);
        
        // 內部中空 (直徑 47mm)
        translate([0, 0, -1]) 
            cylinder(h = sleeve_h + 2, d = sleeve_inner_d, center = false);
        
        // 【精準綁帶定位槽：下高度 10mm 開始，槽寬 40mm】
        // 高度區區間為 10mm 到 50mm，上方留下 15mm 的上高度
        translate([0, 0, 10])
            difference() {
                cylinder(h = 40, d = sleeve_outer_d + 2, center = false);
                cylinder(h = 40, d = sleeve_outer_d - 3, center = false); // 內陷 1.5mm
            }
            
        // 切除另一半
        translate([-sleeve_outer_d, -sleeve_outer_d, -1]) 
            cube([sleeve_outer_d, sleeve_outer_d * 2, sleeve_h + 2]);
    }
}

// ========================================================
// 子模組：半圓形 Brim 裙邊 (同步適應 53mm 外徑)
// ========================================================
module half_brim() {
    difference() {
        cylinder(h = brim_thickness, d = sleeve_outer_d + (brim_width * 2), center = false);
        translate([0, 0, -0.1])
            cylinder(h = brim_thickness + 0.2, d = sleeve_inner_d, center = false);
        translate([-(sleeve_outer_d + brim_width * 2), -(sleeve_outer_d + brim_width * 2), -0.1])
            cube([(sleeve_outer_d + brim_width * 2), (sleeve_outer_d + brim_width * 2) * 2, brim_thickness + 0.2]);
    }
}

// ========================================================
// 子模組：帶有內建裙邊的完全體半個杯殼
// ========================================================
module sleeve_half_with_brim() {
    union() {
        sleeve_holder_half();
        half_brim(); 
    }
}

// ========================================================
// 最終生產排版輸出
// ========================================================
if (part_to_show == "LEFT") {
    sleeve_half_with_brim();
} 
else if (part_to_show == "RIGHT") {
    mirror([1, 0, 0]) sleeve_half_with_brim();
} 
else {
    // 【A1 mini 緊湊一盤流 - 47mm 優化排版】
    union() {
        // 1. 左半杯殼 + 裙邊 (精準平移至 X = -29.5)
        translate([-29.5, 0, 0]) rotate([0, 0, 180]) color("Cyan") sleeve_half_with_brim();
        
        // 2. 右半杯殼 + 裙邊 (精準平移至 X = 29.5)
        translate([29.5, 0, 0]) rotate([0, 0, -180]) color("LightRichBlue") mirror([1, 0, 0]) sleeve_half_with_brim();
        
        // 3. 【紅色防倒連體加固橋】（跨距優化至 65mm）
        color("Red") {
            // 頂部防倒橋 (Z = 55mm，完美黏在最上方的 15mm 平整外牆上)
            translate([-32.5, -sleeve_outer_d/2, 55]) cube([65, 0.4, 6]);
            translate([-32.5, sleeve_outer_d/2 - 0.4, 55]) cube([65, 0.4, 6]);
        }
    }
}