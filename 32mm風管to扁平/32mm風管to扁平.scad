// ====================================================================
// 22mm - 31mm 直立版風口轉接頭 + 外擴樹狀支撐 (Tree Supports - Outer Placement)
// 支撐腳座向外移離中間，擺放更寬更穩，拆除也更方便！
// ====================================================================

$fn = 100; // 高精度渲染，表面平滑

// --- 1. 漸增寶塔段參數 (進風端) ---
barb_min_id  = 22.0;   // 前端軟管內徑 (mm)
barb_max_id  = 31.0;   // 末端軟管內徑 (31mm)
barb_count   = 5;      // 階梯數
barb_length  = 50.0;   // 寶塔段總長 (mm)
barb_overlap = 1.8;    // 倒鉤外擴深度 (mm)

// --- 2. 漸變過渡段參數 ---
transition_length = 50.0; // 加長過渡段至 50mm

// --- 3. 超寬極扁出風口參數 (出風端) ---
flat_width    = 135.0; // 扁口寬度 (135mm)
flat_height   = 5.0;   // 扁口高度 (壓扁至 5mm)
flat_length   = 60.0;  // 扁口延伸長度 (60mm)
corner_radius = 2.0;   // 扁口圓角半徑 (mm)

// --- 4. 壁厚與隙縫 ---
wall_thickness = 2.0;  // 基本壁厚 (mm)
gap            = 0.25; // 支撐接觸面微小間隙 (0.25mm，方便一撕即離)

// --- 主體結構與支撐整合 ---
module main() {
    // 1. 模型主體
    difference() {
        outer_shell();
        inner_void();
    }
    
    // 2. 兩側樹狀支撐結構 (外擴版)
    tree_supports();
}

// 圓角矩形 Profile
module rounded_rect(w, h, r) {
    hw = w/2 - r;
    hh = h/2 - r;
    hull() {
        translate([ hw,  hh, 0]) circle(r = r);
        translate([-hw,  hh, 0]) circle(r = r);
        translate([ hw, -hh, 0]) circle(r = r);
        translate([-hw, -hh, 0]) circle(r = r);
    }
}

// 直線漸增寶塔外殼
module tapered_barb_tube() {
    single_h = barb_length / barb_count;
    for (i = [0 : barb_count - 1]) {
        curr_min_r = (barb_min_id + (barb_max_id - barb_min_id) * (i / barb_count)) / 2;
        curr_max_r = (barb_min_id + (barb_max_id - barb_min_id) * ((i + 1) / barb_count)) / 2;
        
        top_r = curr_max_r + barb_overlap;
        base_r = curr_min_r;
        
        translate([0, 0, i * single_h])
        cylinder(r1 = base_r, r2 = top_r, h = single_h);
    }
}

// 外殼整體造型
module outer_shell() {
    // 1. 直線漸增寶塔段
    tapered_barb_tube();
    
    r_max_base = barb_max_id / 2;
    
    // 2. 直線漸變段
    translate([0, 0, barb_length])
    hull() {
        cylinder(r = r_max_base, h = 0.1);
        
        translate([0, 0, transition_length])
        linear_extrude(height = 0.1)
        rounded_rect(flat_width + 2*wall_thickness, flat_height + 2*wall_thickness, corner_radius + wall_thickness);
    }
    
    // 3. 直線加長極扁口段
    translate([0, 0, barb_length + transition_length])
    linear_extrude(height = flat_length)
    rounded_rect(flat_width + 2*wall_thickness, flat_height + 2*wall_thickness, corner_radius + wall_thickness);
}

// 內部貫通流道
module inner_void() {
    r_in_start = (barb_min_id / 2) - wall_thickness;
    r_in_end   = (barb_max_id / 2) - wall_thickness;
    
    // 寶塔內部
    translate([0, 0, -2])
    cylinder(r1 = r_in_start, r2 = r_in_end, h = barb_length + 2);
    
    // 漸變段內部
    translate([0, 0, barb_length])
    hull() {
        cylinder(r = r_in_end, h = 0.1);
        
        translate([0, 0, transition_length])
        linear_extrude(height = 0.1)
        rounded_rect(flat_width, flat_height, corner_radius);
    }
    
    // 扁口內部
    translate([0, 0, barb_length + transition_length])
    linear_extrude(height = flat_length + 2)
    rounded_rect(flat_width, flat_height, corner_radius);
}

// 外擴版樹狀支撐模組
module single_tree_support(x_sign) {
    // 將底座進一步外移至 X = 45mm 處 (遠離中間主軸)
    x_base = x_sign * 45.0; 
    x_top  = x_sign * (flat_width / 2 + wall_thickness - 2);
    
    z_base = 0;
    z_mid  = barb_length + 20;
    z_top  = barb_length + transition_length - gap;
    
    // 1. 樹幹接地大底座
    translate([x_base, 0, 0])
    cylinder(r1 = 14, r2 = 6, h = 3);
    
    // 2. 外擴樹幹，向外彎曲起步，再延伸向上
    hull() {
        translate([x_base, 0, z_base]) cylinder(r = 5.5, h = 1);
        translate([x_base + x_sign * 5, 0, z_mid]) cylinder(r = 4.0, h = 1);
    }
    
    // 3. 分叉支撐 (從外側斜斜向上接住漸變斜面)
    // 中段觸點
    hull() {
        translate([x_base + x_sign * 5, 0, z_mid]) cylinder(r = 4.0, h = 1);
        translate([x_top * 0.75, 0, barb_length + 28 - gap]) cylinder(r1 = 2.5, r2 = 1.0, h = 1);
    }
    
    // 頂端最大懸空點 (箭頭處)
    hull() {
        translate([x_base + x_sign * 5, 0, z_mid]) cylinder(r = 4.0, h = 1);
        translate([x_top, 0, z_top]) cylinder(r1 = 3.0, r2 = 1.0, h = 1);
    }
}

// 兩側樹狀支撐 (對稱)
module tree_supports() {
    //single_tree_support(1);  // 右側外擴
    //single_tree_support(-1); // 左側外擴
}

// 渲染模型
main();