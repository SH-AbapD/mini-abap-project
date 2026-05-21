CLASS ztest_00 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ztest_00 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    out->write( sy-uname ).

  ENDMETHOD.
ENDCLASS.
