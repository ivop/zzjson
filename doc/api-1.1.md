   #[1]zzjson (en) [2]zzjson Atom feed

API Documentation (version 1.1.x)

   From zzjson
   Jump to: [3]navigation, [4]search

Contents

     * [5]1 Getting started
     * [6]2 Datatypes
          + [7]2.1 Callbacks configuration
          + [8]2.2 ZZJSON struct
     * [9]3 Functions
          + [10]3.1 Parsing
          + [11]3.2 Printing
          + [12]3.3 Querying
          + [13]3.4 Creating
          + [14]3.5 Freeing
     * [15]4 Sample Unicode callback functions
          + [16]4.1 UNIContext
          + [17]4.2 Functions
     * [18]5 Using zzjson from C++

Getting started

   Using zzjson from within your code needs the inclusion of zzjson.h.
#include <zzjson.h>

   After that, all zzjson functions and datatypes are available to your
   program. Be sure to link with -lzzjson and -lm.

Datatypes

Callbacks configuration

   zzjson does not use any memory allocation or file i/o functions
   directly. Instead, it uses a callback mechanism if it needs to allocate
   or free a block of memory or when it needs to read or write a
   character. This way, the user can supply their own memory manager and
   zzjson does not care whether bytes are coming from a file, from memory
   or over a network connection.

   Most zzjson functions below take a pointer to a ZZJSON_CONFIG struct as
   its first argument. This struct descibes what functions to use.
typedef struct ZZJSON_CONFIG {
    int strictness;
    void *ihandle;
    int (*getchar)(void *ihandle);
    int (*ungetchar)(int c, void *ihandle);
    void *(*malloc)(size_t size);
    void *(*calloc)(size_t nmemb, size_t size);
    void (*free)(void *ptr);
    void *(*realloc)(void *ptr, size_t size);
    void *ehandle;
    void (*error)(void *ehandle, const char *format, ...);
    void *ohandle;
    int (*print)(void *ohandle, const char *format, ...);
    int (*putchar)(int c, void *handle);
} ZZJSON_CONFIG;

   The callback function prototypes resemble common libc functions, so if
   you don't need any special functionality, you can just assign those.
   For example, the parser input routines can be defined as fgetc() and
   ungetc() and the input handle void *ihandle will be of type FILE *.
   error() and print() are similar to fprintf(), although error() is not
   supposed to return an int for obvious reasons.

   The strictness field defines how strict the parser should follow the
   JSON standard. See the description zzjson_parse() below.

ZZJSON struct

   A lot of functions either return or take as an argument a pointer to a
   ZZJSON structure. This is the basic building block of a parsed or
   created JSON object or array. Look at zzjson.h for details. Normally,
   you won't have to be bothered by the internal structure of a ZZJSON
   struct, but it might be helpful if you want to write, for example, your
   own traversal function. Keep in mind that the next field is only used
   when ZZJSON is of type ZZJSON_ARRAY or ZZJSON_OBJECT.

Functions

Parsing

ZZJSON *zzjson_parse(ZZJSON_CONFIG *config);

   zzjson_parse() reads consecutive bytes through the callback functions
   defined in config. If everything goes well, it returns a pointer to a
   ZZJSON struct. This pointer can later be handed over to querying
   functions or to zzjson_print(). In case an error occurred,
   zzjson_parse() returns NULL and an appropriate error message is printed
   through config->error(). Memory is allocated by using the functions
   specified in config.

   The behaviour of the parser in case of parse errors can be influenced
   by setting the config->strictness field. If it's zero or
   ZZJSON_VERY_STRICT it will not allow anything that violates the
   standard. Several flags can be set to be a little more loose in
   interpreting the incoming bytestream. Possible flags are:

   ZZJSON_ALLOW_EXTRA_COMMA

          This will parse the following sequences as if the extra comma
          was not there, which is otherwise invalid:

