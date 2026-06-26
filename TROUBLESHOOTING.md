# 트러블슈팅

---

## Case 1. strict(2)에서 기본키 필드를 Determination으로 채울 수 없다

**문제 상황**

Employee BO를 처음 설계할 때, 사람이 읽는 사번(`EmployeeId`)을 그대로 기본키로 쓰고 생성 시 setEmployeeId determination으로 자동 넘버링하는 구조로 의도함. 하지만 `MODIFY ENTITIES`로 키 값을 채우는 코드를 실행해도 값이 채워지지 않고, 직접적인 에러가 발생하지 않아 원인 규명에 난항을 겪음.

**원인 분석**

RAP에서 기본키 필드는 한번 정해지면 바뀌지 않는 값으로 취급되기 때문에, determination 안에서 `MODIFY ENTITIES`로 다시 쓰는 것이 허용되지 않는다는 것을 발견(strict 모드에서는 이 검증이 더 엄격하게 적용). 그에 따라 키로 지정했던 `EmployeeId`에 대한 자동 넘버링 시도가 별다른 에러 없이 묻힘.

**해결**

기술적인 키와 사람이 보는 식별자를 분리. 프레임워크가 자동으로 만들어 주는 UUID(`EmployeeUuid`)를 실제 기본키로 두고, 사번(`EmployeeId`)은 키가 아닌 별도 필드로 분리함. `EmployeeId`는 `field( readonly : update )`로 선언해, 생성할 때만 determination으로 자동 넘버링하고 이후에는 수정되지 않도록 함.

```abap
" BDEF 선언
field ( numbering : managed, readonly ) EmployeeUuid;  " 실제 키
field ( readonly : update ) EmployeeId;                " 채번 후 잠금

" Determination 구현
METHOD setEmployeeId.
  READ ENTITIES OF zi_tr_empolyee IN LOCAL MODE
    ENTITY Emp FIELDS ( EmployeeId ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_emp).

  LOOP AT lt_emp INTO DATA(ls_emp).
    IF ls_emp-EmployeeId IS INITIAL.
      " 기존 최대값 조회 후 +1 채번
      ...
    ENDIF.
  ENDLOOP.
ENDMETHOD.
```

---

## Case 2. Odata 버전에 따라 Create 버튼 보이지 않는 문제

**문제 상황**

Interface View bdef와 Projection View Bdef에 `create`와`update`를 모두 선언했음에도 preview에서 해당 기능의 버튼이 나타나지 않는 문제 발생.

메서드 구현을 마친 이후 다시 publish를 진행했음에도 여전히 버튼이 보이지 않음.

```abap
" Interface View BDEF — 생성/수정 동작 선언
managed implementation in class zbp_i_tr_req_hdr unique;
strict ( 2 );
define behavior for ZI_TR_REQ_HDR alias Req
...
{
  create;
  update;
  ...
}

" Projection View BDEF — 동일하게 노출
projection;
strict ( 2 );
define behavior for ZC_TR_REQ_HDR alias Req
{
  use create;
  use update;
  ...
}
```

**원인 분석**

처음에는 권한(`authorization`) 문제로 버튼이 보이지 않는 줄 알았으나, 권한 체크 로직을 수정해봐도 문제가 지속됨. 공식 페이지를 찾아보던 중 버전과 draft에 대한 내용이 연관되어 있다는 단서를 발견함. 하지만 최초에는 데이터 저장 방식인 draft와 버튼이 어떤 연관 관계인지 쉽게 연결되지 않음.

자세히 보니 핵심은 버전 자체에 문제라기 보다는, V4 UI가 draft를 전제로 동작한다는 사실을 발견하게 됨. V4는 생성 흐름 자체를 draft 중심으로 인식하기 때문에 Fiori에서 Create를 누르면 draft 즉, 임시 데이터를 생성하고 최종 확정 시점에 실제 데이터로 저장.

따라서 BO가 draft-enabled로 구성되어 있지 않다면 V4 UI는 누를 대상이 없다고 판단하여 Create 버튼을 노출하지 않는 현상이 발생한 것.

**해결**

<img width="665" height="556" alt="image" src="https://github.com/user-attachments/assets/1bea4ec5-8f9f-44ed-8e3c-7dba810b5db0" /> <img width="660" height="567" alt="image" src="https://github.com/user-attachments/assets/9653be68-2c28-412d-8f0d-16bce6f36049" />


V2, V4 버전 모두 생성. V2 버전에서는 정상적으로 버튼이 나타나는 것을 확인함.

<img width="461" height="143" alt="image" src="https://github.com/user-attachments/assets/2028e5be-42f2-4f5e-bccf-1cf0fc931534" />

V2 버전에서는 draft를 사용하지 않는 구조에서도 Create가 실제 데이터를 생성하는 흐름이기 때문에 동일한 BDEF로도 생성·수정 기능이 정상 동작함을 확인함. (draft 도입은 향후 개선 과제로 분리)

---

## Case 3. 신청·승인 권한을 BO 성격에 맞게 2단으로 분리

**문제 상황**

마스터 데이터 BO(Department, Position 등)는 관리자만 다루므로 "관리자인가"만 확인하는 Global Authorization 한 겹으로 충분했음. 그러나 Request Header는 **신청자와 관리자가 같은 데이터를 함께 사용**하는 트랜잭션 BO로, 동일한 요청이라도 상태와 주체에 따라 허용되는 행위가 달라야 했음. Global 권한만으로는 다음을 막을 수 없었음.

- 이미 승인(A)된 요청을 관리자가 다시 승인/반려하는 경우
- 타인의 요청을 본인이 아닌 사용자가 취소하는 경우

**원인 분석**

Global Authorization은 "이 사용자가 이 액션을 쓸 자격이 있는가" (역할 기준)만 판단함. 반면 위 문제들은 "지금 이 건에 대해 이 액션이 가능한가" (상태·소유자 기준)의 영역으로, 인스턴스 단위 판단이 필요했음. 즉 권한을 역할 차원(Global)과 인스턴스 차원(Instance)으로 나눠 다뤄야 했음.

**해결**

권한을 2단으로 구성함. 다른 BO들과 달리 Request Header에만 `Instance Authorization`을 추가함.

- **Global** — 역할 기준. 승인·반려는 관리자만, 생성은 모든 사용자 허용.
- **Instance** — 상태·소유자 기준. 승인·반려·수정은 상태가 대기(P)일 때만 허용하고, 취소는 대기 상태이면서 신청자 본인(`CreatedBy = sy-uname`)일 때만 허용.

```abap
" Instance — 건별로 상태·소유자를 확인해 액션 허용 여부 결정
METHOD get_instance_authorizations.
  READ ENTITIES OF zi_tr_req_hdr IN LOCAL MODE
    ENTITY Req FIELDS ( Status CreatedBy )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_req).

  LOOP AT lt_req INTO DATA(ls_req).
    " 승인: 대기(P) 상태일 때만
    <r>-%action-approve = COND #(
      WHEN ls_req-Status = 'P'
      THEN if_abap_behv=>auth-allowed
      ELSE if_abap_behv=>auth-unauthorized ).

    " 취소: 대기(P) + 신청자 본인일 때만
    <r>-%action-cancel = COND #(
      WHEN ls_req-Status = 'P' AND ls_req-CreatedBy = sy-uname
      THEN if_abap_behv=>auth-allowed
      ELSE if_abap_behv=>auth-unauthorized ).
  ENDLOOP.
ENDMETHOD.
```
