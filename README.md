# 사내 요청 관리 시스템 — ABAP RAP 기반

> SAP BTP ABAP Environment 위에서 **ABAP RESTful Application Programming Model(RAP)** 로 구현한 사내 요청 관리 시스템입니다. 마스터 데이터 4종과 승인 워크플로우를 갖춘 트랜잭션 업무 객체를 RAP 표준 아키텍처로 직접 설계·구현했습니다.
> 

`ABAP Cloud` · `RAP (Managed)` · `CDS` · `OData V2` · `SAP Fiori Elements` · `abapGit`

---

## 프로젝트 개요

직원이 사내 요청을 등록하면 직원 본인이 취소하거나, 관리자가 **승인 / 반려** 할 수 있는 요청 관리 시스템입니다. 단순 CRUD가 아니라, **상태 기반 승인 워크플로우**와 **권한·검증 로직**을 RAP 비즈니스 오브젝트(BO) 안에 직접 구현하는 데 초점을 맞췄습니다.

---

## 기술 스택

| 구분 | 사용 기술 |
| --- | --- |
| 개발 모델 | ABAP RESTful Application Programming Model (Managed) |
| 언어 | ABAP for Cloud Development (ABAP Cloud, strict mode) |
| 데이터 모델 | Core Data Services (CDS) View |
| 서비스 | OData V2 (Service Definition / Binding) |
| UI | SAP Fiori Elements (Metadata Extension 기반) |
| 플랫폼 / 도구 | SAP BTP ABAP Environment (Trial) · Eclipse ADT |
| 형상 관리 | abapGit → GitHub |

> 서비스 바인딩은 OData **V2 UI**를 사용합니다. (V4 UI는 draft 기반 동작을 전제로 하여, non-draft 구조에서는 Create 등 일부 기능이 노출되지 않는 이슈가 있어 V2를 선택했습니다.)
> 

---

## 아키텍처

### 비즈니스 오브젝트 구성

마스터 데이터 4종과 트랜잭션 1종, 총 5개의 비즈니스 오브젝트로 구성됩니다.

<img width="1774" height="887" alt="image" src="https://github.com/user-attachments/assets/113fb6ef-2918-48d4-b54b-a65d78990521" />

| 도메인 | 유형 | 주요 기능 |
| --- | --- | --- |
| Department (부서) | 마스터 | CRUD, 활성/비활성 |
| Position (직급) | 마스터 | CRUD, 활성/비활성 |
| Employee (직원) | 마스터 | CRUD, EmployeeId 자동 채번, 이메일 검증, 부서·직급 연결 |
| Request Type (요청 유형) | 마스터 | CRUD, 활성/비활성 |
| **Request Header (요청)** | **트랜잭션** | **등록 → 승인/반려/취소 워크플로우** |

---

### RAP 3-Layer 구조

각 BO는 DB Table → Interface View → Projection View → Behavior(Definition/Implementation) → Metadata Extension → Service(Definition/Binding) 계층을 동일하게 따릅니다.

<img width="1159" height="1358" alt="image" src="https://github.com/user-attachments/assets/d1c9aa04-58df-4c41-9fec-594cdc199738" />

---

## 핵심 기능: 요청 승인 WorkFlow

요청은 생성 시 **대기(P)** 상태가 되며, 관리자의 처리에 따라 상태가 전이됩니다. 한 번 처리된 요청은 다시 수정·처리할 수 없도록 상태 기반 권한으로 제어됩니다.

<img width="1448" height="1086" alt="image" src="https://github.com/user-attachments/assets/b05de259-57bd-425b-b036-ecacb1176077" />


| 상태 | 의미 | 전이 액션 |
| --- | --- | --- |
| `P` | 대기 (Pending) | 생성 시 자동 설정 (Determination) |
| `A` | 승인 (Approved) | `approve` — 처리자·처리일시 기록 |
| `R` | 반려 (Rejected) | `reject` — 반려 사유 파라미터 입력 |
| `C` | 취소 (Cancelled) | `cancel` — 신청자 본인 철회 |

---

## 주요 설계 결정

**1. 취소를 삭제가 아닌 "상태(C)"로 관리**