{ "hello" : "world", }
[ 3, 1, 4, 1, 5, ]

   ZZJSON_ALLOW_ILLEGAL_ESCAPE

          This will allow escaped characters that have no special meaning.
          It'll convert them to normal characters.

{ "foo" : "b\ar" }

   ZZJSON_ALLOW_CONTROL_CHARS

          Normally, all control characters (ASCII values 0..31) are
          invalid. Setting this flag will parse them as being normal
          characters.

[ "normally, a string cannot, for example,
contain a newline character" ]

   ZZJSON_ALLOW_GARBAGE_AT_END

          This will allow garbage characters after a successful object or
          array is parsed.

{ "fubar" : "snafu" } }

   ZZJSON_ALLOW_COMMENTS

          Allow C-style comments during whitespace sections.

{ "fubar" : "snafu" /* yet another silly tuple */ }

   To enable all at once, one can use config->strictness =
   ZZJSON_VERY_LOOSE.

   Example:
ZZJSON_CONFIG config;
...
config.strictness = ZZJSON_ALLOW_EXTRA_COMMA | ZZJSON_ALLOW_GARBAGE_AT_END;

Printing

int zzjson_print(ZZJSON_CONFIG *config, ZZJSON *zzjson);

   zzjson_print() uses config->putchar() and config->print() to output a
   textual representation of the specified ZZJSON structure, which must
   either be of type ZZJSON_ARRAY or ZZJSON_OBJECT.

   On success it returns a value >= 0, on error it returns a value < 0.

Querying

ZZJSON *zzjson_object_find_label(ZZJSON *zzjson, char *label);
ZZJSON *zzjson_object_find_labels(ZZJSON *zzjson, ...);
unsigned int zzjson_object_count(ZZJSON *zzjson);
unsigned int zzjson_array_count(ZZJSON *zzjson);

   The query functions can be used to search for specific objects or count
   the number of entries of an object or array.

   zzjson_object_find_label() searches for a specific label.
   zzjson_object_find_labels() searches for a list of labels, layer by
   layer. The list consists of zero or more arguments of type char * and
   must be closed by an argument of value NULL.

   Consider the following JSON input:
{
  "Image1" : {
    "Width" : 800, "Height" : 600, "Title" :  "View from 15th Floor",
    "Thumbnail" : {
      "Url" : "http://www.example.com/image/481989943",
      "Height" : 125, "Width" :  "100"
    }
  },
  "Image2" : {
    "Width" : 800, "Height" : 600, "Title" :  "View from 16th Floor",
    "Thumbnail" : {
      "Url" : "http://www.example.com/image/481989943",
      "Height" : 125, "Width" :  "100"
    }
  }
}

   If you want to retrieve all information of Image2 at once, you can use:
result = zzjson_object_find_label(zzjson, "Image2");

   result will be a pointer to a ZZJSON structure of type ZZJSON_OBJECT.

   If you just want to retrieve something specific, you can use:
result = zzjson_object_find_labels(zzjson, "Image2", "Thumbnail", "Url", NULL);

   result will be a pointer to a ZZJSON structure of type ZZJSON_STRING.

   Keep in mind that internally the data is stored in linked lists and
   that searching this way is not very fast.

   Both zzjson_object_find_label() and zzjson_object_find_labels() return
   NULL on error.

Creating

ZZJSON *zzjson_create_true(ZZJSON_CONFIG *config);
ZZJSON *zzjson_create_false(ZZJSON_CONFIG *config);
ZZJSON *zzjson_create_null(ZZJSON_CONFIG *config);
ZZJSON *zzjson_create_number_d(ZZJSON_CONFIG *config, double d);
ZZJSON *zzjson_create_number_i(ZZJSON_CONFIG *config, long long i);
ZZJSON *zzjson_create_string(ZZJSON_CONFIG *config, char *s);

   These functions create a ZZJSON structure of said type. Memory is
   allocated through the callbacks specified in config. All functions
   return NULL on error. On success, the resulting pointer can later be
   passed on to one of the functions below to put them inside an array or
   an object.
