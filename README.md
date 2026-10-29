# Mạch đếm số bit 1 trong chuỗi 8 bit (Datapath + Controller)

## Cấu trúc file
| File | Nội dung |
|------|----------|
| `datapath.v` | Thanh ghi dịch 8 bit, bộ đếm bit 1 (`ones_cnt`), bộ đếm số lần dịch (`bit_cnt`) |
| `controller.v` | FSM 4 trạng thái: IDLE → LOAD → SHIFT → DONE |
| `ones_counter.v` | Top-level, nối datapath và controller |
| `tb_ones_counter.v` | Testbench, 5 ca kiểm thử, tự so sánh kết quả |

## Giao diện top-level `ones_counter`
| Tín hiệu | Hướng | Rộng | Ý nghĩa |
|----------|-------|------|---------|
| `clk` | in | 1 | xung nhịp |
| `rst` | in | 1 | reset đồng bộ, mức cao |
| `start` | in | 1 | bắt đầu đếm (giữ mức 1 tới khi `done` = 1) |
| `data_in` | in | 8 | chuỗi bit cần đếm |
| `count_out` | out | 4 | số bit 1 (0..8) |
| `done` | out | 1 | = 1 khi đếm xong, giữ `count_out` |

## Tín hiệu giữa Controller và Datapath
| Tín hiệu | Chiều | Ý nghĩa |
|----------|-------|---------|
| `ld` | Ctrl → DP | nạp `data_in` vào thanh ghi dịch, xoá 2 bộ đếm |
| `sh` | Ctrl → DP | dịch phải 1 bit, cộng LSB vào `ones_cnt`, tăng `bit_cnt` |
| `last_bit` | DP → Ctrl | = 1 khi `bit_cnt == 7` (đang xử lý bit cuối) |

## Bảng chuyển trạng thái (Moore)
| Trạng thái | Mã | Điều kiện | Trạng thái kế | Ngõ ra (ld, sh, done) |
|------------|----|-----------|---------------|-----------------------|
| S_IDLE | 00 | start = 1 | S_LOAD | 0,0,0 |
| S_IDLE | 00 | start = 0 | S_IDLE | 0,0,0 |
| S_LOAD | 01 | luôn | S_SHIFT | 1,0,0 |
| S_SHIFT | 10 | last_bit = 0 | S_SHIFT | 0,1,0 |
| S_SHIFT | 10 | last_bit = 1 | S_DONE | 0,1,0 |
| S_DONE | 11 | start = 1 | S_DONE | 0,0,1 |
| S_DONE | 11 | start = 0 | S_IDLE | 0,0,1 |

Tổng cộng: 1 chu kỳ LOAD + 8 chu kỳ SHIFT + 1 chu kỳ DONE = 10 chu kỳ cho 1 lần đếm.

## Các bước trên Quartus II
1. File → New Project Wizard. Tên project `ones_counter`, top-level entity `ones_counter`. Family chọn Cyclone II hoặc Cyclone IV E (tuỳ bản Quartus).
2. Project → Add/Remove Files in Project: thêm `datapath.v`, `controller.v`, `ones_counter.v`.
3. Processing → Start Compilation. Chụp màn hình **Flow Summary**.
4. Tools → Netlist Viewers → **RTL Viewer**: chụp sơ đồ top-level, sau đó double-click vào `u_dp` và `u_ctrl` để chụp bên trong.
5. Tools → Netlist Viewers → **State Machine Viewer**: chụp sơ đồ FSM và bảng chuyển trạng thái Quartus tự sinh.
6. Mô phỏng với ModelSim-Altera:
   - Assignments → Settings → EDA Tool Settings → Simulation: chọn ModelSim-Altera, format Verilog HDL.
   - Mục Compile test bench → Test Benches → New: tên `tb_ones_counter`, top-level `tb_ones_counter`, thêm file `tb_ones_counter.v`.
   - Tools → Run Simulation Tool → RTL Simulation. Trong ModelSim, Transcript sẽ in PASS/FAIL cho 5 ca.
   - Chụp waveform với các tín hiệu: `clk`, `rst`, `start`, `data_in`, `state`, `ld`, `sh`, `shreg`, `ones_cnt`, `bit_cnt`, `last_bit`, `count_out`, `done`.
7. Nếu dùng Vector Waveform (bản Quartus ≤ 13.0): tạo file `.vwf`, vẽ `clk` chu kỳ 10 ns, kéo `rst` lên 20 ns đầu, đặt `data_in` và `start`, chạy Functional Simulation.

## Mô phỏng nhanh ngoài Quartus (Icarus Verilog)
```bash
sudo apt install iverilog gtkwave
iverilog -g2005 -o sim.out datapath.v controller.v ones_counter.v tb_ones_counter.v
vvp sim.out
gtkwave ones_counter.vcd
```

## Ca kiểm thử trong testbench
| data_in | Kết quả mong đợi |
|---------|------------------|
| 00000000 | 0 |
| 11111111 | 8 |
| 10101010 | 4 |
| 11010011 | 5 |
| 10000001 | 2 |

## Dàn ý báo cáo PDF
1. Thông tin: họ tên, MSSV, lớp, đề bài chép nguyên văn.
2. Phân tích yêu cầu, chọn 8 bit, chọn phương pháp Datapath + Controller.
3. Sơ đồ khối tổng (top-level) và bảng tín hiệu.
4. Thiết kế Datapath: sơ đồ, giải thích từng khối thanh ghi/bộ đếm.
5. Thiết kế Controller: sơ đồ trạng thái, bảng chuyển trạng thái, ngõ ra Moore.
6. Code Verilog (đính kèm hoặc trích).
7. Kết quả Quartus: Flow Summary, RTL Viewer, State Machine Viewer.
8. Kết quả mô phỏng: waveform từng ca, phân tích đọc giá trị `count_out` tại thời điểm `done` = 1.
9. Link chứng minh: video quay màn hình compile + mô phỏng, hoặc repo.
