from libc.stdint cimport uint32_t, uint64_t, uint8_t, int64_t
from libcpp cimport bool

cdef extern from "../src/archive.h":
    
    struct infonode:
        char *name
    
    struct list_record:
        infonode *info
        char *full_name
        uint32_t *errcode

    struct list_summary_record:
        uint32_t dirs
        uint32_t files
        int64_t size

    ctypedef void (*list_operator)(const list_record *v)
    ctypedef void (*list_summary_operator)(const list_summary_record *v)

    cdef cppclass archiver:
        archiver() except +
        
        bool ignore_pt
        uint32_t errcode
        uint32_t header_size
        uint64_t data_size
        uint64_t rwl
        
        void add_name(const char *name)
        void set_base(const char *name)
        void archive(const char *filename, bool unarc, uint8_t unarc_null)

# Declare wrapper functions
cdef extern from "qb_wrapper.h":
    void qb_set_list_operator(archiver* arc, void* op)
    void qb_clear_list_operator(archiver* arc)