ZZJSON *zzjson_create_array(ZZJSON_CONFIG *config, ...);
ZZJSON *zzjson_create_object(ZZJSON_CONFIG *config, ...);

   zzjson_create_array() takes a list of zero or more pointers to ZZJSON
   structures, terminated by a NULL pointer. The structures are stored in
   the specified order.

   zzjson_create_object() takes a list of zero or more pairs of char
   *label and ZZJSON *, terminated by a single NULL pointer. The
   label-value-pairs are stored in the specified order.

   Both functions return a pointer to the newly created array or object.
   In case of an error, they return NULL. If you run out of memory during
   construction of the array or object, all newly allocated memory is
   freed before returning NULL. The specified arguments (ZZJSON structures
   and labels) are not freed.
ZZJSON *zzjson_array_prepend(ZZJSON_CONFIG *config, ZZJSON *array,
                                                    ZZJSON *val);
ZZJSON *zzjson_array_append (ZZJSON_CONFIG *config, ZZJSON *array,
                                                    ZZJSON *val);
ZZJSON *zzjson_object_prepend(ZZJSON_CONFIG *config, ZZJSON *object,
                                        char *label, ZZJSON *val);
ZZJSON *zzjson_object_append (ZZJSON_CONFIG *config, ZZJSON *object,
                                        char *label, ZZJSON *val);

   The specified value or label-value-pair is either prepended or appended
   to the specified array or object. The return value is either NULL on
   error, or a pointer to the array or object with the new value or
   label-value-pair append or prepended. In case of a successful append,
   the return value is equal to the array or object passed to the
   function.

   Keep in mind that internally all data is stored in a linked list.
   Therefore, prepending is fast (Big-O(1)) and appending is slow
   (Big-O(n)).

Freeing

void zzjson_free(ZZJSON_CONFIG *config, ZZJSON *zzjson);

   zzjson_free() frees all memory currently in use by the specified ZZJSON
   structure and everything it links to (labels, values, strings, et
   cetera). It uses config->free to do the freeing.

Sample Unicode callback functions

   Included in the unicode/ directory are sample Unicode callbacks. They
   work by converting all Unicode encodings on-the-fly to plain ASCII with
   \u escaped Unicode characters and back again when printing. All Unicode
   callback functions take a pointer to a UNIContext structure as an
   argument.

UNIContext

typedef struct UNIContext {
    void *ihandle;
    int (*getchar)(void *ihandle);
    int (*ungetchar)(int c, void *ihandle);
    UNIType type;
    unsigned int bigendian;
    unsigned int bufp;
    char ungetcbuf[UNGETCBUFSIZ];
    unsigned int escape;
    unsigned int unival;
    void *ohandle;
    int (*putchar)(int c, void *ohandle);
    unsigned int ostate;
    unsigned int xunival;
    void *ehandle;
    void (*error)(void *ehandle, const char *format, ...);
} UNIContext;

   The UNIContext structure contains callbacks itself. These could point
   to basic libc functions like getchar() and putchar() or to
   user-supplied special purpose callback functions. The rest of the
   fields should be initialized to zero and should not be touched by the
   application. They represent internal states used by the Unicode
   callback functions.

Functions

int unicode_getchar(UNIContext *uc);
int unicode_ungetchar(int c, UNIContext *uc);
int unicode_putchar(int c, UNIContext *uc);
int unicode_print(UNIContext *uc, const char *fmt, ...);

Using zzjson from C++

   You can use zzjson from C++ like any other C library. Just include
   zzjson.h from within the right linkage specification:
extern "C" {
#include "zzjson.h"
}

   After that, you can use zzjson as you would with any C functions
   included in C++. Be sure to link with -lzzjson and -lm.
   Retrieved from
   "[19]http://zzjson.sourceforge.net/wiki/index.php?title=API_Documentati
   on_(version_1.1.x)&oldid=30"

Navigation menu

Personal tools

     * [20]Create account
     * [21]Log in

