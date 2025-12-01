<div align="center">

# I2C Master/Slave Design & UVM Verification

<img src="https://img.shields.io/badge/Language-SystemVerilog-green?style=for-the-badge&logo=verilog" />
<img src="https://img.shields.io/badge/Verification-UVM_1.2-blue?style=for-the-badge" />
<img src="https://img.shields.io/badge/Protocol-I2C-orange?style=for-the-badge" />
<img src="https://img.shields.io/badge/Tool-VCS%20%7C%20Verdi-lightgrey?style=for-the-badge" />

<br/>

<p align="center">
  <strong>SystemVerilog를 이용한 I2C 프로토콜 설계 및 UVM 기반 검증 환경 구축 프로젝트입니다.</strong><br>
  I2C Master와 Slave의 RTL 설계부터 Scoreboard를 이용한 데이터 무결성 검증까지 포함하고 있습니다.
</p>

</div>

<br/>

## 📝 프로젝트 개요 (Project Overview)

이 프로젝트는 **I2C(Inter-Integrated Circuit)** 통신 프로토콜을 RTL(Register Transfer Level)로 구현하고, 산업 표준 검증 방법론인 **UVM**을 적용하여 기능을 검증한 결과물입니다.

* **Master:** FSM 기반의 제어 로직과 정밀한 타이밍 제어 구현
* **Slave:** 시스템 클럭 동기화를 통한 안정적인 데이터 수신 및 LED 제어
* **Verification:** UVM Testbench를 통한 자동화된 트랜잭션 생성 및 결과 비교 (Scoreboard)

---

## 📂 파일 구조 (File Structure)

```bash
.
├── rtl
│   ├── I2C_Master.sv      # I2C Master 모듈 (FSM 및 타이밍 제어)
│   └── I2C_Slave.sv       # I2C Slave 모듈 (시스템 클럭 동기화 방식)
├── tb
│   ├── tb_i2c_top.sv      # UVM Testbench Top 및 클래스 정의
│   └── interface.sv       # (Top 내 포함) I2C 인터페이스 정의
└── sim
    └── wave.fsdb          # 시뮬레이션 파형 파일
