#ifndef UNICODE_CALLBACKS_H
#define UNICODE_CALLBACKS_H

#define UNGETCBUFSIZ    16

typedef enum UNIType {
    UNI_ERROR = -1,
    UNI_UNKNOWN,
    UNI_UTF8,
    UNI_UTF16,
    UNI_UTF32
} UNIType;

typedef struct UNIContext {
    void *ihandle;                          // in
    int (*getchar)(void *ihandle);          // in
    int (*ungetchar)(int c, void *ihandle); // in
    UNIType type;                           // in out
    unsigned int bigendian;                 // in out
    unsigned int bufp;                      // in
    char ungetcbuf[UNGETCBUFSIZ];           // in
    unsigned int escape;                    // in
    unsigned int unival;                    // in out
    void *ohandle;                          //    out
    int (*putchar)(int c, void *ohandle);   //    out
    unsigned int ostate;                    //    out
    unsigned int xunival;                   //    out;
} UNIContext;

int unicode_getchar(UNIContext *uc);
int unicode_ungetchar(int c, UNIContext *uc);
int unicode_putchar(int c, UNIContext *uc);
int unicode_print(UNIContext *uc, const char *fmt, ...);

#endif
