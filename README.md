<div align="center">

# SoC Project: I2C Master/Slave Design & UVM Verification

<img src="https://img.shields.io/badge/Language-SystemVerilog-green?style=for-the-badge&logo=verilog" />
<img src="https://img.shields.io/badge/Verification-UVM_1.2-blue?style=for-the-badge" />
<img src="https://img.shields.io/badge/Tool-Synopsys_VCS-purple?style=for-the-badge" />
<img src="https://img.shields.io/badge/Tool-Xilinx_Vivado-red?style=for-the-badge" />
<img src="https://img.shields.io/badge/Hardware-Basys3_FPGA-orange?style=for-the-badge" />

<br/>

<p align="center">
  <strong>I2C 통신 인터페이스 설계 및 UVM 기반 검증 프로젝트</strong><br>
  SystemVerilog를 이용한 RTL 설계부터 Synopsys VCS를 활용한 검증, 향후 Microblaze 연동까지 고려한 SoC 프로젝트입니다.
</p>

</div>

<br/>

## 📝 프로젝트 개요 (Project Overview)

본 프로젝트는 SoC(System on Chip) 환경에서 필수적인 **I2C(Inter-Integrated Circuit)** 통신 프로토콜을 구현하고 검증하는 것을 목표로 합니다.
[cite_start]2선식 반이중 통신(Half-Duplex) 방식의 I2C Master와 Slave를 설계하였으며, **UVM(Universal Verification Methodology)** 환경을 구축하여 데이터 무결성을 100% 확보하였습니다[cite: 62, 70, 77].

### 🎯 프로젝트 목표 (Goals)
1.  [cite_start]**RTL 설계:** I2C Protocol(Start/Stop, ACK/NACK, Repeated Start)을 준수하는 Master/Slave 모듈 구현[cite: 77].
2.  [cite_start]**검증(Verification):** Synopsys VCS 및 UVM을 활용한 Testbench 구축 및 시뮬레이션[cite: 78].
3.  [cite_start]**확장성(Future):** Microblaze 및 AXI4 버스 인터페이스와의 연동을 통한 SoC 시스템 통합.

---

## 📚 기술적 배경 (Technical Background)

### I2C vs SPI 비교 분석
[cite_start]본 프로젝트는 I2C의 **2선식 구조**와 **주소 지정 방식**의 효율성에 주목하여 설계되었습니다[cite: 90, 91, 92, 93].

| Feature | I2C (본 프로젝트) | SPI |
| :--- | :--- | :--- |
| **통신 라인** | [cite_start]2개 (SCL, SDA) [cite: 105] | [cite_start]4개 (MOSI, MISO, SCLK, CS) [cite: 104] |
| **통신 방식** | [cite_start]반이중 (Half Duplex) [cite: 109] | [cite_start]전이중 (Full Duplex) [cite: 108] |
| **연결성** | [cite_start]1:N (주소 기반) [cite: 101] | [cite_start]1:N (CS 신호 기반) [cite: 100] |
| **동기화** | [cite_start]동기식 (Synchronous) [cite: 97] | [cite_start]동기식 (Synchronous) [cite: 96] |

### I2C Protocol Implementation
* [cite_start]**Start/Stop Condition:** SCL이 High일 때 SDA의 엣지 변화를 감지하여 구현[cite: 119].
* [cite_start]**Write/Read Operation:** 7-bit Slave Address와 R/W 비트를 포함한 프레임 구조 설계[cite: 127, 128].
* [cite_start]**FSM (Finite State Machine):** `IDLE` ↔ `START` ↔ `DATA` ↔ `ACK` ↔ `STOP` 흐름의 정교한 상태 머신 제어[cite: 131].

---

## 🏗 시스템 구조 및 UVM 환경 (System Architecture & UVM)

이 프로젝트는 UVM 1.2 표준을 준수하며, 계층적인 검증 환경을 구축했습니다.

### UVM Phase Execution
[cite_start]UVM의 표준 Phase 흐름에 따라 컴포넌트가 동작합니다[cite: 148, 150].
1.  [cite_start]**Build Phase:** `build_phase()`를 통해 Environment, Agent, Scoreboard 등의 하위 컴포넌트를 생성하고 계층을 구성합니다[cite: 150].
2.  [cite_start]**Connect Phase:** `connect_phase()`에서 Monitor-Scoreboard, Driver-Sequencer 간의 TLM 포트를 연결합니다[cite: 153].
3.  [cite_start]**Run Phase:** `run_phase()`에서 실제 시뮬레이션 시간 동안 Driver 구동 및 Monitor 샘플링을 수행합니다[cite: 155].

### UVM Class Details
* [cite_start]**`i2c_sequence`**: 랜덤 트랜잭션(Write/Read)을 생성하여 Sequencer로 전달합니다[cite: 161].
* **`i2c_driver`**: Virtual Interface를 통해 RTL(DUT)에 물리적인 신호(SCL, SDA)를 인가합니다[cite: 164].
* **`i2c_monitor`**: 버스 상의 신호를 샘플링하여 Transaction 레벨로 변환 후 Scoreboard로 전송합니다[cite: 166].
* **`i2c_scoreboard`**: Master가 보낸 데이터(`tx_data`)와 Slave가 수신한 데이터(`rx_data`/`led`)를 비교 검증합니다.

---

## 💻 시뮬레이션 결과 (Simulation Results)

Synopsys VCS를 이용한 시뮬레이션 결과, 총 256개의 트랜잭션에 대해 **100%의 성공률**을 달성했습니다.

### 1. Waveform Analysis (Verdi)
<details>
<summary>Click to see Waveform Details</summary>

* **Write Transaction:** Master가 `0xDE` 데이터를 Slave(`addr: 0x02`)에 전송하고 ACK를 수신함[cite: 134].
* [cite_start]**Read Transaction:** Master가 Slave로부터 데이터를 읽어오며, 이전 Write된 값(`0xDE`)이 정확히 수신됨을 확인[cite: 147].

</details>

*(여기에 PPT 168페이지의 Verdi 파형 이미지를 첨부하세요)*

### 2. Verification Log (Scoreboard)
[cite_start]Scoreboard를 통해 자동화된 검증을 수행하였으며, 모든 테스트 케이스가 통과되었습니다[cite: 167].

```text
UVM_INFO @ 102417925000: uvm_test_top.ENV.SCB [SCB] *** I2C TEST PASSED (256/256) *** tx_data:108, rx_data:108
==================================================
           SCOREBOARD I2C TEST SUMMARY
==================================================
Total Transactions:      256
Successful Transactions: 256
Failed Transactions:     0
Success Rate:            100.00 %
==================================================
