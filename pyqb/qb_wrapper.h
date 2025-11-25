#ifndef QB_WRAPPER_H
#define QB_WRAPPER_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct archiver archiver;

void qb_set_list_operator(archiver* arc, void* op);
void qb_clear_list_operator(archiver* arc);

#ifdef __cplusplus
}
#endif

#endif
