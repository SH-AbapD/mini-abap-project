CLASS zcl_create_emp_interval DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_create_emp_interval IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    TRY.
        cl_numberrange_intervals=>create(
          interval = VALUE #( ( nrrangenr  = '01'
                                fromnumber = '00002000'
                                tonumber   = '99999999' ) )
          object   = 'ZNR_EMP' ).
        out->write( 'Interval 생성 완료' ).
      CATCH cx_number_ranges INTO DATA(lx).
        out->write( lx->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
