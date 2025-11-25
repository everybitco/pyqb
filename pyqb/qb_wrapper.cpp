#include "qb_wrapper.h"
#include "../src/archive.h"

extern "C" {
    // Wrapper functions to avoid Cython's confusion with function pointer types
    void qb_set_list_operator(archiver* arc, void* op) {
        arc->set_list_operator((list_operator)op);
    }
    
    void qb_clear_list_operator(archiver* arc) {
        arc->set_list_operator(NULL);
    }
}