요청을 DB에서 삭제하지 않고 취소 상태로 남깁니다. 누가 언제 무슨 요청을 했고 언제 취소되었는지가 신청 이력으로 보존되어야 하며, 인사·총무 업무에서 이 이력은 감사 추적의 근거가 되기 때문입니다.

**2. 처리 완료된 요청은 잠금 (수정 불가)**

승인·반려된 건은 이후 수정할 수 없도록 막았습니다. 이미 결재가 끝난 요청이 사후에 변경되면 "승인된 내용 = 결재 시점의 내용"이라는 보장이 깨지므로, 결재 무결성을 위해 처리 완료 건을 고정합니다.

**3. 마스터 데이터는 삭제 대신 비활성화(IsActive)**

부서·직급·요청유형은 삭제하지 않고 비활성 처리합니다. 폐지된 부서라도 과거 요청이 이를 참조하고 있어 삭제 시 참조 무결성이 깨지기 때문에, 신규 사용만 차단하고 기존 데이터는 유지합니다.

**4. 액션별 권한 주체 분리**

승인·반려는 관리자만, 취소는 신청자 본인만 수행할 수 있도록 권한을 나눴습니다. 결재는 관리자 권한, 철회는 신청자 권한이라는 실제 결재 프로세스의 역할 분담을 시스템에 반영한 것입니다.

---

## 스크린샷

### 1. 요청 목록 — 워크플로우 처리 결과 (List Report)

승인(A) / 반려(R) / 취소(C) / 대기(P) 상태가 함께 표시되어, 상태 머신 기반 워크플로우가 실제로 동작함을 보여줍니다.

<img width="1574" height="479" alt="image" src="https://github.com/user-attachments/assets/d0954b23-c9fc-4607-917f-b6f8a9adc5f4" />


---

### 2. 요청 상세 — 반려 처리 건 (Object Page)

반려(R) 처리된 요청의 상세 화면입니다. 처리자 · 처리일시(Time Stamp) · 거절사유가 액션 실행 시 자동으로 기록되어, 워크플로우 처리 결과가 데이터로 남는 것을 확인할 수 있습니다.

<img width="1589" height="237" alt="image" src="https://github.com/user-attachments/assets/28e725de-aa5b-4217-b91a-747f01b56011" />

---

### **3. Value Help — 직원 검색 (CDS Association)**

직원ID 입력 시 다른 BO의 마스터 데이터를 검색해 연결하는 Value Help 다이얼로그입니다. 직원 정보뿐 아니라 연결된 부서·직급까지 함께 조회되어, CDS Association이 올바르게 동작함을 보여줍니다.

<img width="1583" height="852" alt="image" src="https://github.com/user-attachments/assets/dec816ca-7f1f-4110-854d-91ccff7decd3" />

---

## 실행 / 환경

- 개발/실행: SAP BTP ABAP Environment (Trial)에서 ADT로 개발, Fiori Elements Preview로 실행
- 형상 관리: abapGit으로 본 저장소와 동기화

---

## 한계점 및 향후 개선

> 현재 범위에서의 한계점과, 다음 단계로 확장할 방향입니다.
> 

**1. 요청 취소(cancel)의 화면·권한 분리**

현재는 관리자와 신청자가 동일한 단일 앱을 사용하며, 권한은 Behavior 레벨(Global/Instance Authorization)에서 제어합니다. 다만 역할별로 보이는 화면 자체를 분리하면 사용성과 보안이 더 명확해집니다. 향후 신청자용/관리자용 Projection View와 Service Binding을 분리하고, 본인 요청만 필터링하는 구조로 확장할 수 있습니다.

**2. OData V2 → V4 + draft 전환**

draft 기반 동작 이슈로 현재 V2 UI를 사용하고 있습니다. V4 UI + draft-enabled 구조로 전환하면 임시 저장, 동시 편집 제어 등 최신 Fiori Elements 기능을 활용할 수 있습니다.

**3. 테스트 커버리지 확대**

현재 Employee의 활성/비활성 액션에 대한 ABAP Unit 테스트가 작성되어 있습니다. 핵심 워크플로우인 approve / reject / cancel 액션과 상태 전이 검증까지 테스트를 확대하면, 워크플로우의 안정성을 코드로 보장할 수 있습니다.