Namespaces

     * [22]Page
     * [23]Discussion

Variants

Views

     * [24]Read
     * [25]View source
     * [26]View history

Actions

Search

   ____________________ Search Go

Navigation

     * [27]Main page
     * [28]Recent changes
     * [29]Random page
     * [30]Help

Tools

     * [31]What links here
     * [32]Related changes
     * [33]Special pages
     * [34]Printable version
     * [35]Permanent link
     * [36]Page information

     * This page was last modified on 16 August 2009, at 01:05.
     * This page has been accessed 2,044 times.

     * [37]Privacy policy
     * [38]About zzjson
     * [39]Disclaimers

     * [40]Powered by MediaWiki

References

   Visible links:
   1. https://zzjson.sourceforge.net/wiki/opensearch_desc.php
   2. https://zzjson.sourceforge.net/wiki/index.php?title=Special:RecentChanges&feed=atom
   3. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#mw-navigation
   4. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#p-search
   5. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Getting_started
   6. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Datatypes
   7. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Callbacks_configuration
   8. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#ZZJSON_struct
   9. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Functions
  10. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Parsing
  11. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Printing
  12. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Querying
  13. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Creating
  14. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Freeing
  15. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Sample_Unicode_callback_functions
  16. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#UNIContext
  17. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Functions_2
  18. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)#Using_zzjson_from_C.2B.2B
  19. http://zzjson.sourceforge.net/wiki/index.php?title=API_Documentation_(version_1.1.x)&oldid=30
  20. https://zzjson.sourceforge.net/wiki/index.php?title=Special:UserLogin&returnto=API+Documentation+(version+1.1.x)&type=signup
  21. https://zzjson.sourceforge.net/wiki/index.php?title=Special:UserLogin&returnto=API+Documentation+(version+1.1.x)
  22. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)
  23. https://zzjson.sourceforge.net/wiki/index.php?title=Talk:API_Documentation_(version_1.1.x)&action=edit&redlink=1
  24. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_(version_1.1.x)
  25. https://zzjson.sourceforge.net/wiki/index.php?title=API_Documentation_(version_1.1.x)&action=edit
  26. https://zzjson.sourceforge.net/wiki/index.php?title=API_Documentation_(version_1.1.x)&action=history
  27. https://zzjson.sourceforge.net/wiki/index.php/Main_Page
  28. https://zzjson.sourceforge.net/wiki/index.php/Special:RecentChanges
  29. https://zzjson.sourceforge.net/wiki/index.php/Special:Random
  30. https://www.mediawiki.org/wiki/Special:MyLanguage/Help:Contents
  31. https://zzjson.sourceforge.net/wiki/index.php/Special:WhatLinksHere/API_Documentation_(version_1.1.x)
  32. https://zzjson.sourceforge.net/wiki/index.php/Special:RecentChangesLinked/API_Documentation_(version_1.1.x)
  33. https://zzjson.sourceforge.net/wiki/index.php/Special:SpecialPages
  34. https://zzjson.sourceforge.net/wiki/index.php?title=API_Documentation_(version_1.1.x)&printable=yes
  35. https://zzjson.sourceforge.net/wiki/index.php?title=API_Documentation_(version_1.1.x)&oldid=30
  36. https://zzjson.sourceforge.net/wiki/index.php?title=API_Documentation_(version_1.1.x)&action=info
  37. https://zzjson.sourceforge.net/wiki/index.php/Zzjson:Privacy_policy
  38. https://zzjson.sourceforge.net/wiki/index.php/Zzjson:About
  39. https://zzjson.sourceforge.net/wiki/index.php/Zzjson:General_disclaimer
  40. https://www.mediawiki.org/

   Hidden links:
  42. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_%28version_1.1.x%29
  43. https://zzjson.sourceforge.net/wiki/index.php/API_Documentation_%28version_1.1.x%29
  44. https://zzjson.sourceforge.net/wiki/index.php/Main_Page
