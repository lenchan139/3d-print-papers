// ===================================================
// 內壁雙階梯外套式 (入口 52mm -> 內部 51mm) 至 32mm 管道轉接頭
// ===================================================

/* [風機端內壁階梯尺寸 (單位: mm)] */
id_entry    = 52.0;    // 入口段內徑 (較寬鬆，方便對準與套入)
h_entry     = 15.0;    // 入口段深度

id_inner    = 51.0;    // 內部段內徑 (較緊密，越往內卡越緊)
h_inner     = 15.0;    // 內部段深度

/* [32mm 管道端尺寸] */
pipe32_od   = 32.0;    // 32mm 端管道外徑
h_pipe32    = 20.0;    // 32mm 端長度

/* [漸變段與壁厚] */
h_trans     = 25.0;    // 錐形過渡段長度 (減少風阻)
wall        = 2.0;     // 最薄處管壁厚度 (預設 2.0mm)

/* [模型精細度] */
$fn = 120;             // 圓弧平滑度


// ===================================================
// 3D 模型構建邏輯
// ===================================================

module internal_stepped_adapter() {
    // 以較大的 52mm 內徑計算統一的外徑，確保外壁平整美觀
    outer_d_fan = id_entry + (wall * 2);               // 56.0mm
    
    d2_out      = pipe32_od;                           // 32.0mm
    d2_in       = d2_out - (wall * 2);                 // 28.0mm

    difference() {
        // --- 1. 外輪廓實心體 (外壁為順滑圓柱與錐體) ---
        union() {
            // 風機外套段外壁 (長度為入口段 + 內部段)
            cylinder(d = outer_d_fan, h = h_entry + h_inner);
            
            // 錐形漸變過渡段
            translate([0, 0, h_entry + h_inner])
                cylinder(d1 = outer_d_fan, d2 = d2_out, h = h_trans);
            
            // 32mm 管道連接段
            translate([0, 0, h_entry + h_inner + h_trans])
                cylinder(d = d2_out, h = h_pipe32);
        }
        
        // --- 2. 內部空腔挖空 (關鍵：內壁做階梯) ---
        translate([0, 0, -1])
            union() {
                // [階梯 1] 52mm 入口內腔 (底部最先套入處)
                cylinder(d = id_entry, h = h_entry + 1);
                
                // [階梯 2] 51mm 內部內腔 (再往深處推進卡緊處)
                translate([0, 0, h_entry])
                    cylinder(d = id_inner, h = h_inner + 0.1);
                
                // 漸變段內腔
                translate([0, 0, h_entry + h_inner])
                    cylinder(d1 = id_inner, d2 = d2_in, h = h_trans + 0.1);
                
                // 32mm 端貫穿內腔
                translate([0, 0, h_entry + h_inner + h_trans])
                    cylinder(d = d2_in, h = h_pipe32 + 3);
            }
    }
}

// 執行模型生成
internal_stepped_adapter();