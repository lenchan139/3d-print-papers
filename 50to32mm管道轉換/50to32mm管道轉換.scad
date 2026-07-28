// ===================================================
// 雙向相容 50mm 至 32mm 管道風機變徑轉接頭 (Universal Dual-Fit Reducer)
// ===================================================

/* [50mm 風機端設定 (單位: mm)] */
d_fan_nominal = 50.0;    // 風機標稱尺寸
step_len      = 18.0;    // 階梯連接段長度 (插入段與外套段各長 18mm)
wall          = 2.0;     // 壁厚 (建議 2.0mm ~ 2.5mm)

/* [32mm 管道端設定] */
d_pipe_32     = 32.0;    // 32mm 管道尺寸
h_pipe_32     = 20.0;    // 32mm 端長度

/* [漸變段設定] */
h_trans       = 25.0;    // 錐形過渡段長度 (減小風阻)

/* [公差設定] */
insert_tol    = -0.3;    // 塞入端公差 (預設外徑 49.7mm)
sleeve_tol    = 0.3;     // 套入端公差 (預設內徑 50.3mm)

/* [模型精細度] */
$fn = 120;


// ===================================================
// 3D 模型構建邏輯
// ===================================================

module dual_fit_reducer() {
    // 尺寸計算
    d_insert_outer = d_fan_nominal + insert_tol;               // 49.7mm
    d_insert_inner = d_insert_outer - (wall * 2);             // 45.7mm
    
    d_sleeve_inner = d_fan_nominal + sleeve_tol;               // 50.3mm
    d_sleeve_outer = d_sleeve_inner + (wall * 2);             // 54.3mm
    
    d_32_outer     = d_pipe_32;                               // 32.0mm
    d_32_inner     = d_32_outer - (wall * 2);                 // 28.0mm

    difference() {
        // --- 1. 外輪廓實心體 ---
        union() {
            // [段落 1] 插入段 (Male Step)
            cylinder(d = d_insert_outer, h = step_len);
            
            // [段落 2] 套入段 (Female Step)
            translate([0, 0, step_len])
                cylinder(d = d_sleeve_outer, h = step_len);
            
            // [段落 3] 錐形漸變過渡段 (Reducer Transition)
            translate([0, 0, step_len * 2])
                cylinder(d1 = d_sleeve_outer, d2 = d_32_outer, h = h_trans);
            
            // [段落 4] 32mm 管道連接段
            translate([0, 0, step_len * 2 + h_trans])
                cylinder(d = d_32_outer, h = h_pipe_32);
        }
        
        // --- 2. 內部空腔挖空 ---
        translate([0, 0, -1])
            union() {
                // 插入段內腔
                cylinder(d = d_insert_inner, h = step_len + 1);
                
                // 套入段內腔 (讓 50mm 風機管壁可以套進來)
                translate([0, 0, step_len])
                    cylinder(d = d_sleeve_inner, h = step_len + 0.1);
                
                // 漸變段內腔
                translate([0, 0, step_len * 2])
                    cylinder(d1 = d_sleeve_inner, d2 = d_32_inner, h = h_trans + 0.1);
                
                // 32mm 端貫穿內腔
                translate([0, 0, step_len * 2 + h_trans])
                    cylinder(d = d_32_inner, h = h_pipe_32 + 3);
            }
    }
}

// 執行模型生成
dual_fit_reducer();