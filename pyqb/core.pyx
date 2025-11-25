# distutils: language = c++

from pyqb.libqb cimport archiver, list_record, list_summary_record, qb_set_list_operator, qb_clear_list_operator
from libc.stdlib cimport malloc, free
from libc.string cimport strcpy, strlen
import os

# Global variable to hold the current Python callback for listing
# This is a limitation because the C++ API doesn't accept a user_data pointer
cdef object _global_list_callback = None

cdef void c_list_callback(const list_record *v) noexcept nogil:
    with gil:
        if _global_list_callback:
            name = v.full_name.decode('utf-8', 'replace') if v.full_name else ""
            # We could extract more info here if needed
            _global_list_callback(name)

cdef class Archiver:
    cdef archiver *thisptr

    def __cinit__(self):
        self.thisptr = new archiver()

    def __dealloc__(self):
        if self.thisptr:
            del self.thisptr

    def pack(self, inputs, output_file):
        """
        Create an archive from input files/directories.
        
        Args:
            inputs (str or list): Path or list of paths to input files/directories.
            output_file (str): Path to the output .qb file.
        """
        cdef bytes b_output = os.path.abspath(output_file).encode('utf-8')
        cdef bytes b_input
        
        if isinstance(inputs, str):
            inputs = [inputs]
            
        for inp in inputs:
            b_input = os.path.abspath(inp).encode('utf-8')
            self.thisptr.add_name(b_input)
            if self.thisptr.errcode:
                raise RuntimeError(f"Error adding {inp}: Code {self.thisptr.errcode}")

        # Perform archiving
        # archive(output_file, unarc=False, unarc_null=0)
        self.thisptr.archive(b_output, False, 0)
        
        if self.thisptr.errcode:
            raise RuntimeError(f"Archiving failed with error code: {hex(self.thisptr.errcode)}")

    def unpack(self, input_file, output_dir=None):
        """
        Unpack an archive.
        
        Args:
            input_file (str): Path to the .qb archive.
            output_dir (str, optional): Directory to unpack into. Defaults to current directory.
        """
        cdef bytes b_input = os.path.abspath(input_file).encode('utf-8')
        cdef bytes b_base
        
        if output_dir:
            b_base = os.path.abspath(output_dir).encode('utf-8')
            self.thisptr.set_base(b_base)
            if self.thisptr.errcode:
                raise RuntimeError(f"Error setting base dir: Code {self.thisptr.errcode}")

        # Perform unpacking
        # archive(input_file, unarc=True, unarc_null=0)
        self.thisptr.archive(b_input, True, 0)

        if self.thisptr.errcode:
            raise RuntimeError(f"Unpacking failed with error code: {hex(self.thisptr.errcode)}")

    def list(self, input_file):
        """
        List contents of an archive.
        
        Args:
            input_file (str): Path to the .qb archive.
            
        Returns:
            list: A list of filenames in the archive.
        """
        cdef bytes b_input = os.path.abspath(input_file).encode('utf-8')
        
        results = []
        global _global_list_callback
        
        def callback(name):
            results.append(name)
        
        # Set up callback
        _global_list_callback = callback
        qb_set_list_operator(self.thisptr, <void*>c_list_callback)
        
        try:
            # archive(input_file, unarc=True, unarc_null=2) for list mode
            self.thisptr.archive(b_input, True, 2)
        finally:
            _global_list_callback = None
            qb_clear_list_operator(self.thisptr)

        if self.thisptr.errcode:
            raise RuntimeError(f"Listing failed with error code: {hex(self.thisptr.errcode)}")
            
        return results
