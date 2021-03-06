/************************************************************************
      This file is handled by the Visual Development Environment       
************************************************************************/

interface resourceIdentifiers
constants
    id_mnumain = 10000.
    id_test_forms = 10001.
    id_test_forms_main_form = 10002.
    id_test_forms_basic_form = 10003.
    id_разное = 10004.
    id_разное_окно_сообщений = 10005.
    id_разное_окно_особи = 10006.
    idt_help_line = 10007.
    
    acceleratorList : vpiDomains::accel_List =
        [
        vpiDomains::a(vpiDomains::k_f4, vpiDomains::c_Nothing, id_разное_окно_особи),
        vpiDomains::a(vpiDomains::k_f3, vpiDomains::c_Nothing, id_разное_окно_сообщений),
        vpiDomains::a(vpiDomains::k_f2, vpiDomains::c_Nothing, id_test_forms_basic_form),
        vpiDomains::a(vpiDomains::k_f1, vpiDomains::c_Nothing, id_test_forms_main_form)
        ].
end interface resourceIdentifiers
