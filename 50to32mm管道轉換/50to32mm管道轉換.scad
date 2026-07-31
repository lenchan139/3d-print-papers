// ===================================================
// 內壁三段式階梯外套 (入口 51mm -> 50mm -> 49mm) 至 32mm 管道轉接頭
// ===================================================

/* [風機端內壁三段階梯尺寸 (單位: mm)] */
id_step1    = 51.0;    // 入口第一階內徑 (最寬鬆，方便對準)
h_step1     = 10.0;    // 第一階深度

id_step2    = 50.0;    // 中間第二階內徑 (標準配合)
h_step2     = 10.0;    // 第二階深度

id_step3    = 49.0;    // 最深第三階內徑 (緊密卡緊)
h_step3     = 10.0;    // 第三階深度

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

module triple_internal_stepped_adapter() {
    // 總套入深度
    h_fan_total = h_step1 + h_step2 + h_step3; // 30mm
    
    // 以最大的 51mm 內徑計算統一外徑，保持外壁平整美觀
    outer_d_fan = id_step1 + (wall * 2);       // 55.0mm
    
    d2_out      = pipe32_od;                   // 32.0mm
    d2_in       = d2_out - (wall * 2);         // 28.0mm

    difference() {
        // --- 1. 外輪廓實心體 (外壁為順滑圓柱與錐體) ---
        union() {
            // 風機外套段外壁
            cylinder(d = outer_d_fan, h = h_fan_total);
            
            // 錐形漸變過渡段
            translate([0, 0, h_fan_total])
                cylinder(d1 = outer_d_fan, d2 = d2_out, h = h_trans);
            
            // 32mm 管道連接段
            translate([0, 0, h_fan_total + h_trans])
                cylinder(d = d2_out, h = h_pipe32);
        }
        
        // --- 2. 內部空腔挖空 (內壁做三段階梯) ---
        translate([0, 0, -1])
            union() {
                // [階梯 1] 51mm 入口內腔
                cylinder(d = id_step1, h = h_step1 + 1);
                
                // [階梯 2] 50mm 中間內腔
                translate([0, 0, h_step1])
                    cylinder(d = id_step2, h = h_step2 + 0.1);
                
                // [階梯 3] 49mm 深處內腔
                translate([0, 0, h_step1 + h_step2])
                    cylinder(d = id_step3, h = h_step3 + 0.1);
                
                // 漸變段內腔
                translate([0, 0, h_fan_total])
                    cylinder(d1 = id_step3, d2 = d2_in, h = h_trans + 0.1);
                
                // 32mm 端貫穿內腔
                translate([0, 0, h_fan_total + h_trans])
                    cylinder(d = d2_in, h = h_pipe32 + 3);
            }
    }
}

// 執行模型生成
triple_internal_stepped_adapter();