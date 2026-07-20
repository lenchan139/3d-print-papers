//$fn = 100; // 取消註解此行可獲得更平滑的圓弧（預覽與渲染會較慢）
$fn = 60;   // 預覽用的解析度

// ==========================================
// 參數設定區 (外壁加厚、內部挖內坑螺紋版)
// ==========================================
bottle_od       = 27.4; // 可樂瓶口螺紋最外徑 (mm)
bottle_id       = 21.5; // 可樂瓶口內徑 (mm)
tolerance       = 0.30; // 3D列印公差

// 下方接頭參數（維持加厚以利挖坑）
neck_wall_thickness = 3;    // 下方螺紋外壁厚度 (mm)
neck_height         = 16.0; // 螺紋段總高度 (mm)

// 上方漏斗參數（修正壁厚以防切片空層）
funnel_wall_thickness = 1.2;  // 修正：增加至 1.2mm (適合 0.4mm 噴嘴印 3 層牆)
funnel_top_id         = 75.0; // 漏斗上方開口內徑 (mm)
funnel_height         = 55.0; // 漏斗錐形區域高度 (mm)

// PCO 標準螺紋參數 (內凹坑洞型式)
thread_pitch    = 2.70; // 可樂瓶標準螺距 (mm)
thread_turns    = 2.2;  // 螺紋圈數
thread_depth    = 2;    // 螺紋內凹坑的深度 (mm)

// 引流管參數
guide_wall           = 1.5;  // 引流管壁厚 (mm)

// 便捷變數
inner_r = (bottle_od / 2) + tolerance;
outer_r = inner_r + neck_wall_thickness; // 下方外壁最終半徑
cone_bottom_in_r = (bottle_id / 2) - 0.4 - guide_wall; // 漏斗最底部的內半徑

// ==========================================
// 主模型組裝
// ==========================================
union() {
    // 1. 上方漏斗本體 (高度緊接在斜坡上方)
    translate([0, 0, neck_height + neck_wall_thickness])
        funnel_cone();

    // 2. ✨ 45度防懸空過渡斜坡 ✨
    translate([0, 0, neck_height]) {
        difference() {
            // 斜坡外錐
            cylinder(h = neck_wall_thickness,
                     r1 = outer_r,
                     r2 = cone_bottom_in_r + funnel_wall_thickness);
            // 斜坡內孔
            translate([0, 0, -0.1])
                cylinder(h = neck_wall_thickness + 0.2,
                         r1 = cone_bottom_in_r,
                         r2 = cone_bottom_in_r);
        }
    }

    // 3. 下方結構 (直接從實心結構挖出環形槽與螺紋內坑)
    difference() {
        // 基礎：完全實心的加厚圓柱外殼
        cylinder(h = neck_height, r = outer_r);

        // 減去：內外壁之間的「環形槽」
        translate([0, 0, -1])
            difference() {
                cylinder(h = neck_height + 2, r = inner_r);
                cylinder(h = neck_height + 2, r = (bottle_id / 2) - 0.4);
            }

        // 減去：最內側的液體通道
        translate([0, 0, -1])
            cylinder(h = neck_height + 2, r = cone_bottom_in_r);

        // 減去：直接在內壁挖出螺紋坑
        sunk_threads();
    }
}

// ==========================================
// 子模組定義
// ==========================================

// 漏斗錐形本體模組
module funnel_cone() {
    difference() {
        // 外錐體
        cylinder(h = funnel_height,
                 r1 = cone_bottom_in_r + funnel_wall_thickness,
                 r2 = (funnel_top_id / 2) + funnel_wall_thickness);

        // 內錐體 (挖空)
        translate([0, 0, -0.1])
            cylinder(h = funnel_height + 0.2,
                     r1 = cone_bottom_in_r,
                     r2 = funnel_top_id / 2);
    }
}

// 內凹螺紋生成模組
module sunk_threads() {
    total_twist = thread_turns * 360;
    thread_h = thread_turns * thread_pitch;

    translate([0, 0, 1.0]) {
        linear_extrude(height = thread_h, twist = -total_twist, slices = 120, convexity = 10) {
            translate([inner_r, 0, 0])
                polygon(points=[
                    [-0.1, 0],
                    [thread_depth, 0.45 * thread_pitch],
                    [-0.1, 0.9 * thread_pitch]
                ]);
        }
    }
}
